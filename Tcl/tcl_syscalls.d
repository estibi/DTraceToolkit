#!/usr/sbin/dtrace -Zs
/*
 * tcl_syscalls.d - count Tcl calls and syscalls using DTrace.
 *                  Written for the Tcl DTrace provider.
 *
 * $Id: tcl_syscalls.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces activity from all Tcl processes on the system with DTrace
 * provider support (tcl8.4.16).
 *
 * USAGE: tcl_syscalls.d { -p PID | -c cmd }	# hit Ctrl-C to end
 *
 * FIELDS:
 *		PID		Process ID
 *		TYPE		Type of call (method/syscall)
 *		NAME		Name of call
 *		COUNT		Number of calls during sample
 *
 * COPYRIGHT: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 09-Sep-2007	Brendan Gregg	Created this.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

tcl$target:::proc-entry
{
	@calls[pid, "proc", copyinstr(arg0)] = count();
}

tcl$target:::cmd-entry
{
	@calls[pid, "cmd", copyinstr(arg0)] = count();
}

syscall:::entry
/pid == $target/
{
	@calls[pid, "syscall", probefunc] = count();
}


dtrace:::END
{
	printf(" %6s %-8s %-52s %8s\n", "PID", "TYPE", "NAME", "COUNT");
	printa(" %6d %-8s %-52s %@8d\n", @calls);
}
