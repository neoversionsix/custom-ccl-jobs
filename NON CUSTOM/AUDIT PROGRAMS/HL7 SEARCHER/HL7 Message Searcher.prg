drop program wh_hl7_search go
create program wh_hl7_search

prompt
	"Output to File/Printer/MINE" = "MINE"                              ;* Enter or select the printer or file name to send this r
	, "Messages sent after...." = "SYSDATE"
	, "and messages sent before...." = "SYSDATE"
	, "Patient URN" = "1613161"
	, "Is the message going in or out of Oracle (Cerner)?" = "(2001)"
	, "prompt1" = "MSH|^~\&|CERNERLAB|*"
	, "Additional Search String (Optional)" = ""

with OUTDEV, START_DATE_TM, END_DATE_TM, URN, MESSAGE_DIRECTION,
	MESSAGE_INTERFACE, SEARCH_STRING

DECLARE URN_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE SEARCH_STRING_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE MESSAGE_DIRECTION_VAR = VC WITH NOCONSTANT(" "),PROTECT

SET URN_VAR = $URN
IF (URN_VAR = "")
	SET URN_VAR = "*"
	ELSE
	SET URN_VAR = CONCAT("*|", URN_VAR, "^*")
ENDIF

SET SEARCH_STRING_VAR = $SEARCH_STRING
IF (SEARCH_STRING_VAR = "")
	SET SEARCH_STRING_VAR = "*"
	ELSE
	SET SEARCH_STRING_VAR = CONCAT("*", SEARCH_STRING_VAR, "*")
ENDIF

SET MESSAGE_DIRECTION_VAR = $MESSAGE_DIRECTION
IF (MESSAGE_DIRECTION_VAR = "0")
	SET MESSAGE_DIRECTION_VAR = "*"
	ELSE
	SET MESSAGE_DIRECTION_VAR = CONCAT("*", MESSAGE_DIRECTION_VAR, "*")
ENDIF


SELECT INTO $OUTDEV
	CREATED = O_T.CREATE_DT_TM "DD-MMM-YYYY HH:MM:SS"
	, GOING =
		IF (O_T.EVENTID = "1001") "INBOUND"
		ELSEIF (O_T.EVENTID = "2001") "OUTBOUND"
		ELSE O_T.EVENTID
		ENDIF
	, HL7 = REPLACE(O_T.MSG_TEXT,char(13), " ", 0)


FROM
	OEN_TXLOG   O_T

WHERE
	/* TIME FROM NOW FILTER */
	O_T.CREATE_DT_TM BETWEEN CNVTDATETIME($START_DATE_TM) AND CNVTDATETIME($END_DATE_TM)
	/* Patients URN */
	AND O_T.MSG_TEXT = PATSTRING(URN_VAR)
	/* INTERFACE */
    AND O_T.MSG_TEXT = PATSTRING($MESSAGE_INTERFACE)
	/* DIRECTION */
	AND O_T.EVENTID = PATSTRING(MESSAGE_DIRECTION_VAR)
    /* ADDITIONAL STRING TO FILTER */
    AND O_T.MSG_TEXT = PATSTRING(SEARCH_STRING_VAR)


WITH FORMAT, SEPERATOR = " ", TIME = 20, MAXREC = 1000


/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

end
go
