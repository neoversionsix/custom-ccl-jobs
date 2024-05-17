
/*****************************************************************************
Jason Whittle: IN DEVELOPMENT

*******************************************************************************/

drop program vic_au_ds_send_status go
create program vic_au_ds_send_status


; Include standard rtf includes
%i cust_script:ma_rtf_tags.inc
%i cust_script:vic_ds_common_fonts.inc

record RECORD_STRUCTURE_1 (
  1 LIST_1 [*]
    2 A_NOK_NAME = vc
    2 A_NOK_TYPE = vc
)

DECLARE ENCNTR_ID_VAR = F8 WITH CONSTANT(REQUEST->VISIT[1].ENCNTR_ID), PROTECT
DECLARE FINALTEXT_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE PERSON_ID_VAR = F8 WITH NOCONSTANT(0.00),PROTECT
DECLARE COUNTER = I4 WITH NOCONSTANT(0),PROTECT

SET FINALTEXT_VAR = BUILD2(
    "TESTING - IN DEVELOPMENT"
    )

; Get the person id for the encounter
SELECT INTO "NL:"
	E.PERSON_ID
FROM ENCOUNTER E
WHERE E.ENCNTR_ID = ENCNTR_ID_VAR
HEAD REPORT
PERSON_ID_VAR = E.PERSON_ID
WITH TIME = 10

SELECT INTO "NL:"
	 ;  P_P_R.PERSON_ID
	NOK_NAME = P.NAME_FULL_FORMATTED
	; , P_P_R.PERSON_RELTN_CD
	, NOK_TYPE = UAR_GET_CODE_DISPLAY(P_P_R.PERSON_RELTN_CD)
	; , P_P_R.PERSON_RELTN_TYPE_CD
	; , P_PERSON_RELTN_TYPE_DISP = UAR_GET_CODE_DISPLAY(P_P_R.PERSON_RELTN_TYPE_CD)

FROM
	PERSON_PERSON_RELTN     P_P_R
    , PERSON                P

PLAN P_P_R ; PERSON_PERSON_RELTN
    WHERE P_P_R.PERSON_ID = PERSON_ID_VAR; (SELECT E.PERSON_ID FROM ENCOUNTER E WHERE E.ENCNTR_ID = ENCNTR_ID_VAR)
    AND P_P_R.ACTIVE_IND = 1
    AND P_P_R.PERSON_RELTN_CD > 0
    AND P_P_R.PERSON_RELTN_CD != 158 ; NOT 'Self'
    AND
        (
            P_P_R.END_EFFECTIVE_DT_TM > SYSDATE
            OR
            P_P_R.END_EFFECTIVE_DT_TM IS NULL
        )
    AND
        (
            P_P_R.BEG_EFFECTIVE_DT_TM <= SYSDATE
            OR
            P_P_R.BEG_EFFECTIVE_DT_TM IS NULL
        )

JOIN P;PERSON
    WHERE P.PERSON_ID = P_P_R.RELATED_PERSON_ID
    AND P.ACTIVE_IND = 1
    AND P.END_EFFECTIVE_DT_TM > SYSDATE

HEAD REPORT
	COUNTER = 0
	;allocate memory to store information for 100 Next of Kins
	STAT = ALTERLIST(RECORD_STRUCTURE_1->LIST_1,100)
;Loop through in the detail section and store variables
DETAIL
	COUNTER += 1
	RECORD_STRUCTURE_1->LIST_1[counter].A_NOK_NAME = NOK_NAME
	RECORD_STRUCTURE_1->LIST_1[counter].A_NOK_TYPE = NOK_TYPE

WITH time =10

call ApplyFont(active_fonts->normal)

FOR (X = 1 TO COUNTER)
	CALL PRINTLABELEDDATAFIXED("NOK NAME: ",RECORD_STRUCTURE_1->LIST_1[X].A_NOK_NAME,50)
	CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("NOK TYPE: ",RECORD_STRUCTURE_1->LIST_1[X].A_NOK_TYPE,50)
    CALL NEXTLINE(2)
ENDFOR
;call PrintText("**TESTING**",0,0,0)
call FinishText(0)
call echo(rtf_out->text)
set reply->text = rtf_out->text

end
go