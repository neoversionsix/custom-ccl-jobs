/**************************************************************************************************
 *                      MODIFICATION CONTROL LOG                                                  *
 **************************************************************************************************
 *                                                                                                *
 *Mod Date       Engineer             Comment                                                     *
 *--- --------   -------------------- ------------------------------------------------------------*
 *XXX 09/05/2024 Jason W        Pulling GP from the same table as GP View Mpage.
                                encntr_prsnl_reltn was pulling the most recent
                                gp from that table without a match on the
                                specific encounter. Turns out It needs to pull the
                                data from person_prsnl_reltn table. Changed the name of the
                                program to wh_gp_details_person from wh_vic_gp_details_2
                                this is basically a complete rewrite of the program.
 *************************************************************************************************/


drop program wh_gp_details_person go
create program wh_gp_details_person

%i cust_script:ma_rtf_tags.inc
%i cust_script:vic_ds_common_fonts.inc

FREE RECORD ENCNTR_INFO
RECORD ENCNTR_INFO
(
  1 GP_NAME             = VC
  1 GP_ADDRESS_LINE_1   = VC
  1 GP_ADDRESS_LINE_2   = VC
  1 GP_ADDRESS_LINE_3	  = VC
  1 GP_CITY             = VC
  1 GP_STATE            = VC
  1 GP_COUNTRY          = VC
  1 GP_ZIPCODE          = VC
  1 GP_PHONE            = VC
  1 GP_FAX              = VC
)

/*MY CODE */
DECLARE PERSON_PRSNL_R_CD_VAR = f8 with constant(1115.00),protect ; Code for: Primary Care Physician
DECLARE NAME_TYPE_CD_VAR = f8 with constant(614387.00),protect ; Personnel
DECLARE ADDRESS_TYPE_CD_VAR = f8 with constant(754.00),protect ; Business
DECLARE PHONE_TYPE_CD_BUS_VAR = f8 with constant(163.00),protect ; Business
DECLARE PHONE_TYPE_CD_FAX_VAR = f8 with constant(166.00),protect ; Fax Business
DECLARE ALIAS_POOL_CD_VAR = f8 with constant(9569589.00),protect ; UR Number
DECLARE PERSON_ID_VAR = F8 WITH NOCONSTANT(REQUEST->PERSON[1].PERSON_ID), PROTECT ;002
DECLARE PARENT_ENTITY_NAME_VAR = VC WITH CONSTANT("PERSON"), PROTECT ;002


SELECT INTO "nl:"
    PATIENT_URN = P_A.ALIAS
  , PH_PHONE_TYPE_DISP = UAR_GET_CODE_DISPLAY(PH.PHONE_TYPE_CD)
  , PH.PHONE_NUM
  , PATIENT_PERSON_ID = P_P_R.PERSON_ID
	, GP_NAME = P_N.NAME_FULL
	, GP_ADDRESS_L1 = A.STREET_ADDR
	, GP_ADDRESS_L2 = A.STREET_ADDR2
	, GP_ADDRESS_L3 = A.STREET_ADDR3
	, GP_ADDRESS_L4 = A.STREET_ADDR4
	, A.CITY
	, A.COUNTRY
	, A.ZIPCODE
	, A.PARENT_ENTITY_NAME
	, A.ADDRESS_TYPE_CD
	, A_ADDRESS_TYPE_DISP = UAR_GET_CODE_DISPLAY(A.ADDRESS_TYPE_CD)
	, P_N.NAME_TYPE_CD
	, P_N_NAME_TYPE_DISP = UAR_GET_CODE_DISPLAY(P_N.NAME_TYPE_CD)

FROM
	PERSON_PRSNL_RELTN   P_P_R
	, ADDRESS   A
    , PHONE   PH
	;, PERSON   				P
	, PRSNL   PR
	, PERSON_NAME   P_N
    , PERSON_ALIAS   P_A


