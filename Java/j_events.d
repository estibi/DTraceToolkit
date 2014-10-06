#!/usr/sbin/dtrace -Zs
/*
 * j_events.d - count Java events using DTrace.
 *              Written for the Java hotspot DTrace provider.
 *
 * $Id: j_events.d 19 2007-09-12 07:47:59Z brendan $
 *
 * This traces activity from all Java processes on the system with hotspot
 * provider support (1.6.0). Some events such as method calls are only
 * visible when using the flag "+ExtendedDTraceProbes". eg,
 * java -XX:+ExtendedDTraceProbes classfile
 *
 * USAGE: j_events.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		PID		Process ID
 *		EVENT		Event name (DTrace probe name)
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

/* this matches both hotspot and hotspot_jni providers */
hotspot*:::
{
	@calls[pid, probename] = count();
}

dtrace:::END
{
	printf(" %6s  %-36s %8s\n", "PID", "EVENT", "COUNT");
	printa(" %6d  %-36s %@8d\n", @calls);
}
