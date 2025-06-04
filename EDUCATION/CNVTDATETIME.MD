CNVTDATETIME(rdb_dt_tm)
CNVTDATETIME(character_date [character_time])
CNVTDATETIME(internal_date, internal_time)

EXAMPLES:
CNVTDATETIME(CURDATE, CURTIME3)
CNVTDATETIME("07-OCT-1992 12:00:00")

The CNVTDATETIME() function converts date and time expressions to a Binary System Datetime value. A Binary System datetime is a value that represents a specific time on a specific date. A Binary System datetime has a DQ8 data type.

Beginning with Discern Explorer version 8.7.2, CNVTDATETIME() ignores fractional seconds.

Beginning with Discern Explorer versions 8.14.3 and 9.02.3, a DQ8 value passed to CNVTDATETIME() is returned as is.

In Discern Explorer versions 9.03.0 - 9.03.4 and 8.15.0 - 8.15.4, CNVTDATETIME() may incorrectly return a UTC datetime value in a non-UTC enabled environment when passed an internal_date and internal_time or sysdate after CNVTLOOKAHEAD(), CNVTLOOKBEHIND(), or DATETIMEADD() has been executed when SET TRACE DTTMCALC is enabled on a Linux system. This issue is resolved in Discern Explorer versions 9.03.5 and 8.15.5.