PLAN P_P_R ; PERSON_PRSNL_RELTN
	WHERE P_P_R.PERSON_ID =  PERSON_ID_VAR ; FOR A PATIENT PERSON_ID
	AND P_P_R.ACTIVE_IND = 1 ; ACTIVE
	AND P_P_R.PERSON_PRSNL_R_CD = PERSON_PRSNL_R_CD_VAR ; PRIMARY CARE PHYSICIAN
	AND P_P_R.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
	AND P_P_R.BEG_EFFECTIVE_DT_TM =
		(
			SELECT MAX (P_P_R_INLINE.BEG_EFFECTIVE_DT_TM)
			FROM PERSON_PRSNL_RELTN P_P_R_INLINE
			WHERE
				P_P_R_INLINE.PERSON_ID = P_P_R.PERSON_ID ; RELATED TO THIS PATIENT
				AND P_P_R_INLINE.ACTIVE_IND = 1 ; ACTIVE
				AND P_P_R_INLINE.PERSON_PRSNL_R_CD = PERSON_PRSNL_R_CD_VAR ; PRIMARY CARE PHYSICIAN
				AND P_P_R_INLINE.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
		)
JOIN PR ; PRSNL
	WHERE PR.PERSON_ID = OUTERJOIN(P_P_R.PRSNL_PERSON_ID)
    AND PR.ACTIVE_IND = OUTERJOIN(1)
    AND PR.END_EFFECTIVE_DT_TM > OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
    AND PR.BEG_EFFECTIVE_DT_TM <= OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))

; FOR DOCTOR NAME INFO
JOIN P_N ; PERSON_NAME
	WHERE P_N.PERSON_ID = OUTERJOIN(PR.PERSON_ID)
	AND P_N.ACTIVE_IND = OUTERJOIN(1)
	AND P_N.NAME_TYPE_CD = OUTERJOIN(NAME_TYPE_CD_VAR) ; PERSONNEL
    AND P_N.END_EFFECTIVE_DT_TM > OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
    AND P_N.BEG_EFFECTIVE_DT_TM <= OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))

;
JOIN A ; ADDRESS
	WHERE A.PARENT_ENTITY_ID = OUTERJOIN(PR.PERSON_ID)
	AND A.PARENT_ENTITY_NAME = OUTERJOIN(PARENT_ENTITY_NAME_VAR)
	AND A.ADDRESS_TYPE_CD = OUTERJOIN(ADDRESS_TYPE_CD_VAR) ; BUSINESS
	AND A.ACTIVE_IND = OUTERJOIN(1) ; ACTIVE
    ; NOT TIME DEACTIVATED
	AND A.BEG_EFFECTIVE_DT_TM <= OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
	AND A.END_EFFECTIVE_DT_TM > OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))

JOIN PH ; PHONE
    WHERE PH.PARENT_ENTITY_ID = OUTERJOIN(PR.PERSON_ID)
    ; NOT TIME DEACTIVATED
    AND PH.BEG_EFFECTIVE_DT_TM <= OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
    AND PH.END_EFFECTIVE_DT_TM > OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
    AND (
            PH.PHONE_TYPE_CD = OUTERJOIN(PHONE_TYPE_CD_BUS_VAR);	Business
            OR PH.PHONE_TYPE_CD = OUTERJOIN(PHONE_TYPE_CD_FAX_VAR)	;Fax Business
        )

;For Patient  URN
JOIN P_A;PERSON_ALIAS; PATIENT_URN = P_A.ALIAS
    WHERE P_A.PERSON_ID = P_P_R.PERSON_ID
    ;this filters for the UR Number Alias' only */
   	AND P_A.ALIAS_POOL_CD = ALIAS_POOL_CD_VAR
    ;Effective Only
	  AND P_A.END_EFFECTIVE_DT_TM >CNVTDATETIME(CURDATE, curtime3)
    ;Active Only
    AND P_A.ACTIVE_IND = 1

