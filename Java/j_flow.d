#!/usr/sbin/dtrace -Zs
/*
 * j_flow.d - snoop Java execution showing method flow using DTrace.
 *            Written for the Java hotspot DTrace provider.
 *
 * $Id: j_flow.d 38 2007-09-16 08:17:41Z brendan $
 *
 * This traces activity from all Java processes on the system with hotspot
 * provider support (1.6.0) and the flag "+ExtendedDTraceProbes". eg,
 * java -XX:+ExtendedDTraceProbes classfile
 *
 * USAGE: j_flow.d		# hit Ctrl-C to end
 *
 * This watches Java method entries and returns, and indents child
 * method calls.
 *
 * FIELDS:
 *		C		CPU-id
 *		TIME(us)	Time since boot, us
 *		PID		Process ID
 *		CLASS.METHOD	Java class and method name
 *
 * LEGEND:
 *		->		method entry
 *		<-		method return
 *
 * WARNING: Watch the first column carefully, it prints the CPU-id. If it
 * changes, then it is very likely that the output has been shuffled.
 * Changes in TID will appear to shuffle output, as we change from one thread
 * depth to the next. See Docs/Notes/ALLjavaflow.txt for additional notes.
 *
 * COPYRIGHT: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 09-Sep-2007	Brendan Gregg	Created this.
 */

/* increasing bufsize can reduce drops */
#pragma D option bufsize=16m
#pragma D option quiet
#pragma D option switchrate=10

self int depth[int];

dtrace:::BEGIN
{
	printf("%3s %6s %-16s -- %s\n", "C", "PID", "TIME(us)", "CLASS.METHOD");
}

hotspot*:::method-entry
{
	this->class = (char *)copyin(arg1, arg2 + 1);
	this->class[arg2] = '\0';
	this->method = (char *)copyin(arg3, arg4 + 1);
	this->method[arg4] = '\0';

	printf("%3d %6d %-16d %*s-> %s.%s\n", cpu, pid, timestamp / 1000,
	    self->depth[arg0] * 2, "", stringof(this->class),
	    stringof(this->method));
	self->depth[arg0]++;
}

hotspot*:::method-return
{
	this->class = (char *)copyin(arg1, arg2 + 1);
	this->class[arg2] = '\0';
	this->method = (char *)copyin(arg3, arg4 + 1);
	this->method[arg4] = '\0';

	self->depth[arg0] -= self->depth[arg0] > 0 ? 1 : 0;
	printf("%3d %6d %-16d %*s<- %s.%s\n", cpu, pid, timestamp / 1000,
	    self->depth[arg0] * 2, "", stringof(this->class),
	    stringof(this->method));
}
