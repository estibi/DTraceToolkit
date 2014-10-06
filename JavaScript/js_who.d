#!/usr/sbin/dtrace -Zs
/*
 * js_who.d - trace JavaScript function execution by process using DTrace.
 *            Written for the JavaScript DTrace provider.
 *
 * $Id: js_who.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces JavaScript activity from all browsers on the system that are
 * running with JavaScript provider support.
 *
 * USAGE: js_who.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		PID		Process ID of JavaScript
 *		UID		User ID of the owner
 *		FUNCS		Number of function calls
 *		FILE		Pathname of the JavaScript program
 *
 * Filenames are printed if available.
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

javascript*:::function-entry
{
	@funcs[pid, uid, copyinstr(arg0)] = count();
}

dtrace:::END
{
	printf("   %6s %6s %6s %s\n", "PID", "UID", "FUNCS", "FILE");
	printa("   %6d %6d %@6d %s\n", @funcs);
}
