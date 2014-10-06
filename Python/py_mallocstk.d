#!/usr/sbin/dtrace -Zs
/*
 * py_mallocstk.d - Python libc malloc analysis with full stack traces.
 *                  Written for the Python DTrace provider.
 *
 * $Id: py_mallocstk.d 19 2007-09-12 07:47:59Z brendan $
 *
 * USAGE: py_mallocstk.d { -p PID | -c cmd }	# hit Ctrl-C to end
 *
 * COPYRIGHT: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 09-Sep-2007	Brendan Gregg	Created this.
 */

#pragma D option quiet

/* tune as desired, */
#pragma D option jstackframes=64
#pragma D option jstackstrsize=1024

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

pid$target:libc:malloc:entry
{
	@mallocs[jstack()] = quantize(arg0);
}

dtrace:::END
{
	printf("\nPython malloc byte distributions by stack trace,\n\n");
	printa(@mallocs);
}
