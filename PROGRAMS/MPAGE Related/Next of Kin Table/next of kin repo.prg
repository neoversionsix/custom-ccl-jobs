
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
  1 COUNT_PERSONS = I4
  1 LIST_PERSONS [*]
    2 A_PERSON_ID = F8
    2 A_NAME = vc
    2 A_DOB = vc
    2 A_SEX = vc
    2 A_RELATIONSHIP = vc
)


record RECORD_PHONES (
  1 COUNT_PHONES = I4
  1 LIST_PHONES [*]
    2 A_PERSON_ID = F8
    2 A_PHONE_NUMBER_TYPE = vc
    2 A_PHONE_NUMBER = vc
)

record RECORD_STRUCTURE_EMAILS (
  1 COUNT_EMAILS = I4
  1 LIST_EMAILS [*]
    2 A_PERSON_ID = F8
    2 A_EMAIL_ADDRESS = vc
)

record RECORD_STRUCTURE_ADDRESSES (
  1 COUNT_ADDRESSES = I4
  1 LIST_ADDRESSES [*]
    2 A_PERSON_ID = F8
    2 A_ADDRESS_HOME = vc
    2 A_CITY = vc
    2 A_STATE = vc
    2 A_COUNTRY = vc
    2 A_ZIPCODE = vc
)

; DECLARE VARIABLES
    DECLARE ENCNTR_ID_VAR = F8 WITH CONSTANT(REQUEST->VISIT[1].ENCNTR_ID), PROTECT
    DECLARE PATIENT_PERSON_ID_VAR = F8 WITH NOCONSTANT(0.00),PROTECT

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
        NAME = TRIM(P.NAME_FULL_FORMATTED)
        , RELATIONSHIP = UAR_GET_CODE_DISPLAY(P_P_R.PERSON_RELTN_CD)
        , DOB = TRIM(DATEBIRTHFORMAT(P.BIRTH_DT_TM,P.BIRTH_TZ,P.BIRTH_PREC_FLAG,"DD-MMM-YYYY"))
        , SEX = TRIM(UAR_GET_CODE_DISPLAY(P.SEX_CD))
    FROM
        PERSON_PERSON_RELTN     P_P_R
        , PERSON
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
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_NAME = NAME
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_RELATIONSHIP = RELATIONSHIP
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_DOB = DOB
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_SEX = SEX
    WITH time =10


;FULL QUERY
    SELECT INTO "NL:"
	NAME = TRIM(P.NAME_FULL_FORMATTED)
	, RELATIONSHIP = UAR_GET_CODE_DISPLAY(P_P_R.PERSON_RELTN_CD)
	, DOB = TRIM(DATEBIRTHFORMAT(P.BIRTH_DT_TM,P.BIRTH_TZ,P.BIRTH_PREC_FLAG,"DD-MMM-YYYY"))
    , SEX = TRIM(UAR_GET_CODE_DISPLAY(P.SEX_CD))
	, EMAIL_ADDRESS = TRIM(AEMAIL.STREET_ADDR)
    , ADDRESS_HOME = TRIM
    (
        CONCAT
        (
            TRIM(A.STREET_ADDR)
            , " "
            , TRIM(A.STREET_ADDR2)
            , " "
            , TRIM(A.STREET_ADDR3)
            , " "
            , TRIM(A.STREET_ADDR4)
        )
    )
    , CITY = TRIM(A.CITY)
	, STATE = TRIM(A.STATE)
	, COUNTRY = UAR_GET_CODE_DISPLAY(A.COUNTRY_CD)
	, ZIPCODE = TRIM(A.ZIPCODE)

    FROM
        PERSON_PERSON_RELTN     P_P_R
        , PERSON                P
        , ADDRESS   AEMAIL
        , ADDRESS   A

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

    JOIN AEMAIL;ADDRESS
        WHERE AEMAIL.PARENT_ENTITY_ID = OUTERJOIN(P_P_R.RELATED_PERSON_ID)
        AND AEMAIL.ACTIVE_IND = OUTERJOIN(1)
        AND AEMAIL.END_EFFECTIVE_DT_TM > OUTERJOIN(SYSDATE)
        AND AEMAIL.ADDRESS_TYPE_CD = OUTERJOIN(755.00) ; EMAIL Address Type Only

    JOIN A;ADDRESS
        WHERE A.PARENT_ENTITY_ID = OUTERJOIN(P_P_R.RELATED_PERSON_ID)
        AND A.ACTIVE_IND = OUTERJOIN(1)
        AND A.END_EFFECTIVE_DT_TM > OUTERJOIN(SYSDATE)
        AND A.ADDRESS_TYPE_CD = OUTERJOIN(756.00) ; Home Address Type Only

    HEAD REPORT
        COUNT_PERSONS = 0
        ;allocate memory to store information for 50 Next of Kins
        STAT = ALTERLIST(RECORD_STRUCTURE_1->LIST_PERSONS,50)
    ;Loop through in the detail section and store variables

    DETAIL
        COUNT_PERSONS += 1
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_NAME = NAME
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_RELATIONSHIP = RELATIONSHIP
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_DOB = DOB
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_SEX = SEX
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_EMAIL_ADDRESS = EMAIL_ADDRESS
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_ADDRESS_HOME = ADDRESS_HOME
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_CITY = CITY
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_STATE = STATE
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_COUNTRY = COUNTRY
        RECORD_STRUCTURE_1->LIST_PERSONS[COUNT_PERSONS].A_ZIPCODE = ZIPCODE
    ;
    WITH time =10


