drop program wh_bigfile_out go
create program wh_bigfile_out

prompt
	"Output to File/Printer/MINE" = "change_this_filename.csv"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV

SELECT DISTINCT INTO "CUST_SCRIPT:change_this_filename.csv"
	PR.ACTIVE_IND
	, PR.NAME_FULL_FORMATTED

FROM PRSNL PR

WHERE
	PR.PERSON_ID = REQINFO->UPDT_ID

WITH
    TIME = 3600 ; 1hr time limit, to somewhat help prevent overly large files
	, PCFORMAT (^"^, ^,^ , 1)
    , FORMAT = STREAM
	, FORMAT

end
go