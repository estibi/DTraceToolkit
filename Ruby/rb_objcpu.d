#!/usr/sbin/dtrace -Zs
/*
 * rb_objcpu.d - measure Ruby object creation on-CPU time using DTrace.
 *               Written for the Ruby DTrace provider.
 *
 * $Id: rb_objcpu.d 20 2007-09-12 09:28:22Z brendan $
 *
 * This traces Ruby activity from all programs running on the system with
 * Ruby provider support.
 *
 * USAGE: rb_objcpu.d	 	# hit Ctrl-C to end
 *
 * Class names are printed if available.
 *
 * COPYRIGHT: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 09-Sep-2007	Brendan Gregg	Created this.
 */

#pragma D option quiet

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
}

ruby*:::object-create-start
{
	self->vstart = vtimestamp;
}

ruby*:::object-create-done
/self->vstart/
{
	this->oncpu = vtimestamp - self->vstart;
	@total = sum(this->oncpu);
	@dist[copyinstr(arg0)] = quantize(this->oncpu / 1000);
	self->vstart = 0;
}

dtrace:::END
{
	normalize(@total, 1000000);
	printa("Total object creation on-CPU time (ms): %@d\n\n", @total);
	printf("Object creation on-CPU time distributions (us),\n");
	printa(@dist);
}
