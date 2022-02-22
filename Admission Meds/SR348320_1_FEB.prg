SELECT DISTINCT
	O.ENCNTR_ID ; encounter id
	, O.PERSON_ID ; patient for whom it was ordered for
	, ORDER_DATE_TIME = FORMAT(O.ORIG_ORDER_DT_TM, "YYYY-MM-DD HH:MM:SS") ; order date time
	, E_LOC_FACILITY_DISP = UAR_GET_CODE_DISPLAY(E.LOC_FACILITY_CD) ; Footscray or Sunshine
	, E_MED_SERVICE_DISP = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD) ; CLINICAL UNIT
	, pharmacy_cd = O.CATALOG_CD ; Code for the item ordered
	, O_CATALOG_DISP = UAR_GET_CODE_DISPLAY(O.CATALOG_CD) ; name of the item ordered

FROM
	ORDERS   O
	; , (LEFT JOIN PERSON P ON (P.PERSON_ID = O.PERSON_ID)) ; Join this table to get the patients name etc
	, (INNER JOIN ENCOUNTER E ON (E.ENCNTR_ID = O.ENCNTR_ID))

PLAN 
	O 
	WHERE
		(O.ORIG_ORDER_DT_TM BETWEEN 
			CNVTDATETIME("01-FEB-2021 00:00:00.00")
			AND
			; CNVTDATETIME("02-FEB-2021 00:00:00.00") ; use this for a quick look at the data
			CNVTDATETIME("01-AUG-2021 00:00:00.00") ; full range of customer request
		) ; Date range filter above
		AND
		O.CATALOG_TYPE_CD = 2516 ; Filters for only 'Pharmacy'
		AND
		O.ORDER_STATUS_CD = 2543 ; Filters for only 'Completed' order status'
; JOIN P
JOIN E
	WHERE(
		E.ENCNTR_TYPE_CD = 309308 ; Only inpatient encounters
		AND(
		E.LOC_BUILDING_CD = 86164609 ; Sunshine Location
		OR
		E.LOC_BUILDING_CD = 85758827 ; Footscray Location
		)
	)
ORDER BY ; the order by part here is  used for the distinct parameters
	O.ENCNTR_ID
	, O.CATALOG_CD
	, 0
WITH MAXREC = 1000000000, NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 600

/* NOTES
REQUEST
Can you please generate the average number of inpatient medicines
charted on admission for inpatients under FH (IMFA-D) and
SH Gen Med units (IMSA-D)? from 1/2/21-31/7/21? A monthly
breakdown across each of the 8 units would be helpful.
 */