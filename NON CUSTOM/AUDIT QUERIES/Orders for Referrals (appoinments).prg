SELECT
/* For Andrew Woo
Need to add appointment type
appt_type_cd

Examples
Audiology ABR New
Audiology New
Gyno MBR?

Code Set 14230 For appointment type
 */
      ACTIVE = ORDER_CATALOG_SYNONYM.ACTIVE_IND
    , CATALOG_TYPE = UAR_GET_CODE_DISPLAY(ORDER_CATALOG.CATALOG_TYPE_CD)
    , ACTIVITY_TYPE = UAR_GET_CODE_DISPLAY(ORDER_CATALOG.ACTIVITY_TYPE_CD)
    , PRIMARY_NAME = ORDER_CATALOG.PRIMARY_MNEMONIC
    , OE_FORMAT = ORDER_ENTRY_FORMAT.OE_FORMAT_NAME

FROM
    ORDER_CATALOG
    , ORDER_CATALOG_SYNONYM
    , ORDER_ENTRY_FORMAT

PLAN ORDER_CATALOG
    WHERE
        ORDER_CATALOG.CATALOG_TYPE_CD = 77902618.00 ; Referral
        AND
        ORDER_CATALOG.ACTIVE_IND = 1 ; Only Active Primaries

JOIN ORDER_CATALOG_SYNONYM
    WHERE
        ORDER_CATALOG_SYNONYM.CATALOG_CD = ORDER_CATALOG.CATALOG_CD
        AND
        ORDER_CATALOG_SYNONYM.MNEMONIC_TYPE_CD = 2583 ; Code value for 'primary' from code set 6011
JOIN ORDER_ENTRY_FORMAT
    WHERE ORDER_ENTRY_FORMAT.OE_FORMAT_ID = ORDER_CATALOG.OE_FORMAT_ID

JOIN BR_SCHED_APPT_TYPE
	WHERE BR_SCHED_APPT_TYPE.CATALOG_TYPE_CD = ORDER_CATALOG.CATALOG_TYPE_CD

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME=10



