#!/usr/sbin/dtrace -s
/*
 * pgpginbypid.d - pages paged in by PID.
 *                 Writen using DTrace (Solaris 10 3/05).
 *
 * $Id: pgpginbypid.d 3 2007-08-01 10:50:08Z brendan $
 *
 * USAGE:	pgpginbypid.d		# hit Ctrl-C to end sample
 *
 * FIELDS:
 *		PID		process ID
 * 		CMD		process name
 *		PAGES		number of pages paged in
 *
 * This is based on a script from DExplorer.
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

vminfo:::pgpgin
{
	@pg[pid, execname] = sum(arg0);
}

dtrace:::END
{
	printf("%6s %-16s %16s\n", "PID", "CMD", "PAGES");
	printa("%6d %-16s %@16d\n", @pg);
}
