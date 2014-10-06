#!/usr/sbin/dtrace -Zs
/*
 * tcl_flow.d - snoop Tcl execution showing procedure flow using DTrace.
 *              Written for the Tcl DTrace provider.
 *
 * $Id: tcl_flow.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces activity from all Tcl processes on the system with DTrace
 * provider support (tcl8.4.16).
 *
 * USAGE: tcl_flow.d		# hit Ctrl-C to end
 *
 * This watches Tcl method entries and returns, and indents child
 * method calls.
 *
 * FIELDS:
 *		C		CPU-id
 *		TIME(us)	Time since boot, us
 *		PID		Process ID
 *		CALL		Tcl command or procedure name
 *
 * LEGEND:
 *		->		procedure entry
 *		<-		procedure return
 *		 >		command entry
 *		 <		command return
 *
 * WARNING: Watch the first column carefully, it prints the CPU-id. If it
 * changes, then it is very likely that the output has been shuffled.
 *
 * COPYRIGHT: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 09-Sep-2007	Brendan Gregg	Created this.
 */

#pragma D option quiet
#pragma D option switchrate=10

self int depth;

dtrace:::BEGIN
{
	printf("%3s %6s %-16s -- %s\n", "C", "PID", "TIME(us)", "CALL");
}

tcl*:::proc-entry
{
	printf("%3d %6d %-16d %*s-> %s\n", cpu, pid, timestamp / 1000,
	    self->depth * 2, "", copyinstr(arg0));
	self->depth++;
}

tcl*:::proc-return
{
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %6d %-16d %*s<- %s\n", cpu, pid, timestamp / 1000,
	    self->depth * 2, "", copyinstr(arg0));
}

tcl*:::cmd-entry
{
	printf("%3d %6d %-16d %*s > %s\n", cpu, pid, timestamp / 1000,
	    self->depth * 2, "", copyinstr(arg0));
	self->depth++;
}

tcl*:::cmd-return
{
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %6d %-16d %*s < %s\n", cpu, pid, timestamp / 1000,
	    self->depth * 2, "", copyinstr(arg0));
}
