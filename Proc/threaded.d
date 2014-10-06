#!/usr/sbin/dtrace -s
/*
 * threaded.d - sample multi-threaded CPU usage.
 *              Written using DTrace (Solaris 10 3/05).
 *
 * This measures thread IDs as a process runs across multiple CPUs.
 * It is a simple script that can help determine if a multi-threaded
 * application is effectively using it's threads, or if the threads have
 * serialised. See the example file in Docs/Examples/threaded_example.txt
 * for a demonstration.
 *
 * $Id: threaded.d 3 2007-08-01 10:50:08Z brendan $
 *
 * USAGE:	threaded.d
 *
 * FIELDS:
 *		PID		process ID
 *		CMD		process name
 *		value		thread ID
 *		count		number of samples
 *
 * SEE ALSO:	prstat -L
 *
 * COPYRIGHT: Copyright (c) 2005 Brendan Gregg.
 *

 *
 * Author: Brendan Gregg  [Sydney, Australia]
 *
 * 25-Jul-2005	Brendan Gregg	Created this.
 * 25-Jul-2005	   "      "	Last update.
 */

#pragma D option quiet

/*
 * Sample at 100 Hertz
 */
profile:::profile-100
/pid != 0/
{
	@sample[pid, execname] = lquantize(tid, 0, 128, 1);
}

/*
 * Print output every 1 second
 */
profile:::tick-1sec
{
	printf("%Y,\n", walltimestamp);
	printa("\n     PID: %-8d CMD: %s\n%@d", @sample);
	printf("\n");
	trunc(@sample);
}
