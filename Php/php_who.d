#!/usr/sbin/dtrace -Zs
/*
 * php_who.d - trace PHP function execution by process using DTrace.
 *             Written for the PHP DTrace provider.
 *
 * $Id: php_who.d 51 2007-09-24 00:55:23Z brendan $
 *
 * This traces PHP activity from all PHP programs on the system that are
 * running with PHP provider support.
 *
 * USAGE: php_who.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		PID		Process ID of PHP
 *		UID		User ID of the owner
 *		FUNCS		Number of function calls
 *		FILE		Pathname of the PHP program
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

php*:::function-entry
{
	@lines[pid, uid, copyinstr(arg1)] = count();
}

dtrace:::END
{
	printf("   %6s %6s %6s %s\n", "PID", "UID", "FUNCS", "FILE");
	printa("   %6d %6d %@6d %s\n", @lines);
}
