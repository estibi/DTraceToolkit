#!/usr/sbin/dtrace -Zs
/*
 * j_objnew.d - report Java object allocation using DTrace.
 *              Written for the Java hotspot DTrace provider.
 *
 * $Id: j_objnew.d 19 2007-09-12 07:47:59Z brendan $
 *
 * This traces activity from all Java processes on the system with hotspot
 * provider support (1.6.0) and the flag "+ExtendedDTraceProbes". eg,
 * java -XX:+ExtendedDTraceProbes classfile
 *
 * USAGE: j_objnew.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		PID		Process ID
 *		OBJS		Number of objects created
 *		CLASS.METHOD	Java class and method name
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

hotspot*:::object-alloc
{
	this->class = (char *)copyin(arg1, arg2 + 1);
	this->class[arg2] = '\0';
	@objs[pid, stringof(this->class)] = count();
	@dist[pid, stringof(this->class)] = quantize(arg3);
}

dtrace:::END
{
	printf("Java object allocation byte distributions by pid and class,\n");
	printa(@dist);

	printf("Java object allocation count by pid and class,\n\n");
	printf(" %6s %8s %s\n", "PID", "OBJS", "CLASS");
	printa(" %6d %8@d %s\n", @objs);
}
