#!/usr/sbin/dtrace -s
/*
 * vmbypid.d - print vminfo events by process. DTrace.
 *
 * $Id: vmbypid.d 8 2007-08-06 05:55:26Z brendan $
 *
 * USAGE:	vmbypid.d
 *
 * FIELDS:
 *		EXEC	Process name
 *		PID	Process ID
 * 		VM	Virtual Memory statistic (/usr/include/sys/sysinfo.h)
 *		VALUE	Value by which statistic was incremented
 *
 * The virtual memory statistics are documented in the cpu_vminfo struct
 * in the /usr/include/sys/sysinfo.h file; and also in the vminfo provider
 * chapter of the DTrace Guide, http://docs.sun.com/db/doc/817-6223.
 *
 * COPYRIGHT: Copyright (c) 2005 Brendan Gregg.
 *

 *
 * 14-May-2005	Brendan Gregg	Created this.
 * 20-Apr-2006	   "      "	Last update.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

vminfo:::
{
	@VM[execname, pid, probename] = sum(arg0);
}

dtrace:::END {
	printf("%16s %8s %22s %8s\n", "EXEC", "PID", "VM", "VALUE");
	printa("%16s %8d %22s %@8d\n", @VM);
}
