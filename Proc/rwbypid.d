#!/usr/sbin/dtrace -s
/*
 * rwbypid.d - read/write calls by PID.
 *             Written using DTrace (Solaris 10 3/05)
 *
 * This script tracks the number of reads and writes at the syscall level
 * by processes, printing the totals in a report. This matches reads
 * and writes whether they succeed or not.
 *
 * $Id: rwbypid.d 3 2007-08-01 10:50:08Z brendan $
 *
 * USAGE:	rwbypid.d			# hit Ctrl-C to end sample
 *
 * FIELDS:
 *		PID		process ID
 *		CMD		process name
 *		DIR		Read or Write
 *		COUNT		total calls
 *
 * COPYRIGHT: Copyright (c) 2005, 2006 Brendan Gregg.
 *

 *
 * 28-Jun-2005	Brendan Gregg	Created this.
 * 20-Apr-2006	   "      "	Last update.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

syscall::*read*:entry
{
	@calls[pid, execname, "R"] = sum(arg0);
}

syscall::*write*:entry
{
	@calls[pid, execname, "W"] = sum(arg0);
}

dtrace:::END
{
	printf("%6s %-24s %4s %8s\n", "PID", "CMD", "DIR", "COUNT");
	printa("%6d %-24s %4s %@8d\n", @calls);
}
