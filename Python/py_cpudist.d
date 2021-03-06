#!/usr/sbin/dtrace -Zs
/*
 * py_cpudist.d - measure Python on-CPU times for functions.
 *                Written for the Python DTrace provider.
 *
 * $Id: py_cpudist.d 28 2007-09-13 10:49:37Z brendan $
 *
 * This traces Python activity from all programs running on the system with
 * Python provider support.
 *
 * USAGE: py_cpudist.d 		# hit Ctrl-C to end
 *
 * This script prints distribution plots of elapsed time for Python
 * operations. Use py_cputime.d for summary reports.
 *
 * FIELDS:
 *		1		Filename of the Python program
 *		2		Type of call (func)
 *		3		Name of call
 *
 * Filename and function names are printed if available.
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

python*:::function-entry
{
	self->depth++;
	self->exclude[self->depth] = 0;
	self->function[self->depth] = vtimestamp;
}

python*:::function-return
/self->function[self->depth]/
{
	this->oncpu_incl = vtimestamp - self->function[self->depth];
	this->oncpu_excl = this->oncpu_incl - self->exclude[self->depth];
	self->function[self->depth] = 0;
	self->exclude[self->depth] = 0;
	this->file = basename(copyinstr(arg0));
	this->name = copyinstr(arg1);

	@types_incl[this->file, "func", this->name] =
	    quantize(this->oncpu_incl / 1000);
	@types_excl[this->file, "func", this->name] =
	    quantize(this->oncpu_excl / 1000);

	self->depth--;
	self->exclude[self->depth] += this->oncpu_incl;
}

dtrace:::END
{
	printf("\nExclusive function on-CPU times (us),\n");
	printa("   %s, %s, %s %@d\n", @types_excl);

	printf("\nInclusive function on-CPU times (us),\n");
	printa("   %s, %s, %s %@d\n", @types_incl);
}
