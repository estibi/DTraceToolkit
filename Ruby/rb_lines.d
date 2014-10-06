#!/usr/sbin/dtrace -Zs
/*
 * rb_lines.d - trace Ruby line execution by process using DTrace.
 *              Written for the Ruby DTrace provider.
 *
 * $Id: rb_lines.d 20 2007-09-12 09:28:22Z brendan $
 *
 * This traces Ruby activity from all Ruby programs on the system that are
 * running with Ruby provider support.
 *
 * USAGE: rb_who.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		FILE		Filename of the Ruby program
 *		LINE		Line number
 *		COUNT		Number of times a line was executed
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

ruby*:::line
{
	@calls[basename(copyinstr(arg0)), arg1] = count();
}

dtrace:::END
{
	printf(" %32s:%-6s %10s\n", "FILE", "LINE", "COUNT");
	printa(" %32s:%-6d %@10d\n", @calls);
}