; Loop over the table and
; Save the data retrieved from the database into the record
DETAIL
    IF (P_P_R.PRSNL_PERSON_ID = 0)
        ENCNTR_INFO->GP_NAME = P_P_R.FT_PRSNL_NAME
    ELSE
        ENCNTR_INFO->GP_NAME = P_N.NAME_FULL
    ENDIF
    ENCNTR_INFO->GP_ADDRESS_LINE_1 = A.STREET_ADDR
    ENCNTR_INFO->GP_ADDRESS_LINE_2 = A.STREET_ADDR2
    ENCNTR_INFO->GP_ADDRESS_LINE_3 = A.STREET_ADDR3
    ENCNTR_INFO->GP_CITY = A.CITY
    ENCNTR_INFO->GP_STATE = A.STATE
    ENCNTR_INFO->GP_ZIPCODE = TRIM(A.ZIPCODE,3)
    ENCNTR_INFO->GP_COUNTRY = A.COUNTRY
    IF (PH.PHONE_TYPE_CD = PHONE_TYPE_CD_BUS_VAR)
        ENCNTR_INFO->GP_PHONE = PH.PHONE_NUM
    ELSEIF (PH.PHONE_TYPE_CD = PHONE_TYPE_CD_FAX_VAR)
        ENCNTR_INFO->GP_FAX = PH.PHONE_NUM
    ENDIF

WITH
  TIME = 120
  ;DONTCARE=A,
  ;OUTERJOIN=D2

; DISPLAY THE DATA ON THE FRONT END
CALL ECHORECORD(ENCNTR_INFO)
CALL APPLYFONT(ACTIVE_FONTS->NORMAL)

; GP NAME
CALL PRINTTEXT("Name: ",0,0,0)
DECLARE TEMPNAME = VC
SET TEMPNAME = TRIM(ENCNTR_INFO->GP_NAME,3)
CALL PRINTTEXT(BUILD2(TEMPNAME),0,0,0)
;CALL PRINTTEXT(BUILD2(" ",ENCNTR_INFO->GP_NAME))
CALL NEXTLINE(1)

; ADDRESS
DECLARE TEMPSTR = VC
CALL PRINTTEXT("Address:",0,0,0)
SET TEMPSTR = BUILD2(" ",TRIM(ENCNTR_INFO->GP_ADDRESS_LINE_1,3))
IF(TEXTLEN(ENCNTR_INFO->GP_ADDRESS_LINE_2) > 1)
  SET TEMPSTR = BUILD2(TEMPSTR,", ",TRIM(ENCNTR_INFO->GP_ADDRESS_LINE_2,3))
ENDIF
IF(TEXTLEN(ENCNTR_INFO->GP_ADDRESS_LINE_3) > 1)
  SET TEMPSTR = BUILD2(TEMPSTR,", ",TRIM(ENCNTR_INFO->GP_ADDRESS_LINE_3,3))
ENDIF
IF(TEXTLEN(ENCNTR_INFO->GP_CITY) > 1)
  SET TEMPSTR = BUILD2(TEMPSTR,", ",ENCNTR_INFO->GP_CITY)
ENDIF
IF(TEXTLEN(ENCNTR_INFO->GP_STATE) > 1)
    SET TEMPSTR = BUILD2(TEMPSTR,", ",ENCNTR_INFO->GP_STATE)
ENDIF
IF(TEXTLEN(ENCNTR_INFO->GP_ZIPCODE) > 1)
  SET TEMPSTR = BUILD2(TEMPSTR," ",ENCNTR_INFO->GP_ZIPCODE)
ENDIF
IF(TEXTLEN(ENCNTR_INFO->GP_COUNTRY) > 1)
  SET TEMPSTR = BUILD2(TEMPSTR,", ",ENCNTR_INFO->GP_COUNTRY)
ENDIF
CALL PRINTTEXT(TEMPSTR,0,0,0)
CALL NEXTLINE(1)

; PHONE
CALL PRINTTEXT("Phone:",0,0,0)
CALL PRINTTEXT(BUILD2(" ",ENCNTR_INFO->GP_PHONE),0,0,0)

; FAX
CALL PRINTTEXT("  Fax:",0,0,0)
CALL PRINTTEXT(BUILD2(" ",ENCNTR_INFO->GP_FAX),0,0,0)
CALL NEXTLINE(1)

; Send the text to Output
CALL FINISHTEXT(0)
SET REPLY->TEXT = RTF_OUT->TEXT

END
GO