#!/usr/sbin/dtrace -Zs
/*
 * j_thread.d - snoop Java thread execution using DTrace.
                Written for the Java hotspot DTrace provider.
 *
 * $Id: j_thread.d 19 2007-09-12 07:47:59Z brendan $
 *
 * This traces activity from all Java processes on the system with hotspot
 * provider support (1.6.0).
 *
 * USAGE: j_thread.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		TIME		Time string
 *		PID		Process ID
 *		TID		Thread ID
 *		THREAD		Thread name
 *
 * LEGEND:
 *		=>		thread start
 *		<=		thread end
 *
 * COPYRIGHT: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 09-Sep-2007	Brendan Gregg	Created this.
 */

#pragma D option quiet
#pragma D option switchrate=10

dtrace:::BEGIN
{
	printf("%-20s  %6s/%-5s -- %s\n", "TIME", "PID", "TID", "THREAD");
}

hotspot*:::thread-start
{
	this->thread = (char *)copyin(arg0, arg1 + 1);
	this->thread[arg1] = '\0';
	printf("%-20Y  %6d/%-5d => %s\n", walltimestamp, pid, tid,
	    stringof(this->thread));
}

hotspot*:::thread-stop
{
	this->thread = (char *)copyin(arg0, arg1 + 1);
	this->thread[arg1] = '\0';
	printf("%-20Y  %6d/%-5d <= %s\n", walltimestamp, pid, tid,
	    stringof(this->thread));
}
