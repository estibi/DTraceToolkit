#!/usr/sbin/dtrace -Zs
/*
 * py_funccalls.d - measure Python function calls using DTrace.
 *                  Written for the Python DTrace provider.
 *
 * $Id: py_funccalls.d 25 2007-09-12 09:51:58Z brendan $
 *
 * This traces Python activity from all running programs on the system
 * which support the Python DTrace provider.
 *
 * USAGE: py_funccalls.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *              FILE		Filename that contained the function
 *		FUNC		Python function name
 *		CALLS		Function calls during this sample
 *
 * Filename and function names are printed if available.
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

python*:::function-entry
{
	@funcs[basename(copyinstr(arg0)), copyinstr(arg1)] = count();
}

dtrace:::END
{
	printf(" %-32s %-32s %8s\n", "FILE", "FUNC", "CALLS");
	printa(" %-32s %-32s %@8d\n", @funcs);
}
