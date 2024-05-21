
/*****************************************************************************
Jason Whittle: IN DEVELOPMENT

*******************************************************************************/

drop program vic_au_ds_send_status go
create program vic_au_ds_send_status

; Include standard rtf includes
%i cust_script:ma_rtf_tags.inc
%i cust_script:vic_ds_common_fonts.inc

; Record Structures
record RECORD_PERSONS (
  1 LIST_PERSONS [*]
    2 A_PERSON_ID = F8
    2 A_NAME = vc
    2 A_RELATIONSHIP = vc
    2 A_DOB = vc
    2 A_SEX = vc
)

record RECORD_PHONES (
  1 LIST_PHONES [*]
    2 A_PERSON_ID = F8
    2 A_PHONE_NUMBER_TYPE = vc
    2 A_PHONE_NUMBER = vc
)

record RECORD_EMAILS (
  1 LIST_EMAILS [*]
    2 A_PERSON_ID = F8
    2 A_EMAIL = vc
)

; DECLARE VARIABLES
DECLARE ENCNTR_ID_VAR = F8 WITH CONSTANT(REQUEST->VISIT[1].ENCNTR_ID), PROTECT
DECLARE PATIENT_PERSON_ID_VAR = F8 WITH NOCONSTANT(0.00),PROTECT
DECLARE COUNT_PERSONS = I4 WITH NOCONSTANT(0),PROTECT
DECLARE COUNT_PHONES = I4 WITH NOCONSTANT(0),PROTECT
DECLARE COUNT_EMAILS = I4 WITH NOCONSTANT(0),PROTECT

; Get the patient person id for the encounter
    SELECT INTO "NL:"
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
    SELECT DISTINCT INTO "NL:"
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
        ;allocate memory to store information for 20 Next of Kins
        STAT = ALTERLIST(RECORD_PERSONS->LIST_PERSONS,20)

    ;Loop through in the detail section and store variables
    DETAIL
        COUNT_PERSONS += 1
        RECORD_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_PERSON_ID = R_PERSON_ID
        RECORD_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_NAME = NAME
        RECORD_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_RELATIONSHIP = RELATIONSHIP
        RECORD_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_DOB = DOB
        RECORD_PERSONS->LIST_PERSONS[COUNT_PERSONS].A_SEX = SEX
    WITH time =10


;Get Phone Numbers and number types for each Next of Kin
    SELECT DISTINCT INTO "NL:"
        R_PERSON_ID = P_P_R.RELATED_PERSON_ID
        , PHONE_NUMBER_TYPE = TRIM(UAR_GET_CODE_DISPLAY(PH.PHONE_TYPE_CD))
        , PHONE_NUMBER = TRIM(PH.PHONE_NUM)
    FROM
        PERSON_PERSON_RELTN     P_P_R
        , PHONE               PH
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

    JOIN PH;PHONE
        WHERE PH.PARENT_ENTITY_ID = P_P_R.RELATED_PERSON_ID
        AND PH.ACTIVE_IND = 1
        and PH.END_EFFECTIVE_DT_TM > SYSDATE

    HEAD REPORT
        COUNT_PHONES = 0
        ;allocate memory to store information for 10 Phones
        STAT = ALTERLIST(RECORD_PHONES->LIST_PHONES,10)

    ;Loop through in the detail section and store variables
    DETAIL
        COUNT_PHONES += 1
        RECORD_PHONES->LIST_PHONES[COUNT_PHONES].A_PERSON_ID = R_PERSON_ID
        RECORD_PHONES->LIST_PHONES[COUNT_PHONES].A_PHONE_NUMBER_TYPE = PHONE_NUMBER_TYPE
        RECORD_PHONES->LIST_PHONES[COUNT_PHONES].A_PHONE_NUMBER = PHONE_NUMBER
    WITH time =10


;Get Emails for each Next of Kin
    SELECT DISTINCT INTO "NL:"
        R_PERSON_ID = P_P_R.RELATED_PERSON_ID
        , EMAIL = TRIM(AEMAIL.STREET_ADDR)
    FROM
        PERSON_PERSON_RELTN     P_P_R
        , ADDRESS               AEMAIL
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

    JOIN AEMAIL;ADDRESS
        WHERE AEMAIL.PARENT_ENTITY_ID = P_P_R.RELATED_PERSON_ID
        AND AEMAIL.ACTIVE_IND = 1
        AND AEMAIL.END_EFFECTIVE_DT_TM > SYSDATE
        AND AEMAIL.ADDRESS_TYPE_CD = 755.00 ; EMAIL Address Type Only

    HEAD REPORT
        COUNT_EMAILS = 0
        ;allocate memory to store information for 10 Emails
        STAT = ALTERLIST(RECORD_EMAILS->LIST_EMAILS,10)

    ;Loop through in the detail section and store variables
    DETAIL
        COUNT_EMAILS += 1
        RECORD_EMAILS->LIST_EMAILS[COUNT_EMAILS].A_PERSON_ID = R_PERSON_ID
        RECORD_EMAILS->LIST_EMAILS[COUNT_EMAILS].A_EMAIL = EMAIL
    WITH time =10

call ApplyFont(active_fonts->normal)

FOR (X = 1 TO COUNT_PERSONS)
    CALL PRINTLABELEDDATAFIXED("Name: ",RECORD_PERSONS->LIST_PERSONS[X].A_NAME,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("Relationship: ",RECORD_PERSONS->LIST_PERSONS[X].A_RELATIONSHIP,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("DOB: ",RECORD_PERSONS->LIST_PERSONS[X].A_DOB,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("Sex: ",RECORD_PERSONS->LIST_PERSONS[X].A_SEX,90)
    CALL NEXTLINE(1)
    FOR (Y = 1 TO COUNT_PHONES)
        IF (RECORD_PHONES->LIST_PHONES[Y].A_PERSON_ID = RECORD_PERSONS->LIST_PERSONS[X].A_PERSON_ID)
            CALL PRINTLABELEDDATAFIXED("Number: ",RECORD_PHONES->LIST_PHONES[Y].A_PHONE_NUMBER_TYPE, 10)
            CALL PRINTLABELEDDATAFIXED(": ",RECORD_PHONES->LIST_PHONES[Y].A_PHONE_NUMBER,20)
            CALL NEXTLINE(1)
        ENDIF
    ENDFOR
    FOR (Z = 1 TO COUNT_PHONES)
        IF (RECORD_EMAILS->LIST_EMAILS[Z].A_PERSON_ID = RECORD_PERSONS->LIST_PERSONS[X].A_PERSON_ID)
            CALL PRINTLABELEDDATAFIXED("Email: ",RECORD_EMAILS->LIST_EMAILS[Z].A_EMAIL, 10)
            CALL NEXTLINE(1)
        ENDIF
    ENDFOR
    CALL NEXTLINE(1)
    CALL PRINTTEXT("------------------------------------------------------------------------------------",0,0,0)
    CALL NEXTLINE(2)
ENDFOR


;call PrintText("**TESTING**",0,0,0)
call FinishText(0)
call echo(rtf_out->text)
set reply->text = rtf_out->text

end
go