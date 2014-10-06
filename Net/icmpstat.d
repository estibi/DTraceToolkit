#!/usr/sbin/dtrace -s
/*
 * icmpstat.d - print ICMP statistics. Uses DTrace.
 *
 * This prints ICMP statistics every second, retrieved from the MIB provider.
 * This is a simple script to demonstrate the ability to trace ICMP events.
 *
 * $Id: icmpstat.d 3 2007-08-01 10:50:08Z brendan $
 *
 * USAGE:	icmpstat.d
 *
 * FIELDS:
 *		STATISTIC		ICMP statistic name
 *		VALUE			total of statistic during sample
 *
 * The above ICMP statistics are documented in the mib2_icmp struct
 * in the /usr/include/inet/mib2.h file; and also in the mib provider
 * chapter of the DTrace Guide, http://docs.sun.com/db/doc/817-6223.
 *
 * COPYRIGHT: Copyright (c) 2005 Brendan Gregg.
 *

 *
 * 25-Jul-2005	Brendan Gregg	Created this.
 * 25-Jul-2005	   "      "	Last update.
 */

#pragma D option quiet

/*
 * Save Data
 */
mib:::icmp*
{
	@icmp[probename] = sum(arg0);
}

/*
 * Print Output
 */
profile:::tick-1sec
{
	printf("%Y,\n\n", walltimestamp);
	printf("%32s %8s\n", "STATISTIC", "VALUE");
	printa("%32s %@8d\n", @icmp);
	printf("\n");

	trunc(@icmp);
}
