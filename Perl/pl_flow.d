#!/usr/sbin/dtrace -Zs
/*
 * pl_flow.d - snoop Perl execution showing subroutine flow.
 *             Written for the Solaris Perl DTrace provider.
 *
 * $Id: pl_flow.d 41 2007-09-17 02:20:10Z brendan $
 *
 * This traces Perl activity from all Perl programs on the system
 * running with Perl provider support.
 *
 * USAGE: pl_flow.d			# hit Ctrl-C to end
 *
 * This watches Perl subroutine entries and returns, and indents child
 * subroutine calls.
 *
 * FIELDS:
 *		C		CPU-id
 *		TIME(us)	Time since boot, us
 *		FILE		Filename that this subroutine belongs to
 *		SUB		Subroutine name
 *
 * LEGEND:
 *		->		subroutine entry
 *		<-		subroutine return
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
	printf("%3s %-16s %-16s -- %s\n", "C", "TIME(us)", "FILE", "SUB");
}

perl*:::sub-entry
{
	printf("%3d %-16d %-16s %*s-> %s\n", cpu, timestamp / 1000, 
	    basename(copyinstr(arg1)), self->depth * 2, "", copyinstr(arg0));
	self->depth++;
}

perl*:::sub-return
{
	self->depth -= self->depth > 0 ? 1 : 0;
	printf("%3d %-16d %-16s %*s<- %s\n", cpu, timestamp / 1000,
	    basename(copyinstr(arg1)), self->depth * 2, "", copyinstr(arg0));
}
