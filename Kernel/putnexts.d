#!/usr/sbin/dtrace -s
/*
 * putnexts.d - stream putnext() tracing with stacks. Solaris, DTrace.
 *
 * This shows who is calling putnext() to who, by listing the destination
 * queue and the calling stack, by frequency count. This is especially useful
 * for understanding streams based frameworks, such as areas of the Solaris
 * TCP/IP stack.
 *
 * $Id: putnexts.d 14 2007-09-11 08:03:35Z brendan $
 *
 * USAGE:	putnext.d
 *
 * BASED ON: /usr/demo/dtrace/putnext.d
 *
 * PORTIONS: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 12-Jun-2005  Brendan Gregg   Created this.
 */

fbt::putnext:entry
{
	@[stringof(args[0]->q_qinfo->qi_minfo->mi_idname), stack(5)] = count();
}
