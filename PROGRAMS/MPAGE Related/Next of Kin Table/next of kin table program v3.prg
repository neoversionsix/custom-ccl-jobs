
/*****************************************************************************
Jason Whittle: IN DEVELOPMENT

*******************************************************************************/

drop program vic_au_ds_send_status go
create program vic_au_ds_send_status

; Include standard rtf includes
%i cust_script:ma_rtf_tags.inc
%i cust_script:vic_ds_common_fonts.inc

; Record Structures
record RECORD_STRUCTURE_PERSONS (
  1 LIST_PERSONS [*]
    2 A_PERSON_ID = F8
    2 A_NAME = vc
    2 A_RELATIONSHIP = vc
    2 A_DOB = vc
    2 A_SEX = vc
)

; DECLARE VARIABLES
DECLARE ENCNTR_ID_VAR = F8 WITH CONSTANT(REQUEST->VISIT[1].ENCNTR_ID), PROTECT
DECLARE PATIENT_PERSON_ID_VAR = F8 WITH NOCONSTANT(0.00),PROTECT
DECLARE COUNT_PERSONS = I4 WITH NOCONSTANT(0),PROTECT

; Get the patient person id for the encounter
    SELECT DISTINCT INTO "NL:"
        E.PERSON_ID
    FROM ENCOUNTER E
    WHERE E.ENCNTR_ID = ENCNTR_ID_VAR
        AND E.ACTIVE_IND = 1
        AND E.END_EFFECTIVE_DT_TM > SYSDATE
        AND E.BEG_EFFECTIVE_DT_TM <= SYSDATE
    HEAD REPORT
    PATIENT_PERSON_ID_VAR = E.PERSON_ID
    WITH TIME = 10

;Get Next of Kin Names, DOBs, Genders and Relationships
    SELECT INTO "NL:"
        R_PERSON_ID = P_P_R.RELATED_PERSON_ID
        , NAME = TRIM(P.NAME_FULL_FORMATTED)
        , RELATIONSHIP = UAR_GET_CODE_DISPLAY(P_P_R.PERSON_RELTN_CD)
        , DOB = TRIM(DATEBIRTHFORMAT(P.BIRTH_DT_TM,P.BIRTH_TZ,P.BIRTH_PREC_FLAG,"DD-MMM-YYYY"))
        , SEX = TRIM(UAR_GET_CODE_DISPLAY(P.SEX_CD))
    FROM
        PERSON_PERSON_RELTN     P_P_R
        , PERSON               P
    PLAN P_P_R ; PERSON_PERSON_RELTN
        WHERE P_P_R.PERSON_ID = PATIENT_PERSON_ID_VAR; (SELECT E.PERSON_ID FROM ENCOUNTER E WHERE E.ENCNTR_ID = ENCNTR_ID_VAR)
        AND P_P_R.ACTIVE_IND = 1
        AND P_P_R.PERSON_RELTN_CD > 0
        AND P_P_R.PERSON_RELTN_CD != 158.00; Not a relationship name of "SELF"
        AND P_P_R.PERSON_RELTN_TYPE_CD = 1159.00; 'Next of Kin' Relationship Type Only
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
        COUNT_PERSONS = 0
        ;allocate memory to store information for 50 Next of Kins
        STAT = ALTERLIST(RECORD_STRUCTURE_PERSONS->LIST_PERSONS,50)

    ;Loop through in the detail section and store variables
    DETAIL
        COUNT_PERSONS += 1
        RECORD_STRUCTURE_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_PERSON_ID = R_PERSON_ID
        RECORD_STRUCTURE_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_NAME = NAME
        RECORD_STRUCTURE_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_RELATIONSHIP = RELATIONSHIP
        RECORD_STRUCTURE_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_DOB = DOB
        RECORD_STRUCTURE_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_SEX = SEX
    WITH time =10

call ApplyFont(active_fonts->normal)

FOR (X = 1 TO COUNT_PERSONS)
    CALL PRINTLABELEDDATAFIXED("Name: ",RECORD_STRUCTURE_PERSONS->LIST_PERSONS[X].A_NAME,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("Relationship: ",RECORD_STRUCTURE_PERSONS->LIST_PERSONS[X].A_RELATIONSHIP,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("DOB: ",RECORD_STRUCTURE_PERSONS->LIST_PERSONS[X].A_DOB,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("Sex: ",RECORD_STRUCTURE_PERSONS->LIST_PERSONS[X].A_SEX,90)

    CALL PRINTTEXT("------------------------------------------------------------------------------------",0,0,0)
    CALL NEXTLINE(2)

ENDFOR
;call PrintText("**TESTING**",0,0,0)
call FinishText(0)
call echo(rtf_out->text)
set reply->text = rtf_out->text

end
go