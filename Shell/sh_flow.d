#!/usr/sbin/dtrace -Zs
/*
 * sh_flow.d - snoop Bourne shell execution showing function flow using DTrace.
 *             Written for the sh DTrace provider.
 *
 * $Id: sh_flow.d 41 2007-09-17 02:20:10Z brendan $
 *
 * This traces shell activity from all Bourne shells on the system that are
 * running with sh provider support.
 *
 * USAGE: sh_flow.d			# hit Ctrl-C to end
 *
 * This watches shell function entries and returns, and indents child
 * function calls. Shell builtins are also printed.
 *
 * FIELDS:
 *		C		CPU-id
 *		TIME(us)	Time since boot, us
 *		FILE		Filename that this function belongs to
 *		NAME		Shell function, builtin or command name
 *
 * LEGEND:
 *		->		function entry
 *		<-		function return
 *		>		builtin
 *		|		external command
 *
 * WARNING: Watch the first column carefully, it prints the CPU-id. If it
 * changes, then it is very likely that the output has been shuffled.
 *
 * COPYRIGHT: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 09-Sep-2007	Brendan Gregg	Created this.
 */

#pragma D option quiet
#pragma D option switchrate=10

self int depth;

dtrace:::BEGIN
{
	self->depth = 0;
	printf("%3s %-16s %-16s -- %s\n", "C", "TIME(us)", "FILE", "NAME");
}

sh*:::function-entry
{
	printf("%3d %-16d %-16s %*s-> %s\n", cpu, timestamp / 1000, 
	    basename(copyinstr(arg0)), self->depth * 2, "", copyinstr(arg1));
	self->depth++;
}

sh*:::function-return
{
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %-16d %-16s %*s<- %s\n", cpu, timestamp / 1000,
	    basename(copyinstr(arg0)), self->depth * 2, "", copyinstr(arg1));
}

sh*:::builtin-entry
{
	printf("%3d %-16d %-16s %*s> %s\n", cpu, timestamp / 1000, 
	    basename(copyinstr(arg0)), self->depth * 2, "", copyinstr(arg1));
}

sh*:::command-entry
{
	printf("%3d %-16d %-16s %*s| %s\n", cpu, timestamp / 1000, 
	    basename(copyinstr(arg0)), self->depth * 2, "", copyinstr(arg1));
}