;Get NOK Phone numbers
    SELECT INTO "NL:"
        PHONE_NUMBER_TYPE = UAR_GET_CODE_DISPLAY(PH.PHONE_TYPE_CD)
        , PHONE_NUMBER = TRIM(PH.PHONE_NUMBER)

    FROM
        PERSON_PERSON_RELTN     P_P_R
        , PHONE   PH

    PLAN P_P_R ; PERSON_PERSON_RELTN
        WHERE P_P_R.PERSON_ID = PATIENT_PERSON_ID_VAR; (SELECT E.PERSON_ID FROM ENCOUNTER E WHERE E.ENCNTR_ID = ENCNTR_ID_VAR)
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

    JOIN PH;PHONE
        WHERE PH.PARENT_ENTITY_ID = OUTERJOIN(P_P_R.RELATED_PERSON_ID)
        AND PH.ACTIVE_IND = OUTERJOIN(1)
        and PH.END_EFFECTIVE_DT_TM > OUTERJOIN(SYSDATE)

    HEAD REPORT
        COUNTER_2 = 0
        ;allocate memory to store information for 10 Phone Numbers
        STAT = ALTERLIST(RECORD_STRUCTURE_2->LIST_2,10)
    ;Loop through in the detail section and store variables

    DETAIL
        COUNTER_2 += 1
        RECORD_STRUCTURE_2->LIST_2[COUNTER_2].A_PHONE_NUMBER_TYPE = PHONE_NUMBER_TYPE
        RECORD_STRUCTURE_2->LIST_2[COUNTER_2].A_PHONE_NUMBER = PHONE_NUMBER
    WITH time =10

call ApplyFont(active_fonts->normal)

FOR (X = 1 TO COUNT_PERSONS)
    CALL PRINTLABELEDDATAFIXED("Name: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_NAME,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("Relationship: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_RELATIONSHIP,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("DOB: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_DOB,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("Sex: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_SEX,90)
    CALL NEXTLINE(1)
    FOR (Y = 1 TO COUNTER_2)
        CALL PRINTLABELEDDATAFIXED("Phone Type: ",RECORD_STRUCTURE_2->LIST_2[X].A_PHONE_NUMBER_TYPE,90)
        CALL NEXTLINE(1)
        CALL PRINTLABELEDDATAFIXED("Phone Number: ",RECORD_STRUCTURE_2->LIST_2[X].A_PHONE_NUMBER,90)
        CALL NEXTLINE(1)
    ENDFOR
    CALL PRINTLABELEDDATAFIXED("Email: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_EMAIL_ADDRESS,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("Address: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_ADDRESS_HOME,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("City: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_CITY,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("State: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_STATE,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("Country: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_COUNTRY,90)
    CALL NEXTLINE(1)
    CALL PRINTLABELEDDATAFIXED("Zipcode: ",RECORD_STRUCTURE_1->LIST_PERSONS[X].A_ZIPCODE,90)
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