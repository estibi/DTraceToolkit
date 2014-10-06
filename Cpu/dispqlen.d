#!/usr/sbin/dtrace -s
/*
 * dispqlen.d - dispatcher queue length by CPU.
 *              Written using DTrace (Solaris 10 3/05).
 *
 * $Id: dispqlen.d 3 2007-08-01 10:50:08Z brendan $
 *
 * USAGE:	dispqlen.d		# hit Ctrl-C to end sample
 *
 * NOTES: The dispatcher queue length is an indication of CPU saturation.
 * It is not an indicatior of utilisation - the CPUs may or may not be
 * utilised when the dispatcher queue reports a length of zero.
 *
 * SEE ALSO:    uptime(1M)
 *
 * COPYRIGHT: Copyright (c) 2005 Brendan Gregg.
 *

 *
 * 27-Jun-2005  Brendan Gregg   Created this.
 * 14-Feb-2006	   "      "	Last update.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Sampling... Hit Ctrl-C to end.\n");
}

profile:::profile-1000hz
{
	@queue[cpu] =
	    lquantize(curthread->t_cpu->cpu_disp->disp_nrunnable, 0, 64, 1);
}

dtrace:::END
{
	printa(" CPU %d%@d\n", @queue);
}
