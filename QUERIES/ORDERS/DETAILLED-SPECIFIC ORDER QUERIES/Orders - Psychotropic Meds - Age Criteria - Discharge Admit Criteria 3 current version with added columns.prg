drop program wh_bigfile_out go
create program wh_bigfile_out

prompt
	"Output to File/Printer/MINE" = "SR867924_output_v2.csv"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV

SELECT DISTINCT INTO "CUST_SCRIPT:SR867924_output_v2.csv"

	PATIENT_NAME = "REQUEST TO UNHIDE";P.NAME_FULL_FORMATTED
	, PATIENT_URN = P_A.ALIAS
    , SEX = UAR_GET_CODE_DISPLAY(P.SEX_CD)
    , LANGUAGE = UAR_GET_CODE_DISPLAY(P.LANGUAGE_CD)
    , FIRST_4AT_RISK_SCORE = C.SCORE; 4AT Risk Score in adult risk assessments (fluid interactive view)
    , PATIENT_DOB = DATEBIRTHFORMAT(P.BIRTH_DT_TM, P.BIRTH_TZ, P.BIRTH_PREC_FLAG,"DD-MMM-YYYY")
	, AGE_AT_ORDER = CNVTAGE(P.BIRTH_DT_TM, O.ORIG_ORDER_DT_TM,0)
    , ENCOUNTER_FIN = E_A.ALIAS
    , E.ARRIVE_DT_TM "YYYY-MM-DD HH:MM:SS" ; THIS ENCOUNTER TIME IS SHOWN IN POWERCHART
    , E.DISCH_DT_TM "YYYY-MM-DD HH:MM:SS" ; THIS ENCOUNTER TIME IS SHOWN IN POWERCHART
	, ITEM_ORDERED = O.ORDER_MNEMONIC

    , CLASS =
        IF (OCS.SYNONYM_ID IN (
            /* ADHD */
            9748016,    /* atomoxetine */
            9754916,    /* methYLPHENIDATe */
            85749762    /* guanfacine */
        )) "ADHD"

        ELSEIF (OCS.SYNONYM_ID IN (
            /* Dependence */
            9751907,    /* naloxone */
            9751036,    /* bupropion */
            9754991,    /* methADONe */
            9758705,    /* acamprosate */
            9753379,    /* naltrexone */
            9758445,    /* disulfiram */
            9763304,    /* nicotine */
            9763801,    /* varenicline */
            124216261,  /* naloxone infusion */
            64305486    /* naltrexone-bupropion */
        )) "Dependence"

        ELSEIF (OCS.SYNONYM_ID IN (
            /* Bipolar */
            9748269     /* lithium */
        )) "Bipolar"

        ELSEIF (OCS.SYNONYM_ID IN (
            /* Sleep Anxiety */
            64305260,   /* lemborexant */
            9746903,    /* flunitrazepam */
            9749396,    /* DIAzepam */
            9754696,    /* LORazepam */
            9750257,    /* bromazepam */
            9751629,    /* cloBAZam */
            9754324,    /* nitrazepam */
            9755108,    /* OXazepam */
            9752384,    /* modafinil */
            9759362,    /* alprazolam */
            9761903,    /* temazepam */
            9765314,    /* zolpidem */
            9767960,    /* zopiclone */
            12906896,   /* melatonin */
            86492772,   /* armodafinil */
            87777529    /* suvorexant */
        )) "Sleep Anxiety"

        ELSEIF (OCS.SYNONYM_ID IN (
            /* Antidepressants */
            82335361,   /* vortioxetine */
            9748536,    /* escitalopram */
            9743906,    /* fluVOXAMine */
            10410096,   /* desvenlafaxine */
            9744810,    /* imipramine */
            9743088,    /* fluoxetine */
            9751079,    /* doSULepin (doTHiepin) */
            9753675,    /* mirtazapine */
            9752828,    /* mianserin */
            9751281,    /* citalopram */
            9749515,    /* DULoxetine */
            9756441,    /* nortriptyline */
            9758811,    /* cLOMIPRAMine */
            9755441,    /* moclobemide */
            9761288,    /* PARoxetine */
            9756552,    /* amiTRIPTYLine */
            9765477,    /* venlafaxine */
            9758753,    /* doXepin */
            9762324,    /* reboxetine */
            9764249,    /* tranylcypromine */
            9764052,    /* SERTRALine */
            15133808    /* agomelatine */
        )) "Antidepressants"

        ELSEIF (OCS.SYNONYM_ID IN (
            /* Anticholinergics Opioids (O) */
            125595401,
            9768276,
            9888934,
            9888981,
            14814595,
            124197910,
            124197977,
            124210774,
            124211307,
            9888902,
            124211360,
            124216194,
            10410018,
            10410033,
            10410063,
            10410081,
            10410084,
            10410105,
            124216229,
            152317131,
            152317155,
            152317435,
            152317437,
            152316875,
            152316887,
            152317007,
            152317029,
            152316877,
            152316883,
            152316987,
            152317071,
            152317077,
            152317089,
            152317109,
            152317135,
            152317409,
            152317413,
            152317423,
            152317123,
            124216210,
            124204847,
            9743078,
            9750783,
            9754991,
            9750855,
            9758897,
            79419432,
            9760585,
            9753358,
            9759965,
            9758361,
            9756289,
            9757172,
            9755918,
            9762367,
            9762722,
            9757694,
            124197734,
            124197803,
            124197841,
            9766432,
            9764135,
            9766440,
            9768458,
            9888786,
            124198021,
            9763793,
            9766946,
            9766921,
            226916807,
            16869765,
            226912327,
            226917367,
            226917753,
            20213931,
            201533059,
            201528157,
            64305408,
            91044838,
            305004721
        )) "Anticholinergics Opioids (O)"

        ELSEIF (OCS.SYNONYM_ID IN (
            /* Anticholinergics Opioids (AC) */
            124234464,
            9767559,
            9768300,
            9819799,
            9848336,
            82821064,
            80770746,
            9842152,
            82139958,
            9888783,
            9888880,
            80808516,
            9888941,
            125968268,
            9888821,
            9888849,
            9888975,
            9745529,
            9748719,
            82135837,
            10410030,
            10410036,
            10410072,
            10410093,
            10410234,
            124233909,
            124198028,
            140834362,
            80767685,
            80765845,
            124316040,
            124198001,
            124316073,
            9744810,
            124233923,
            9746940,
            9745257,
            9749572,
            9750850,
            9750826,
            9750824,
            9750345,
            9744607,
            9744533,
            125969239,
            9753942,
            9751079,
            9754555,
            9752828,
            9750496,
            9752511,
            9751132,
            9751371,
            9749868,
            138629717,
            9756464,
            9756441,
            9757239,
            9758811,
            9757210,
            9759835,
            9760770,
            9754960,
            9755472,
            9761239,
            9761288,
            9756552,
            9763143,
            9756296,
            9759114,
            9759000,
            9757754,
            9755339,
            9762209,
            9761903,
            9766047,
            9766220,
            9763187,
            9761758,
            9760232,
            9758753,
            9756077,
            9760179,
            9762650,
            9766409,
            9766008,
            9764366,
            9764971,
            9766132,
            9764744,
            9763200,
            9761418,
            9763986,
            9765799,
            9764922,
            9761185,
            9767877,
            9768167,
            92678984,
            64304174,
            125967782,
            125969863,
            124197552,
            9768966,
            9768776,
            9766191,
            9767164,
            9768055,
            163592033,
            124234323,
            124234471,
            124234479,
            21714436,
            45226846,
            64304212,
            64305489,
            64305079,
            64305065,
            91044844
        )) "Anticholinergics Opioids (AC)"

        ELSEIF (OCS.SYNONYM_ID IN (
            /* Anticholinergics Opioids (AC-O) */
            9888918,
            82140450,
            9889010,
            9888998,
            9854604,
            9744390,
            10410087,
            149149086,
            10410231,
            147920479,
            148230931,
            124211486,
            152935661,
            9763463,
            9763322,
            9766310,
            9765750,
            9763060,
            9767612,
            9769068,
            9769224,
            9889245,
            9768515,
            9768133,
            124211536,
            9767166,
            147920402,
            64305093
        )) "Anticholinergics Opioids (AC-O)"

        ELSE "NOT FOUND"
        ENDIF

	, ORDERED_TIME = O.ORIG_ORDER_DT_TM "DD-MMM-YYYY HH:MM:SS;;D"
	, SERVICE = UAR_GET_CODE_DISPLAY(E.MED_SERVICE_CD)
    , ENCOUNTER_TYPE = UAR_GET_CODE_DISPLAY(E.ENCNTR_TYPE_CD)
    ;, ORDERED_BY = PR.NAME_FULL_FORMATTED