/*
   CODE SET: 14230

TABLE NAME                    COLUMN NAME                   DESCRIPTION
------------------------------------------------------------------------------------------------------------------------

BR_SCHED_APPT_9691            MATCH_APPT_TYPE_CD            Code value from 14230 if the proposed appointment type is
                                                            created
BR_SCHED_APPT_TYPE            MATCH_APPT_TYPE_CD            Code value from 14230 if the proposed appointment type is
                                                            created
LH_MU_FX_2_METRICSC261DRR     APPT_TYPE_CD                  Shadow table for LH_MU_FX_2_METRICS
LH_MU_FX_METRICSB530DRR       APPT_TYPE_CD                  CODE SET:14230
                                                                               The identifier for an appointment type.
                                                            An example would be  'cardiac cath', 'echo stress', etc.
PM_WAIT_LIST                  APPT_TYPE_CD                  What the appointment is for. Examples are 'MRI Knee',
                                                            'Ortho Consult', etc.
PM_WAIT_LIST3383              APPT_TYPE_CD                  What the appointment is for. Examples are 'MRI Knee',
                                                            'Ortho Consult', etc.
PM_WAIT_LIST3383DRR           APPT_TYPE_CD                  Shadow table for PM_WAIT_LIST
SCH_ABN_CROSS                 PARENT_APPT_TYPE_CD           Protocol Parent Appointment Type Code
SCH_ABN_CROSS                 APPT_TYPE_CD                  The identifier for an appointment type.
SCH_ABN_CROSS6693             APPT_TYPE_CD                  The identifier for an appointment type.
SCH_ABN_CROSS6693             PARENT_APPT_TYPE_CD           Protocol Parent Appointment Type Code
SCH_APPT_ACT8638              APPT_TYPE_CD                  The unique identifier for the scheduling appointment type.
SCH_APPT_ACTION               APPT_TYPE_CD                  The unique identifier for the scheduling appointment type.
SCH_APPT_BOOK                 APPT_TYPE_CD                  What the appointment is for. Examples are 'MRI Knee',
                                                            'Ortho Consult', etc.
SCH_APPT_BOOK1166             APPT_TYPE_CD                  What the appointment is for. Examples are 'MRI Knee',
                                                            'Ortho Consult', etc.
SCH_APPT_COMP                 APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_COMP                 COMP_APPT_TYPE_CD             The coded identifier for the component appointment type.
SCH_APPT_COMP3286             COMP_APPT_TYPE_CD             The coded identifier for the component appointment type.
SCH_APPT_COMP3286             APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_DUP                  APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_DUP3666              APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_FREE                 APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_FREE4982             APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_INTER                APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_INTER3667            APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_LOC                  APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_LOC1626              APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_NOMEN                APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_NOMEN3907            APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_NOTIF3672            APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_NOTIFY               APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_OBJEC5287            APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_OBJECT               APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_OPTIO5190            APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_OPTION               APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_OPTION_CONFIG        APPT_TYPE_CD                  The appointment type code (from scheduling appointment type
                                                            code set: 14230) the OPTION_VALUE applies to
SCH_APPT_ORD                  APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_ORD2771              APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_PRI8131              APPT_TYPE_CD                  Appointment type code
SCH_APPT_PRIORITY             APPT_TYPE_CD                  Appointment type code
SCH_APPT_PRODU7032            APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_PRODUCT              APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_ROUTI5288            APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_ROUTING              APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_STATE                APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_STATE1159            APPT_TYPE_CD                  The identifier for an appointment type.

   CODE SET: 14230

TABLE NAME                    COLUMN NAME                   DESCRIPTION
------------------------------------------------------------------------------------------------------------------------

SCH_APPT_SYN                  APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_SYN1161              APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_TEXT                 APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_TEXT1698             APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_TYP1784              APPT_TYPE_CD                  Parent Appointment Type Code
SCH_APPT_TYPE                 APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_TYPE1162             APPT_TYPE_CD                  The identifier for an appointment type.
SCH_APPT_TYPE_SYN_R           APPT_TYPE_CD                  Parent Appointment Type Code
SCH_AT_ENCNT2533              APPT_TYPE_CD                  Parent appointment type code.
SCH_AT_ENCNTR_TYPE_R          APPT_TYPE_CD                  Parent appointment type code.
SCH_AT_INSUR_PROFILE_R        APPT_TYPE_CD                  Indicate the Appointment Type Code.
SCH_AT_MED_S2532              APPT_TYPE_CD                  Parent appointment type code.
SCH_AT_MED_SERVICE_R          APPT_TYPE_CD                  Parent appointment type code.
SCH_AT_SPECIALTY_R            APPT_TYPE_CD                  Parent appointment type code
SCH_AUTO_MSG_APPT_TYPE_R      APPT_TYPE_CD                  The code value of an appointment type which has a relation
                                                            to an automated messaging build.
SCH_BOOKING                   APPT_TYPE_CD                  The identifier for an appointment type.
SCH_BOOKING2772               APPT_TYPE_CD                  The identifier for an appointment type.
SCH_BOOKING2772DRR            APPT_TYPE_CD                  Shadow table for SCH_BOOKING
SCH_BOOK_GUI8669              APPT_TYPE_CD                  CODE SET:14230
                                                                                                   The identifier for
                                                            an appointment type.
SCH_BOOK_GUIDE                APPT_TYPE_CD                  CODE SET:14230
                                                                                                   The identifier for
                                                            an appointment type.
SCH_COMP_LOC                  APPT_TYPE_CD                  The identifier for an appointment type.
SCH_COMP_LOC3287              APPT_TYPE_CD                  The identifier for an appointment type.
SCH_ENTRY                     APPT_TYPE_CD                  The identifier for an appointment type.
SCH_ENTRY5787                 APPT_TYPE_CD                  The identifier for an appointment type.
SCH_ENTRY5787DRR              APPT_TYPE_CD                  Shadow table for SCH_ENTRY
SCH_EVENT                     APPT_TYPE_CD                  The identifier for an appointment type. An example would be
                                                             cardiac cath, echo stress, etc.
SCH_EVENT1191                 APPT_TYPE_CD                  The identifier for an appointment type. An example would be
                                                             cardiac cath, echo stress, etc.
SCH_EVENT1191DRR              APPT_TYPE_CD                  Shadow table for SCH_EVENT
SCH_NOMEN_LIST                APPT_TYPE_CD                  The unique identifier for the scheduling appointment type.
SCH_NOMEN_LIST3077            APPT_TYPE_CD                  The unique identifier for the scheduling appointment type.
SCH_ORDER_APPT                CHILD_APPT_TYPE_CD            The unique identifier for the child appointment type.
SCH_ORDER_APPT                APPT_TYPE_CD                  The unique identifier for the scheduling appointment type.
SCH_ORDER_APPT5358            APPT_TYPE_CD                  The unique identifier for the scheduling appointment type.
SCH_ORDER_APPT5358            CHILD_APPT_TYPE_CD            The unique identifier for the child appointment type.
SCH_PEND_APPT                 APPT_TYPE_CD                  The identifier for an appointment type.
SCH_PEND_APPT4921DRR          APPT_TYPE_CD                  Shadow table for SCH_PEND_APPT
SCH_PEND_EVENT                APPT_TYPE_CD                  The appointment type
SCH_PEND_EVENTF423DRR         APPT_TYPE_CD                  The appointment type
SCH_QUESTION                  APPT_TYPE_CD                  CODE SET:14230
                                                                                                   The identifier for
                                                            an appointment type.
SCH_QUESTION8670              APPT_TYPE_CD                  CODE SET:14230
                                                                                                   The identifier for
                                                            an appointment type.
SCH_RESOURCE_L2180            APPT_TYPE_CD                  The unique identifier for the scheduling appointment type.
SCH_RESOURCE_LIST             APPT_TYPE_CD                  The unique identifier for the scheduling appointment type.
SCH_SERVICE                   APPT_TYPE_CD                  The unique identifier for the scheduling appointment type
SCH_SERVICE8661               APPT_TYPE_CD                  The unique identifier for the scheduling appointment type

   CODE SET: 14230

TABLE NAME                    COLUMN NAME                   DESCRIPTION
------------------------------------------------------------------------------------------------------------------------

SCH_WORKLIST                  APPT_TYPE_CD                  The identifier of the appointment type.
SCH_WORKLIST8702              APPT_TYPE_CD                  The identifier of the appointment type.
UKRWH_CDE_OP_A9837            APPT_TYPE_REF                 The identifier for an appointment type.
UKRWH_CDE_OP_ATTENDANCE       APPT_TYPE_REF                 The identifier for an appointment type.

 */