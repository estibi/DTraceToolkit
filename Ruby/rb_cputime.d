#!/usr/sbin/dtrace -Zs
/*
 * rb_cputime.d - measure Ruby on-CPU times for types of operation.
 *                Written for the Ruby DTrace provider.
 *
 * $Id: rb_cputime.d 49 2007-09-17 12:03:20Z brendan $
 *
 * This traces Ruby activity from all programs running on the system with
 * Ruby provider support.
 *
 * USAGE: rb_cputime.d 		# hit Ctrl-C to end
 *
 * FIELDS:
 *		FILE		Filename of the Ruby program
 *		TYPE		Type of call (method/obj-new/gc/total)
 *		NAME		Name of call
 *		TOTAL		Total on-CPU time for calls (us)
 *
 * Filename and method names are printed if available.
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

ruby*:::function-entry
{
	self->depth++;
	self->exclude[self->depth] = 0;
	self->function[self->depth] = vtimestamp;
}

ruby*:::function-return
/self->function[self->depth]/
{
	this->oncpu_incl = vtimestamp - self->function[self->depth];
	this->oncpu_excl = this->oncpu_incl - self->exclude[self->depth];
	self->function[self->depth] = 0;
	self->exclude[self->depth] = 0;
	this->file = basename(copyinstr(arg2));
	this->name = strjoin(strjoin(copyinstr(arg0), "::"), copyinstr(arg1));

	@num[this->file, "func", this->name] = count();
	@num["-", "total", "-"] = count();
	@types_incl[this->file, "func", this->name] = sum(this->oncpu_incl);
	@types_excl[this->file, "func", this->name] = sum(this->oncpu_excl);
	@types_excl["-", "total", "-"] = sum(this->oncpu_excl);

	self->depth--;
	self->exclude[self->depth] += this->oncpu_incl;
}

ruby*:::object-create-start
{
	self->object = vtimestamp;
}

ruby*:::object-create-done
/self->object/
{
	this->oncpu = vtimestamp - self->object;
	self->object = 0;
	this->file = basename(copyinstr(arg1));
	this->file = this->file != NULL ? this->file : ".";
	this->name = copyinstr(arg0);

	@num[this->file, "obj-new", this->name] = count();
	@types[this->file, "obj-new", this->name] = sum(this->oncpu);

	self->exclude[self->depth] += this->oncpu;
}

ruby*:::gc-begin
{
	self->gc = vtimestamp;
}

ruby*:::gc-end
/self->gc/
{
	this->oncpu = vtimestamp - self->gc;
	self->gc = 0;
	@num[".", "gc", "-"] = count();
	@types[".", "gc", "-"] = sum(this->oncpu);
	self->exclude[self->depth] += this->oncpu;
}

dtrace:::END
{
	printf("\nCount,\n");
	printf("   %-20s %-10s %-32s %8s\n", "FILE", "TYPE", "NAME", "COUNT");
	printa("   %-20s %-10s %-32s %@8d\n", @num);

	normalize(@types, 1000);
	printf("\nElapsed times (us),\n");
	printf("   %-20s %-10s %-32s %8s\n", "FILE", "TYPE", "NAME", "TOTAL");
	printa("   %-20s %-10s %-32s %@8d\n", @types);

	normalize(@types_excl, 1000);
	printf("\nExclusive function on-CPU times (us),\n");
	printf("   %-20s %-10s %-32s %8s\n", "FILE", "TYPE", "NAME", "TOTAL");
	printa("   %-20s %-10s %-32s %@8d\n", @types_excl);

	normalize(@types_incl, 1000);
	printf("\nInclusive function on-CPU times (us),\n");
	printf("   %-20s %-10s %-32s %8s\n", "FILE", "TYPE", "NAME", "TOTAL");
	printa("   %-20s %-10s %-32s %@8d\n", @types_incl);
}
