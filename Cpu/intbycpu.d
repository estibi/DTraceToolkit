#!/usr/sbin/dtrace -s
/*
 * intbycpu.d - interrupts by CPU.
 *              Written using DTrace (Solaris 10 3/05).
 *
 * $Id: intbycpu.d 3 2007-08-01 10:50:08Z brendan $
 *
 * USAGE:	intbycpu.d		# hit Ctrl-C to end sample
 *
 * FIELDS:
 *		CPU		CPU number
 *		INTERRUPTS	number of interrupts in sample
 *
 * This is based on a DTrace OneLiner from the DTraceToolkit.
 *
 * COPYRIGHT: Copyright (c) 2005, 2006 Brendan Gregg.
 *

 *
 * 15-May-2005	Brendan Gregg	Created this.
 * 20-Apr-2006	   "      "	Last update.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

sdt:::interrupt-start { @num[cpu] = count(); }

dtrace:::END
{
	printf("%-16s %16s\n", "CPU", "INTERRUPTS");
	printa("%-16d %@16d\n", @num);
}