FROM
	  ORDERS                O
	, ORDER_CATALOG_SYNONYM	OCS
	, ENCOUNTER             E
    ;, PRSNL                 PR
    , PERSON				P
    , PERSON_ALIAS          P_A
    , ENCNTR_ALIAS          E_A
    ;, ORDER_ACTION          	O_A
    /*
    Below is the inline clinical event table with ranked 4at scores
    that were updated after the 1st of June 2023. They are ranked
    by the event end date time in ascending order.
     */

	, (
		(
			SELECT
				TIME_RANK = RANK() OVER(PARTITION BY C_TEMP.ENCNTR_ID ORDER BY C_TEMP.EVENT_END_DT_TM ASC)
				, ENCOUNTER_ID = C_TEMP.ENCNTR_ID
				, SCORE = C_TEMP.RESULT_VAL
			FROM
				CLINICAL_EVENT C_TEMP
            WHERE
                C_TEMP.EVENT_CD = 109971106.00	;4AT Risk Score
                AND C_TEMP.VIEW_LEVEL = 1
                AND C_TEMP.UPDT_DT_TM > CNVTDATETIME("01-JUN-2023 00:00")
            ORDER BY
				C_TEMP.ENCNTR_ID
				, C_TEMP.EVENT_END_DT_TM
			WITH SQLTYPE("F8","F8","VC")
		)
											C
	)

