/*
Programmer: Jason Whittle
*/

drop program wh_testing_query_88 go
create program wh_testing_query_88

prompt
	"Output to File/Printer/MINE" = "MINE"

with OUTDEV




; Query from Order_Catalog TABLE
    SELECT INTO $OUTDEV
		lt.long_text




    FROM

	pct_ipass   pi
	, sticky_note   sn
	, long_text   lt
	, LONG_BLOB   l

	plan pi
	where
	pi.ENCNTR_ID IN
   (
       SELECT E_A.ENCNTR_ID
       FROM ENCNTR_ALIAS E_A
       WHERE E_A.ALIAS = "30313959" ; EDIT THIS!
           AND E_A.ENCNTR_ALIAS_TYPE_CD = 1077	; 'FIN NBR' from code set 319
           AND E_A.ACTIVE_IND = 1	; active FIN NBRs only
           AND E_A.END_EFFECTIVE_DT_TM > SYSDATE	; effective FIN NBRs only
   )
	and pi.active_ind = 1
	and pi.end_effective_dt_tm >= sysdate
	and pi.ipass_data_type_cd in (
		82070315.00,
		82070321.00
		)
join sn
	where sn.sticky_note_id = pi.parent_entity_id
	and sn.beg_effective_dt_tm <= sysdate
	and sn.end_effective_dt_tm >= sysdate
	and sn.sticky_note_id != 0
join lt
	where lt.long_text_id = outerjoin(sn.long_text_id)
	and lt.active_ind = outerjoin(1)

join l where l.PARENT_ENTITY_ID = OUTERJOIN(pi.PARENT_ENTITY_ID)

with time = 5, format, seperator = " ", maxcol = 50000


end
go