#!/usr/sbin/dtrace -ZCs
/*
 * tcl_ins.d - count Tcl instructions using DTrace.
 *             Written for the Tcl DTrace provider.
 *
 * $Id: tcl_ins.d 64 2007-10-04 08:35:29Z claire $
 *
 * This traces activity from all Tcl processes on the system with DTrace
 * provider support (tcl8.4.16).
 *
 * USAGE: tcl_calls.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		PID		Process ID
 *		TYPE		Type of call (see below)
 *		NAME		Name of call
 *		COUNT		Number of calls during sample
 *
 * TYPEs:
 *		inst		instruction
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

tcl*:::inst-start
{
	@calls[pid, "inst", copyinstr(arg0)] = count();
}

dtrace:::END
{
	printf(" %6s %-8s %-52s %8s\n", "PID", "TYPE", "NAME", "COUNT");
	printa(" %6d %-8s %-52s %@8d\n", @calls);
}