PLAN E ; ENCOUNTER
	WHERE
        E.ACTIVE_IND = 1
        /* Not "DEMO 1 HOSPITAL" Removes Fake Data From The Demo Hospital */
        AND E.LOC_FACILITY_CD != 4038465.00
        AND E.ARRIVE_DT_TM > CNVTDATETIME("01-JUN-2023 00:00")
        AND E.DISCH_DT_TM < CNVTDATETIME("01-JUN-2024 00:00")
        ; PEOPLE BORN AFTER
        AND E.PERSON_ID = (SELECT I.PERSON_ID FROM PERSON I WHERE I.BIRTH_DT_TM < CNVTDATETIME("01-JUN-1958"))

JOIN C ; CLINICAL_EVENT ; outer joining the inline clinical event table with the 4at score
    WHERE C.ENCOUNTER_ID = OUTERJOIN(E.ENCNTR_ID)
        AND C.TIME_RANK = OUTERJOIN(1)

JOIN O ; ORDERS
	WHERE O.ENCNTR_ID = E.ENCNTR_ID
    /* Time filter */
    	AND O.ORIG_ORDER_DT_TM >=  CNVTDATETIME("01-JUN-2023 00:00")
    	AND O.ORIG_ORDER_DT_TM <= CNVTDATETIME("01-JUN-2024 00:00")
        AND O.ORDER_STATUS_CD =        2543.00; Completed orders only

JOIN OCS ;ORDER_CATALOG_SYNONYM
	WHERE OCS.CATALOG_CD = O.CATALOG_CD
