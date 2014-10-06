#!/usr/sbin/dtrace -Zs
/*
 * js_flowtime.d - JavaScript function flow with delta times using DTrace.
 *                 Written for the JavaScript DTrace provider.
 *
 * $Id: js_flowtime.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces activity from all browsers on the system that are running
 * with JavaScript provider support.
 *
 * USAGE: js_flowtime.d 	# hit Ctrl-C to end
 *
 * FIELDS:
 *		C		CPU-id
 *		TIME(us)	Time since boot, us
 *		FILE		Filename that this function belongs to
 *		DELTA(us)	Elapsed time from previous line to this line
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
	printf("%3s %-16s %-18s %9s -- %s\n", "C", "TIME(us)", "FILE",
	    "DELTA(us)", "FUNC");
}

javascript*:::function-entry,
javascript*:::function-return
/self->last == 0/
{
	self->last = timestamp;
}

javascript*:::function-entry
{
	this->delta = (timestamp - self->last) / 1000;
	printf("%3d %-16d %-18s %9d %*s-> %s\n", cpu, timestamp / 1000, 
	    basename(copyinstr(arg0)), this->delta, self->depth * 2, "",
	    copyinstr(arg2));
	self->depth++;
	self->last = timestamp;
}

javascript*:::function-return
{
	this->delta = (timestamp - self->last) / 1000;
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %-16d %-18s %9d %*s<- %s\n", cpu, timestamp / 1000,
	    basename(copyinstr(arg0)), this->delta, self->depth * 2, "",
	    copyinstr(arg2));
	self->last = timestamp;
}
