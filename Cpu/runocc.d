#!/usr/sbin/dtrace -s
/*
 * runocc.d - run queue occupancy by CPU.
 *            Written using DTrace (Solaris 10 3/05).
 *
 * This prints the dispatcher run queue occupancy by CPU each second.
 * A consistant run queue occupancy is a sign of CPU saturation.
 *
 * The value is similar to that seen in "sar -q", however this is
 * calculated in a more accurate manner - sampling at 1000 Hertz.
 *
 * $Id: runocc.d 3 2007-08-01 10:50:08Z brendan $
 *
 * USAGE:	runocc.d
 *
 * FIELDS:
 *		CPU		cpu ID
 *		%runocc		% run queue occupancy, sampled at 1000 Hertz
 *
 * SEE ALSO: Solaris Internals 2nd Ed, vol 2, CPU chapter.
 *
 * COPYRIGHT: Copyright (c) 2006 Brendan Gregg.
 *

 *
 * 02-Mar-2006  Brendan Gregg   Created this.
 * 24-Apr-2006	   "      "	Last update.
 */

#pragma D option quiet

profile-1000hz
/curthread->t_cpu->cpu_disp->disp_nrunnable/
{
	@qocc[cpu] = count();
}

profile:::tick-1sec
{
	normalize(@qocc, 10);
	printf("\n%8s %8s\n", "CPU", "%runocc");
	printa("%8d %@8d\n", @qocc);
	clear(@qocc);
}
