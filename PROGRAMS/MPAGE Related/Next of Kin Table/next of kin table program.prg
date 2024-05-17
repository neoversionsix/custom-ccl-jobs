
/*****************************************************************************
Jason Whittle: IN DEVELOPMENT

*******************************************************************************/

drop program vic_au_ds_send_status go
create program vic_au_ds_send_status


; Include standard rtf includes
%i cust_script:ma_rtf_tags.inc
%i cust_script:vic_ds_common_fonts.inc

DECLARE ENCNTR_ID_VAR = F8 WITH CONSTANT(REQUEST->VISIT[1].ENCNTR_ID), PROTECT
DECLARE FINALTEXT_VAR = VC WITH NOCONSTANT(" "),PROTECT
DECLARE PERSON_ID_VAR = F8 WITH NOCONSTANT(0.00),PROTECT

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
	P_P_R.FT_REL_PERSON_NAME
	; , P_P_R.PERSON_RELTN_CD
	; , P_PERSON_RELTN_DISP = UAR_GET_CODE_DISPLAY(P_P_R.PERSON_RELTN_CD)
	; , P_P_R.PERSON_RELTN_TYPE_CD
	; , P_PERSON_RELTN_TYPE_DISP = UAR_GET_CODE_DISPLAY(P_P_R.PERSON_RELTN_TYPE_CD)

FROM
	PERSON_PERSON_RELTN   P_P_R

WHERE P_P_R.PERSON_ID = PERSON_ID_VAR;(SELECT E.PERSON_ID FROM ENCOUNTER E WHERE E.ENCNTR_ID = ENCNTR_ID_VAR)
    AND P_P_R.ACTIVE_IND = 1
    AND P_P_R.PERSON_RELTN_CD > 0
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

HEAD REPORT
	"HEADER";FINALTEXT_VAR  = BUILD2(FINALTEXT_VAR," ", P_P_R.FT_REL_PERSON_NAME)
DETAIL
    FINALTEXT_VAR  = BUILD2(FINALTEXT_VAR," ", P_P_R.FT_REL_PERSON_NAME)
	; , P_P_R.FT_REL_PERSON_NAME
	; , P_P_R.PERSON_RELTN_CD
	; , P_PERSON_RELTN_DISP = UAR_GET_CODE_DISPLAY(P_P_R.PERSON_RELTN_CD)
	; , P_P_R.PERSON_RELTN_TYPE_CD
	; , P_PERSON_RELTN_TYPE_DISP = UAR_GET_CODE_DISPLAY(P_P_R.PERSON_RELTN_TYPE_CD)
FOOT REPORT
	"FOOTER";FINALTEXT_VAR  = BUILD2(FINALTEXT_VAR," ", P_P_R.FT_REL_PERSON_NAME)


WITH time =10


call PrintText(FINALTEXT_VAR,0,0,0)
call FinishText(0)
call echo(rtf_out->text)
SET _memory_reply_string = FINALTEXT_VAR
set reply->text = rtf_out->text


end
go