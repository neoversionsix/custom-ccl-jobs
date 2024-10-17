/*
Programmer: Jason Whittle
Requester: Annie.L
Cherwells: 766199, 770993, 704272, TASK 189622

Use: Pulls back patient concession details for a dyndoc: Pharmacy Admission
#dynamic document

 */

DROP PROGRAM WH_PATIENT_CONCESSIONS GO
CREATE PROGRAM WH_PATIENT_CONCESSIONS

%I CUST_SCRIPT:MA_RTF_TAGS.INC
%I CUST_SCRIPT:VIC_DS_COMMON_FONTS.INC

; Store encounter_id from powerchart
DECLARE ENCNTR_ID_VAR                           = F8 WITH CONSTANT(REQUEST->VISIT[1].ENCNTR_ID), PROTECT
; Store patient person_id from powerchart
DECLARE PERSON_ID_VAR                           = F8 WITH CONSTANT(REQUEST->PERSON[1].PERSON_ID), PROTECT

; Store Code value for DVA GOLD
DECLARE DVA_GOLD_CD_VAR                         = F8 WITH CONSTANT(4039501.00)
; Create a placeholder variable for the DVA GOLD value retrieved from the database
DECLARE DVA_GOLD_VAR                             = VC WITH NOCONSTANT("")

; Store Code value for Safety Net Concession Card
DECLARE SAFETY_NET_CONCESSION_CD_VAR            = F8 WITH CONSTANT(4081892.00)
; Create a placeholder variable for the Safety Net Concession Card value retrieved from the database
DECLARE SAFETY_NET_CONCESSION_VAR               = VC WITH NOCONSTANT("")

; Store Code value for Safety Net Entitlement Card
DECLARE SAFETY_NET_ENTITLEMENT_CD_VAR           = F8 WITH CONSTANT(10719999.00)
; Create a placeholder variable for the Safety Net Entitlement Card value retrieved from the database
DECLARE SAFETY_NET_ENTITLEMENT_VAR              = VC WITH NOCONSTANT("")

; Store Code value for DVA Number
DECLARE DVA_NUMBER_CD_VAR                       = F8 WITH CONSTANT(6797507.00)
; Create a placeholder variable for the DVA Number value retrieved from the database
DECLARE DVA_NUMBER_VAR                          = VC WITH NOCONSTANT("")

; Store Code value for Medicare No
DECLARE MEDICARE_NO_CD_VAR                      = F8 WITH CONSTANT(4039507.00)
; Create a placeholder variable for the Medicare No value retrieved from the database
DECLARE MEDICARE_NO_VAR                         = VC WITH NOCONSTANT("")

; Store Code value for Pension Concession Card
DECLARE PENSION_CONCESSION_CD_VAR               = F8 WITH CONSTANT(13079326.00)
; Create a placeholder variable for the Pension Concession Card value retrieved from the database
DECLARE PENSION_CONCESSION_VAR                  = VC WITH NOCONSTANT("")

; Store Code value for Healthcare Card
DECLARE HEALTHCARE_CARD_CD_VAR                  = F8 WITH CONSTANT(4081893.00)
; Create a placeholder variable for the Healthcare Card value retrieved from the database
DECLARE HEALTHCARE_CARD_VAR                     = VC WITH NOCONSTANT("")

; Store Code value for Pension - Other
DECLARE PENSION_OTHER_CD_VAR                    = F8 WITH CONSTANT(10726213.00)
; Create a placeholder variable for the Pension - Other value retrieved from the database
DECLARE PENSION_OTHER_VAR                       = VC WITH NOCONSTANT("")

; Store Code value for Commonwealth Seniors Health Card
DECLARE COMMONWEALTH_SENIORS_HEALTH_CD_VAR      = F8 WITH CONSTANT(6797508.00)
; Create a placeholder variable for the Commonwealth Seniors Health Card value retrieved from the database
DECLARE COMMONWEALTH_SENIORS_HEALTH_VAR         = VC WITH NOCONSTANT("")

; Store Code value for DVA WHITE
DECLARE DVA_WHITE_CD_VAR                        = F8 WITH CONSTANT(4039502.00)
; Create a placeholder variable for the DVA WHITE value retrieved from the database
DECLARE DVA_WHITE_VAR                           = VC WITH NOCONSTANT("")

; Store Code value for NDIS Participant Identifier
DECLARE NDIS_PARTICIPANT_IDENTIFIER_CD_VAR      = F8 WITH CONSTANT(174930721.00)
; Create a placeholder variable for the NDIS Participant Identifier value retrieved from the database
DECLARE NDIS_PARTICIPANT_IDENTIFIER_VAR         = VC WITH NOCONSTANT("")

/*
Alias Pool code from the ALIAS_POOL_CD column on the PERSON_ALIAS table
ALIAS_POOL_CD	ALIAS_POOL
    4039501.00	DVA GOLD
   13075331.00	Carer Payment Pension
    4455022.00	TAC
    4081892.00	Safety Net Concession Card
   14966006.00	Unemployment Related Benefits
   10719999.00	Safety Net Entitlement Card
    9569589.00	WHS UR Number
    6797507.00	DVA Number
   14966012.00	Emergency ID
    4039507.00	Medicare No
   13079326.00	Pension Concession Card
  174930721.00	NDIS Participant Identifier
   13079325.00	Disability Support Pension
    4081893.00	Healthcare Card
  152031769.00	CONSUMER_MESSAGING
   10726213.00	Pension - Other
    4443217.00	Work Cover
    6797508.00	Commonwealth Seniors Health Card
    4039502.00	DVA WHITE
*/

