#!/usr/sbin/dtrace -Zs
/*
 * tcl_methodcalls.d - count Tcl method calls DTrace.
 *                     Written for the Tcl DTrace provider.
 *
 * $Id: tcl_proccalls.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces activity from all Tcl processes on the system with DTrace
 * provider support (tcl8.4.16).
 *
 * USAGE: tcl_methodcalls.d 	# hit Ctrl-C to end
 *
 * FIELDS:
 *		PID		Process ID
 *		COUNT		Number of calls during sample
 *		PROCEDURE	Tcl procedure name
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

tcl*:::proc-entry
{
	@calls[pid, copyinstr(arg0)] = count();
}

dtrace:::END
{
	printf(" %6s %8s %s\n", "PID", "COUNT", "PROCEDURE");
	printa(" %6d %@8d %s\n", @calls);
}
