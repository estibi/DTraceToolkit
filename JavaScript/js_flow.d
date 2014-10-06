#!/usr/sbin/dtrace -Zs
/*
 * js_flow.d - snoop JavaScript execution showing function flow using DTrace.
 *             Written for the JavaScript DTrace provider.
 *
 * $Id: js_flow.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces activity from all browsers on the system that are running
 * with JavaScript provider support.
 *
 * USAGE: js_flow.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		C		CPU-id
 *		TIME(us)	Time since boot, us
 *		FILE		Filename that this function belongs to
 *		FUNC		Function name
 *
 * LEGEND:
 *		->		function entry
 *		<-		function return
 *
 * Filename and function names are printed if available.
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
	printf("%3s %-16s %-22s -- %s\n", "C", "TIME(us)", "FILE", "FUNC");
}

javascript*:::function-entry
{
	printf("%3d %-16d %-22s %*s-> %s\n", cpu, timestamp / 1000,
	    basename(copyinstr(arg0)), self->depth * 2, "", copyinstr(arg2));
	self->depth++;
}

javascript*:::function-return
{
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %-16d %-22s %*s<- %s\n", cpu, timestamp / 1000,
	    basename(copyinstr(arg0)), self->depth * 2, "", copyinstr(arg2));
}
