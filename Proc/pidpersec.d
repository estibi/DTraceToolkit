#!/usr/sbin/dtrace -s
/*
 * pidpersec.d - print new PIDs per sec.
 *               Written using DTrace (Solaris 10 3/05)
 *
 * This script prints the number of new processes created per second.
 *
 * $Id: pidpersec.d 3 2007-08-01 10:50:08Z brendan $
 *
 * USAGE: pidpersec.d
 *
 * FIELDS:
 *
 *          TIME        Time, as a string
 *          LASTPID     Last PID created
 *          PID/s       Number of processes created per second
 *
 * SEE ALSO: execsnoop
 *
 * COPYRIGHT: Copyright (c) 2005 Brendan Gregg.
 *

 *
 * 09-Jun-2005  Brendan Gregg   Created this.
 * 09-Jun-2005	   "      "	Last update.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("%-22s %8s %6s\n", "TIME", "LASTPID", "PID/s");
	pids = 0;
}

proc:::exec-success
{
	pids++;
}

profile:::tick-1sec
{
	printf("%-22Y %8d %6d\n", walltimestamp, `mpid, pids);
	pids = 0;
}
