/*
 * time.h - DTrace Time include file.
 *
 * $Id: time.h 36 2007-09-15 06:51:18Z brendan $
 *
 * COPYRIGHT: Copyright (c) 2007 Brendan Gregg.
 *

 *
 * 16-Sep-2007	Brendan Gregg	Created this.
 */

/*
 * TIME_HHMMSS - Returns GMT time as a "HH:MM:SS" string.
 *
 * eg, "21:53:07"
 */
#define TIME_HHMMSS							\
	strjoin(strjoin(strjoin(strjoin(strjoin(			\
	(((walltimestamp / 1000000000) % 86400) / 3600) < 10 ? "0" : "",\
	lltostr(((walltimestamp / 1000000000) % 86400) / 3600)), ":"),	\
	strjoin((((walltimestamp / 1000000000) % 3600) / 60) < 10 ?	\
	"0" : "", lltostr(((walltimestamp / 1000000000) % 3600) / 60))),\
	":"), strjoin(((walltimestamp / 1000000000) % 60) < 10 ?	\
	"0" : "", lltostr((walltimestamp / 1000000000) % 60)))