AND OCS.SYNONYM_ID IN
    (
        /* ADHD */
        9748016,
        9754916,
        85749762,

        /* Dependence */
        9751907,
        9751036,
        9754991,
        9758705,
        9753379,
        9758445,
        9763304,
        9763801,
        124216261,
        64305486,

        /* Bipolar */
        9748269,

        /* Sleep Anxiety */
        64305260,
        9746903,
        9749396,
        9754696,
        9750257,
        9751629,
        9754324,
        9755108,
        9752384,
        9759362,
        9761903,
        9765314,
        9767960,
        12906896,
        86492772,
        87777529,

        /* Antidepressants */
        82335361,
        9748536,
        9743906,
        10410096,
        9744810,
        9743088,
        9751079,
        9753675,
        9752828,
        9751281,
        9749515,
        9756441,
        9758811,
        9755441,
        9761288,
        9756552,
        9765477,
        9758753,
        9762324,
        9764249,
        9764052,
        15133808,

        /* Anticholinergics Opioids (O) */
        125595401,
        9768276,
        9888934,
        9888981,
        14814595,
        124197910,
        124197977,
        124210774,
        124211307,
        9888902,
        124211360,
        124216194,
        10410018,
        10410033,
        10410063,
        10410081,
        10410084,
        10410105,
        124216229,
        152317131,
        152317155,
        152317435,
        152317437,
        152316875,
        152316887,
        152317007,
        152317029,
        152316877,
        152316883,
        152316987,
        152317071,
        152317077,
        152317089,
        152317109,
        152317135,
        152317409,
        152317413,
        152317423,
        152317123,
        124216210,
        124204847,
        9743078,
        9750783,
        9754991,
        9750855,
        9758897,
        79419432,
        9760585,
        9753358,
        9759965,
        9758361,
        9756289,
        9757172,
        9755918,
        9762367,
        9762722,
        9757694,
        124197734,
        124197803,
        124197841,
        9766432,
        9764135,
        9766440,
        9768458,
        9888786,
        124198021,
        9763793,
        9766946,
        9766921,
        226916807,
        16869765,
        226912327,
        226917367,
        226917753,
        20213931,
        201533059,
        201528157,
        64305408,
        91044838,
        305004721,

        /* Anticholinergics Opioids (AC) */
        124234464,
        9767559,
        9768300,
        9819799,
        9848336,
        82821064,
        80770746,
        9842152,
        82139958,
        9888783,
        9888880,
        80808516,
        9888941,
        125968268,
        9888821,
        9888849,
        9888975,
        9745529,
        9748719,
        82135837,
        10410030,
        10410036,
        10410072,
        10410093,
        10410234,
        124233909,
        124198028,
        140834362,
        80767685,
        80765845,
        124316040,
        124198001,
        124316073,
        9744810,
        124233923,
        9746940,
        9745257,
        9749572,
        9750850,
        9750826,
        9750824,
        9750345,
        9744607,
        9744533,
        125969239,
        9753942,
        9751079,
        9754555,
        9752828,
        9750496,
        9752511,
        9751132,
        9751371,
        9749868,
        138629717,
        9756464,
        9756441,
        9757239,
        9758811,
        9757210,
        9759835,
        9760770,
        9754960,
        9755472,
        9761239,
        9761288,
        9756552,
        9763143,
        9756296,
        9759114,
        9759000,
        9757754,
        9755339,
        9762209,
        9761903,
        9766047,
        9766220,
        9763187,
        9761758,
        9760232,
        9758753,
        9756077,
        9760179,
        9762650,
        9766409,
        9766008,
        9764366,
        9764971,
        9766132,
        9764744,
        9763200,
        9761418,
        9763986,
        9765799,
        9764922,
        9761185,
        9767877,
        9768167,
        92678984,
        64304174,
        125967782,
        125969863,
        124197552,
        9768966,
        9768776,
        9766191,
        9767164,
        9768055,
        163592033,
        124234323,
        124234471,
        124234479,
        21714436,
        45226846,
        64304212,
        64305489,
        64305079,
        64305065,
        91044844,

        /* Anticholinergics Opioids (AC-O) */
        9888918,
        82140450,
        9889010,
        9888998,
        9854604,
        9744390,
        10410087,
        149149086,
        10410231,
        147920479,
        148230931,
        124211486,
        152935661,
        9763463,
        9763322,
        9766310,
        9765750,
        9763060,
        9767612,
        9769068,
        9769224,
        9889245,
        9768515,
        9768133,
        124211536,
        9767166,
        147920402,
        64305093
    )

/* Patient Identifiers such as URN Medicare no etc */
JOIN P_A;PERSON_ALIAS; PATIENT_URN = P_A.ALIAS
    WHERE P_A.PERSON_ID = E.PERSON_ID
        AND
        /* this filters for the UR Number Alias' only */
        P_A.ALIAS_POOL_CD = 9569589.00
        AND
        /* Effective Only */
        P_A.END_EFFECTIVE_DT_TM >CNVTDATETIME(CURDATE, curtime3)
        AND
        /* Active Only */
        P_A.ACTIVE_IND = 1
        /* Patient URN */
        ; AND
        ; P_A.ALIAS = "ENTERURN#" ; ENTER URN!

/* Patients */
JOIN P;PERSON
	WHERE P.PERSON_ID = E.PERSON_ID
        /* Remove Inactive Patients */
        AND P.ACTIVE_IND = 1
        /* Remove Fake 'Test' Patients */
        AND P.NAME_LAST_KEY != "*TESTWHS*"
        /* Remove Ineffective Patients */
        AND P.END_EFFECTIVE_DT_TM > SYSDATE
        ; Over >=65 on the 1st of june 2023
        AND P.BIRTH_DT_TM < CNVTDATETIME("02-JUN-1958")

