#!/usr/sbin/dtrace -ZCs
/*
 * tcl_calls.d - count Tcl calls (proc/cmd) using DTrace.
 *               Written for the Tcl DTrace provider.
 *
 * $Id: tcl_calls.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces activity from all Tcl processes on the system with DTrace
 * provider support (tcl8.4.16).
 *
 * USAGE: tcl_calls.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		PID		Process ID
 *		TYPE		Type of call (see below)
 *		NAME		Name of proc or cmd call
 *		COUNT		Number of calls during sample
 *
 * TYPEs:
 *		proc		procedure
 *		cmd		command
 *
 * PORTIONS: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 09-Sep-2007	Brendan Gregg	Created this.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

tcl*:::proc-entry
{
	@calls[pid, "proc", copyinstr(arg0)] = count();
}

tcl*:::cmd-entry
{
	@calls[pid, "cmd", copyinstr(arg0)] = count();
}

dtrace:::END
{
	printf(" %6s %-8s %-52s %8s\n", "PID", "TYPE", "NAME", "COUNT");
	printa(" %6d %-8s %-52s %@8d\n", @calls);
}
