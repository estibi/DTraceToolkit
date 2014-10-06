#!/usr/sbin/dtrace -Zs
/*
 * rb_funccalls.d - count Ruby function (method) calls using DTrace.
 *                  Written for the Ruby DTrace provider.
 *
 * $Id: rb_funccalls.d 20 2007-09-12 09:28:22Z brendan $
 *
 * This traces activity from all Ruby programs on the system that are
 * running with Ruby provider support.
 *
 * USAGE: rb_funccalls.d 	# hit Ctrl-C to end
 *
 * FIELDS:
 *		FILE		Filename of the Ruby program
 *		METHOD		Method name
 *		COUNT		Number of calls during sample
 *
 * Filename and method names are printed if available.
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

ruby*:::function-entry
{
        @funcs[basename(copyinstr(arg2)), copyinstr(arg0), copyinstr(arg1)] =
	    count();
}

dtrace:::END
{
        printf(" %-32.32s %-16s %-16s %8s\n", "FILE", "CLASS", "METHOD",
	    "CALLS");
        printa(" %-32.32s %-16s %-16s %@8d\n", @funcs);
}