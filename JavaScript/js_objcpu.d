#!/usr/sbin/dtrace -Zs
/*
 * js_objcpu.d - measure JavaScript object creation on-CPU time using DTrace.
 *               Written for the JavaScript DTrace provider.
 *
 * $Id: js_objcpu.d 63 2007-10-04 04:34:38Z brendan $
 *
 * This traces JavaScript activity from all browsers running on the system
 * with JavaScript provider support.
 *
 * USAGE: js_objcpu.d	 	# hit Ctrl-C to end
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

javascript*:::object-create-start
{
	self->vstart = vtimestamp;
}

javascript*:::object-create-done
/self->vstart/
{
	this->oncpu = vtimestamp - self->vstart;
	@total = sum(this->oncpu);
	@dist[copyinstr(arg1)] = quantize(this->oncpu / 1000);
	self->vstart = 0;
}

dtrace:::END
{
	normalize(@total, 1000000);
	printa("Total object creation on-CPU time (ms): %@d\n\n", @total);
	printf("Object creation on-CPU time distributions (us),\n");
	printa(@dist);
}
