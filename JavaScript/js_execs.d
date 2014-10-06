#!/usr/sbin/dtrace -Zs
/*
 * js_execs.d - JavaScript execute snoop using DTrace.
 *              Written for the JavaScript DTrace provider.
 *
 * $Id: js_execs.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces activity from all browsers on the system that are
 * running with JavaScript provider support.
 *
 * USAGE: js_execs.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		TIME		Time of event
 *		FILE		Filename of the JavaScript program
 *		LINENO		Line number in filename
 *
 * Filename and function names are printed if available.
 *
 * COPYRIGHT: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 09-Sep-2007	Brendan Gregg	Created this.
 */

#pragma D option quiet
#pragma D option switchrate=10

dtrace:::BEGIN
{
	printf("%-20s  %32s:%s\n", "TIME", "FILE", "LINENO");
}

javascript*:::execute-start
{
	printf("%-20Y  %32s:%d\n", walltimestamp, basename(copyinstr(arg0)),
	    arg1);
}
