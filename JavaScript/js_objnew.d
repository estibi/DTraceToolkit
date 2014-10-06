#!/usr/sbin/dtrace -Zs
/*
 * js_objnew.d - count JavaScript object creation using DTrace.
 *               Written for the JavaScript DTrace provider.
 *
 * $Id: js_objnew.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces JavaScript activity from all browsers running on the system
 * with JavaScript provider support.
 *
 * USAGE: js_objnew.d	 	# hit Ctrl-C to end
 *
 * FIELDS:
 *		FILE		Filename of the JavaScript program
 *		CLASS		Class of new object
 *		COUNT		Number of object creations during tracing
 *
 * Filename and class names are printed if available.
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

javascript*:::object-create-done
{
	@objs[basename(copyinstr(arg0)), copyinstr(arg1)] = count();
}

dtrace:::END
{
	printf(" %-24s %-36s %8s\n", "FILE", "CLASS", "COUNT");
	printa(" %-24.24s %-36s %@8d\n", @objs);
}