/* Encounter Identifiers such as the Financial Number */
JOIN E_A;ENCNTR_ALIAS; ENCOUNTER_NO = E_A.ALIAS
    WHERE E_A.ENCNTR_ID = E.ENCNTR_ID
        /*  'FIN/ENCOUNTER/VISIT NBR' from code set 319 */
        AND E_A.ENCNTR_ALIAS_TYPE_CD = 1077
        /* active FIN NBRs only */
        AND E_A.ACTIVE_IND = 1
        /* effective FIN NBRs only */
        AND E_A.END_EFFECTIVE_DT_TM > SYSDATE

ORDER BY
    O.PERSON_ID
	, O.ORDER_ID
    , 0

WITH
    TIME = 3600
	, PCFORMAT (^"^, ^,^ , 1)
    , FORMAT = STREAM
	, FORMAT

end
go

/*
This is for SR867924
Customer: Stephanie Tran
Data Nov 26 2024
Programmer: Jason Whittle

changes; 13/02/2025 10:03 AM - Whittle, Jason: changes requested: Retrieving patient sex/gender, admission date, discharge date, and language spoken + first 4AT, would be of great help to our research team.

Request:
Good morning Digital Health Medication Team,

On behalf of can we please request for an EMR report with the following:
·Patients aged 65 years and over
·Admitted/discharged June 2023 – June 2024
·Patients with order of any psychotropic listed (would you also be able to separate the data by psychotropic class as below):

ADHD:
9748016	atomoxetine
9754916	methYLPHENIDATe
85749762	guanfacine


Dependence:
9751907	naloxone
9751036	bupropion
9754991	methADONe
9758705	acamprosate
9753379	naltrexone
9758445	disulfiram
9763304	nicotine
9763801	varenicline
124216261	naloxone infusion 2 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS (CRIT CARE)
64305486	naltrexone-bupropion


Bipolar:
9748269	lithium


Sleep Anxiety:
64305260	lemborexant
9746903	flunitrazepam
9749396	DIAzepam
9754696	LORazepam
9750257	bromazepam
9751629	cloBAZam
9754324	nitrazepam
9755108	OXazepam
9752384	modafinil
9759362	alprazolam
9761903	temazepam
9765314	zolpidem
9767960	zopiclone
12906896	melatonin
86492772	armodafinil
87777529	suvorexant


Antidepressants:
82335361	vortioxetine
9748536	escitalopram
9743906	fluVOXAMine
10410096	desvenlafaxine
9744810	imipramine
9743088	fluoxetine
9751079	doSULepin (doTHiepin)
9753675	mirtazapine
9752828	mianserin
9751281	citalopram
9749515	DULoxetine
9756441	nortriptyline
9758811	cLOMIPRAMine
9755441	moclobemide
9761288	PARoxetine
9756552	amiTRIPTYLine
9765477	venlafaxine
9758753	doXepin
9762324	reboxetine
9764249	tranylcypromine
9764052	SERTRALine
15133808	agomelatine


Anticholinergics Opioids (O):
125595401	fentanyl infusion 1000 MICROg in Sodium Chloride 0.9% 100 mL CONTINUOUS (CRIT CARE)
9768276	paracetamol-codeine
9888934	benzocaine/cetylpyridinium/dextromethorphan/menthol
9888981	fentanyl
14814595	codeine/aluminium hydroxide/kaolin/pectin
124197910	fentanyl (PCA) infusion 15 MICROg/kg in Sodium Chloride 0.9% 100 mL CONTINUOUS - PAED (10-50kg)
124197977	fentanyl infusion 1000 MICROg in Sodium Chloride 0.9% 100 mL CONTINUOUS
124210774	morphine (PCA) infusion 100 mg in Sodium Chloride 0.85% 100 mL CONTINUOUS
124211307	morphine infusion 1 mg/kg in Sodium Chloride 0.9% 100 mL CONTINUOUS - PAED (10-50kg)
9888902	aspirin-dihydrocodeine
124211360	morphine infusion 100 mg in Sodium Chloride 0.85% 100 mL CONTINUOUS
124216194	morphine 120mg-midazolam 120mg infusion in Sodium Chloride 0.9% 120 mL CONTINUOUS (CRIT CARE)
10410018	benzydamine/cetylpyridinium/pholcodine
10410033	pholcodine-bromhexine
10410063	pholcodine-cetylpyridinium chloride
10410081	paracetamol/codeine/doxylamine
10410084	paracetamol/codeine/phenylephrine
10410105	dextromethorphan-phenylephrine
124216229	morphine infusion 100 mg in Sodium Chloride 0.85% 100 mL CONTINUOUS (CRIT CARE)
152317131	morphine infusion 100 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS
152317155	morphine (PCA) infusion 100 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS
152317435	morphine infusion NEO QUAD (2 mg/kg in 25 mL) in Glucose 10%
152317437	FENTanyl infusion NEO QUAD (200 MICROg/kg in 25 mL) in Glucose 5%
152316875	morphine infusion 250 mg in Sodium Chloride 0.9% 250 mL CONTINUOUS (CRIT CARE)
152316887	FENTanyl infusion NEO SINGLE (50 MICROg/kg in 25 mL) in Sodium Chloride 0.9%
152317007	FENTanyl infusion NEO SINGLE (50 MICROg/kg in 25 mL) in Glucose 10%
152317029	morphine infusion NEO SINGLE (0.5 mg/kg in 25 mL) in Sodium Chloride 0.9%
152316877	morphine infusion NEO SINGLE (0.5 mg/kg in 25 mL) in Glucose 10%
152316883	morphine infusion NEO DOUBLE (1 mg/kg in 25 mL) in Sodium Chloride 0.9%
152316893	FENTanyl infusion NEO SINGLE (50 MICROg/kg in 25 mL) in Glucose 5%
152316987	morphine infusion NEO DOUBLE (1 mg/kg in 25 mL) in Glucose 5%
152317071	FENTanyl infusion NEO DOUBLE (100 MICROg/kg in 25 mL) in Glucose 10%
152317077	morphine infusion  NEO QUAD (2 mg/kg in 25 mL) in Glucose 5%
152317089	FENTanyl infusion NEO QUAD (200 MICROg/kg in 25 mL) in Glucose 10%
152317109	morphine infusion NEO DOUBLE (1 mg/kg in 25 mL) in Glucose 10%
152317135	morphine infusion NEO SINGLE (0.5 mg/kg in 25 mL) in Glucose 5%
152317409	FENTanyl infusion NEO DOUBLE (100 MICROg/kg in 25 mL) in Sodium Chloride 0.9%
152317413	FENTanyl infusion NEO QUAD (200 MICROg/kg in 25 mL) in Sodium Chloride 0.9%
152317423	FENTanyl infusion NEO DOUBLE (100 MICROg/kg in 25 mL) in Glucose 5%
152317123	morphine infusion 100 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS (CRIT CARE)
124216210	morphine infusion 1 mg/kg in Glucose 5% 50 mL CONTINUOUS - PAED (CRIT CARE)
124204847	morphine (PCA) infusion 1 mg/kg in Sodium Chloride 0.9% 100 mL CONTINUOUS - PAED (10-50kg)
9743078	HYDROmorphone
9750783	codeine
9754991	methADONe
9750855	buprenorphine-naloxone
9758897	dextropropoxyphene-paracetamol
79419432	tAPENTadol
9760585	oxycodone
9753358	morphine liposomal
9759965	bupivacaine-fentanyl
9758361	dextropropoxyphene napsilate
9756289	buprenorphine
9757172	dihydrocodeine
9755918	morphine
9762367	pholcodine
9762722	pethidine
9757694	aspirin-codeine
124197734	buprenorphine (PCA) infusion 1800 MICROg in Sodium Chloride 0.9% 90 mL CONTINUOUS
124197803	buprenorphine infusion 1800 MICROg in Sodium Chloride 0.9% 90 mL CONTINUOUS
124197841	fentanyl (PCA) infusion 1000 MICROg in Sodium Chloride 0.9% 100 mL CONTINUOUS
9766432	guaifenesin-dextromethorphan
9764135	ropivacaine-fentanyl
9766440	dextromethorphan
9768458	ibuprofen-codeine
9769047	alfentanil
9888786	morphine-hydrogel topical
124198021	fentanyl infusion 15 MICROg/kg in Sodium Chloride 0.9% 100 mL CONTINUOUS - PAED (10-50kg)
9763793	remifentanil
9766946	paracetamol/dextromethorphan/doxylamine
9766921	paracetamol/phenylephrine/dextromethorphan
226916807	oxycodone (PCA) infusion 100 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS
16869765	oxycodone-naloxone
226912327	hydromorphone infusion 20 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS
226917367	oxycodone infusion 100 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS
226917753	hydromorphone (PCA) infusion 20 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS
20213931	pholcodine-phenylephrine
201533059	morphine 100 mg-midazolam 100 mg infusion in Sodium Chloride 0.9% 100 mL CONTINUOUS (CRIT CARE)
201528157	morphine 50 mg-midazolam 50 mg infusion in Sodium Chloride 0.9% 50 mL CONTINUOUS (CRIT CARE)
64305408	codeine-ethylmorphine
91044838	morphine-midazolam
305004721	FENTanyl infusion 1000 MICROg in Glucose 5% 100 mL CONTINUOUS (CRIT CARE)


Anticholinergics Opioids (AC):
124234464	ranitidine IV infusion 1.5 mg/kg in Sodium Chloride 0.9%, 8 hourly - NEONATE
9767559	fexofenadine-pseudoephedrine
9768300	pseudoephedrine-chlorphenamine
9819799	haloperidol
9848336	cyclopentolate ophthalmic
82821064	tiotropium-olodaterol
80770746	indacaterol-glycopyrronium
9842152	hyoscine
82139958	pseudoephedrine/paracetamol/triprolidine
9888783	belladonna/chlorphenamine/codeine/paracetamol/pseudoephedrine
9888880	atropine/hyoscine/hyoscyamine
80808516	umeclidinium
9888941	ascorbic acid/aspirin/chlorphenamine/phenylephrine
125968268	cinnarizine-dimenhydrinate
9888821	diphenhydramine/ammonium chloride/sodium citrate
9888849	zuclopenthixol
9888975	atropine/hyoscine/hyoscyamine/kaolin
9745529	ipratropium
9748719	fluphenazine
82135837	paracetamol/codeine/pseudoephedrine/triprolidine
10410030	bromhexine/guaifenesin/pseudoephedrine
10410036	bromhexine-pseudoephedrine
10410072	paracetamol/codeine/pseudoephedrine/chlorphenamine
10410093	codeine/dexchlorpheniramine/paracetamol/pseudoephedrine
10410234	pholcodine-pseudoephedrine
124233909	ranitidine IV infusion 0.5 mg/kg in Glucose 5%, 12 hourly - NEONATE
124198028	cHLORPROMAZine infusion 25 mg in Sodium Chloride 0.9% 500 mL BAG BY BAG
140834362	buDESONide/glycopyrronium/formoterol
80767685	umeclidinium-vilanterol
80765845	aclidinium
124316040	ranitidine IV infusion 0.5 mg/kg in Glucose 10%, 12 hourly - NEONATE
124198001	cHLORPROMAZine infusion 12.5 mg in Sodium Chloride 0.9% 500 mL BAG BY BAG
124316073	ranitidine IV infusion 1.5 mg/kg in Glucose 10%, 8 hourly - NEONATE
9744810	imipramine
124233923	ranitidine IV infusion 0.5 mg/kg in Sodium Chloride 0.9%, 12 hourly - NEONATE
9746940	fexofenadine
9745257	ipratropium-salbutamol
9749572	paracetamol/pseudoephedrine/chlorphenamine maleate
9750850	cHLORPROMAZine
9750826	atropine ophthalmic
9750824	cyproheptadine
9750345	darifenacin
9744607	ipratropium nasal
9744533	glycopyrronium
125969239	glycopyrronium-neostigmine
9753942	loperamide
9751079	doSULepin (doTHiepin)
9754555	naphazoline-pheniramine ophthalmic
9752828	mianserin
9750496	CARBAMazepine
9752511	loratadine-pseudoephedrine
9751132	cycLIZINE
9751371	clozapine
9749868	cetirizine
138629717	hyoscine butylbromide
9756464	periciazine
9756441	nortriptyline
9757239	baclofen
9758811	cLOMIPRAMine
9757210	trihexyphenidyl (benzhexol)
9759835	atropine
9760770	pseudoephedrine
9754960	OXCARBazepine
9755472	QUETIAPine
9761239	oxybutynin
9761288	PARoxetine
9756552	amiTRIPTYLine
9763143	propantheline
9756296	olanzapine
9759114	benzatropine
9759000	theophylline
9757754	diSOPYRAMIDe
9755339	pizotifen
9762209	diphenhydramine
9761903	temazepam
9766047	dexchlorpheniramine
9766220	chlorphenamine-phenylephrine
9763187	brompheniramine-phenylephrine
9761758	tropicamide ophthalmic
9760232	tiotropium
9758753	doXepin
9756077	orphenadrine-paracetamol
9760179	paracetamol-pseudoephedrine
9762650	ranitidine
9766409	amantadine
9766008	chlorphenamine-paracetamol
9764366	pheniramine
9764971	trifluoperazine
9766132	ibuprofen-pseudoephedrine
9764744	dimenhydrinate
9763200	proCHLORPERazine
9761418	proMETHazine
9763986	pimozide
9765799	riSPERIDONe
9764922	tolterodine
9761185	orphenadrine
9767877	diphenhydramine-phenylephrine
9768167	loperamide-simethicone
92678984	fluticasone/umeclidinium/vilanterol
64304174	brompheniramine
125967782	beclometasone/formoterol/glycopyrronium
125969863	magnesium trisilicate/belladonna/magnesium carbonate/sodium bicarbonate
124197552	atropine infusion xx mg in Sodium Chloride 0.9% 1000 mL BAG BY BAG (CRIT CARE)
9768966	guaifenesin-pseudoephedrine
9768776	trimipramine
9766191	phenylephrine/paracetamol/chlorphenamine maleate
9767164	solifenacin
9768055	dimenhydrinate/hyoscine/caffeine
163592033	cHLORPROMAZine infusion 12.5 mg in Sodium Chloride 0.9% 100 mL BAG BY BAG
124234323	ranitidine IV infusion 1.5 mg/kg in Glucose 5%, 8 hourly - NEONATE
124234471	ranitidine IV infusion 25 mg in Sodium Chloride 0.9%, 6 hourly
124234479	ranitidine IV infusion 50 mg in Sodium Chloride 0.9%, 6 hourly
21714436	dexchlorpheniramine-pseudoephedrine
45226846	tizanidine
64304212	indacaterol/glycopyrronium/mometasone
64305489	procyclidine
64305079	ipratropium-xylometazoline nasal
64305065	paracetamol-diphenhydramine
91044844	neostigmine-atropine


Anticholinergics Opioids (AC-O):
9888918	pholcodine/phenylephrine/chlorphenamine/ammonium chloride
82140450	tRAMadol-paracetamol
9889010	ammonium chloride/codeine/guaifenesin/phenylephrine/pseudoephedrine
9888998	paracetamol/phenylephrine/dextromethorphan/chlorphenamine
9854604	paracetamol/pseudoephedrine/dextromethorphan/doxylamine
9744390	diphenoxylate-atropine
10410087	paracetamol/codeine/pseudoephedrine
149149086	tRAMadol IV infusion xx mg/kg in Sodium Chloride 0.9%, 6 hourly PRN - PAED
10410231	pholcodine/proMETHazine/pseudoephedrine
147920479	tRAMadol IV infusion 50 mg in Sodium Chloride 0.9%, 4 hourly PRN
148230931	tRAMadol IV infusion 50 mg in Sodium Chloride 0.9% PRN
124211486	tRAMadol (PCA) infusion 1000 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS
152935661	tRAMadol IV infusion xx mg in Sodium Chloride 0.9% PRN
9763463	tRAMadol
9763322	chlorphenamine/dextromethorphan/pseudoephedrine
9766310	dextromethorphan-pseudoephedrine
9765750	paracetamol/pseudoephedrine/dextromethorphan
9763060	codeine-pseudoephedrine
9767612	pholcodine-proMETHazine
9769068	dextromethorphan-diphenhydramine
9769224	paracetamol/codeine/phenylephrine/chlorphenamine maleate
9889245	codeine/paracetamol/proMETHazine
9768515	chlorphenamine/pholcodine/pseudoephedrine
9768133	paracetamol/pseudoephedrine/dextromethorphan/chlorphenamine
124211536	tRAMadol infusion 1000 mg in Sodium Chloride 0.9% 100 mL CONTINUOUS
9767166	brompheniramine/phenylephrine/dextromethorphan
147920402	tRAMadol IV infusion 100 mg in Sodium Chloride 0.9%, 4 hourly PRN
64305093	paracetamol/chlorphenamine maleate/dextromethorphan
 */