/* LIST TO INCLUDE
Alias Pool code from the ALIAS_POOL_CD column on the PERSON_ALIAS table
ALIAS_POOL_CD	ALIAS_POOL
    4039501.00	DVA GOLD
    4081892.00	Safety Net Concession Card
   10719999.00	Safety Net Entitlement Card
    6797507.00	DVA Number
    4039507.00	Medicare No
   13079326.00	Pension Concession Card
    4081893.00	Healthcare Card
   10726213.00	Pension - Other
    6797508.00	Commonwealth Seniors Health Card
    4039502.00	DVA WHITE
    174930721.00	NDIS Participant Identifier
*/

; Get Concession - DVA Gold
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = DVA_GOLD_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    DVA_GOLD_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; Get Concession - Safety Net Concession Card
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = SAFETY_NET_CONCESSION_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    SAFETY_NET_CONCESSION_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; Get Concession - Safety Net Entitlement Card
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = SAFETY_NET_ENTITLEMENT_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    SAFETY_NET_ENTITLEMENT_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; Get Concession - DVA Number
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = DVA_NUMBER_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    DVA_NUMBER_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; Get Concession - Medicare No
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = MEDICARE_NO_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    MEDICARE_NO_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; Get Concession - Pension Concession Card
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = PENSION_CONCESSION_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    PENSION_CONCESSION_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; Get Concession - Healthcare Card
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = HEALTHCARE_CARD_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    HEALTHCARE_CARD_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; Get Concession - Pension - Other
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = PENSION_OTHER_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    PENSION_OTHER_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; Get Concession - Commonwealth Seniors Health Card
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = COMMONWEALTH_SENIORS_HEALTH_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    COMMONWEALTH_SENIORS_HEALTH_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; Get Concession - DVA WHITE
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = DVA_WHITE_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    DVA_WHITE_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000


; Get Concession - NDIS Participant Identifier
SELECT INTO "NL:"
    ALIAS = PA.ALIAS
FROM
    PERSON_ALIAS PA
WHERE
        PA.PERSON_ID = PERSON_ID_VAR
    AND PA.ALIAS_POOL_CD = NDIS_PARTICIPANT_IDENTIFIER_CD_VAR
    AND PA.ACTIVE_IND = 1
DETAIL
    NDIS_PARTICIPANT_IDENTIFIER_VAR = TRIM(ALIAS, 3)
WITH
    TIME = 5, maxcol = 1000000

; DISPLAY THE DATA ON THE FRONT END
CALL APPLYFONT(ACTIVE_FONTS->NORMAL)

; Display Safety Net Concession Card only if it exists
IF(TEXTLEN(SAFETY_NET_CONCESSION_VAR) > 1)
    CALL PRINTTEXT("Safety Net Concession Card: ",0,0,0)
    CALL PRINTTEXT(BUILD2(SAFETY_NET_CONCESSION_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display Safety Net Entitlement Card only if it exists
IF(TEXTLEN(SAFETY_NET_ENTITLEMENT_VAR) > 1)
    CALL PRINTTEXT("Safety Net Entitlement Card: ",0,0,0)
    CALL PRINTTEXT(BUILD2(SAFETY_NET_ENTITLEMENT_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display DVA Number only if it exists
IF(TEXTLEN(DVA_NUMBER_VAR) > 1)
    CALL PRINTTEXT("DVA Number: ",0,0,0)
    CALL PRINTTEXT(BUILD2(DVA_NUMBER_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display DVA WHITE only if it exists
IF(TEXTLEN(DVA_WHITE_VAR) > 1)
    CALL PRINTTEXT("DVA WHITE: ",0,0,0)
    CALL PRINTTEXT(BUILD2(DVA_WHITE_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display DVA GOLD only if it exists
IF(TEXTLEN(DVA_GOLD_VAR) > 1)
    CALL PRINTTEXT("DVA GOLD: ",0,0,0)
    CALL PRINTTEXT(BUILD2(DVA_GOLD_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display Medicare No only if it exists
IF(TEXTLEN(MEDICARE_NO_VAR) > 1)
    CALL PRINTTEXT("Medicare No: ",0,0,0)
    CALL PRINTTEXT(BUILD2(MEDICARE_NO_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display Pension Concession Card only if it exists
IF(TEXTLEN(PENSION_CONCESSION_VAR) > 1)
    CALL PRINTTEXT("Pension Concession Card: ",0,0,0)
    CALL PRINTTEXT(BUILD2(PENSION_CONCESSION_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display Pension - Other only if it exists
IF(TEXTLEN(PENSION_OTHER_VAR) > 1)
    CALL PRINTTEXT("Pension - Other: ",0,0,0)
    CALL PRINTTEXT(BUILD2(PENSION_OTHER_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display Healthcare Card only if it exists
IF(TEXTLEN(HEALTHCARE_CARD_VAR) > 1)
    CALL PRINTTEXT("Healthcare Card: ",0,0,0)
    CALL PRINTTEXT(BUILD2(HEALTHCARE_CARD_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display Commonwealth Seniors Health Card only if it exists
IF(TEXTLEN(COMMONWEALTH_SENIORS_HEALTH_VAR) > 1)
    CALL PRINTTEXT("Commonwealth Seniors Health Card: ",0,0,0)
    CALL PRINTTEXT(BUILD2(COMMONWEALTH_SENIORS_HEALTH_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Display NDIS Participant Identifier only if it exists
IF(TEXTLEN(NDIS_PARTICIPANT_IDENTIFIER_VAR) > 1)
    CALL PRINTTEXT("NDIS Participant Identifier: ",0,0,0)
    CALL PRINTTEXT(BUILD2(NDIS_PARTICIPANT_IDENTIFIER_VAR),0,0,0)
    CALL NEXTLINE(1)
ENDIF

; Send the text to Output
CALL FINISHTEXT(0)
SET REPLY->TEXT = RTF_OUT->TEXT

END
GO