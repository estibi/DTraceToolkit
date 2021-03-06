#!/usr/sbin/dtrace -Zs
/*
 * sh_lines.d - trace Bourne shell line execution using DTrace.
 *              Written for the sh DTrace provider.
 *
 * $Id: sh_lines.d 25 2007-09-12 09:51:58Z brendan $
 *
 * This traces shell activity from all Bourne shells on the system that are
 * running with sh provider support.
 *
 * USAGE: sh_lines.d 	# hit Ctrl-C to end
 *
 * FIELDS:
 *		FILE		Filename of the shell or shellscript
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

sh*:::line
{
	@calls[basename(copyinstr(arg0)), arg1] = count();
}

dtrace:::END
{
	printf(" %32s:%-6s %10s\n", "FILE", "LINE", "COUNT");
	printa(" %32s:%-6d %@10d\n", @calls);
}
