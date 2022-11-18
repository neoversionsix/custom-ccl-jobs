/* Discern SQL Engine (EJS) v. 3.14.2: Orthopaedics - Outpatient Clinic and Radiology Orders [5a070a5e-c96f-4730-9a3e-62758a75eea6] */
SELECT
  PM_GET_ALIAS('MRN', 0, per.PERSON_ID, 0, cclsql_cnvtdatetimeutc(sysdate, 1, 511, 1)) as "Person - Medical Record Number"
  , per.NAME_FULL_FORMATTED as "Name - Full"
  , case when enc.reg_dt_tm is null 

  then TRUNC((cclsql_utc_cnvt(sysdate, 1,75) - Per.BIRTH_DT_TM)/365.25,0)

  else trunc((enc.REG_DT_TM - per.birth_dt_tm)/365.25,0) end as "Age - Years (Reg)"
  , OMF_GET_CV_DISPLAY(per.SEX_CD) as "Gender"
  , omf_get_fin_nbr(enc.encntr_id) as "Enc Fin Nbr"
  , OMF_GET_CV_DISPLAY(ENC.ENCNTR_TYPE_CD) as "Encounter Type"
  , OMF_GET_CV_DISPLAY(ENC.ENCNTR_STATUS_CD) as "Encounter Status"
  , OMF_GET_CV_DISPLAY(ELH.MED_SERVICE_CD) as "Enc Medical Service -Curr"
  , cclsql_utc_cnvt(sch_appt.beg_dt_tm,1,514) as "Sch Appt Dt/Tm"
  , ENC.encntr_id as "Encounter Id"
  , "Ortho OPD Rad Orders"."Ordering Personnel" as "Ordering Personnel"
  , "Ortho OPD Rad Orders"."Ordered DT/TM" as "Ordered DT/TM"
  , "Ortho OPD Rad Orders"."Order Mnemonic" as "Order Mnemonic"
FROM ENCOUNTER ENC
  , PERSON PER
  , ENCNTR_LOC_HIST ELH
  , SCH_APPT SCH_APPT_PERS
  , SCH_APPT SCH_APPT
  , ( SELECT
      PM_GET_ALIAS('MRN', 0, per.PERSON_ID, 0, cclsql_cnvtdatetimeutc(sysdate, 1, 511, 1)) as "Person - Medical Record Number"
      , omf_get_fin_nbr(enc.encntr_id) as "Enc Fin Nbr"
      , OMF_GET_CV_DISPLAY(ELH.MED_SERVICE_CD) as "Enc Medical Service -Curr"
      , cclsql_utc_cnvt(sch_appt.beg_dt_tm,1,514) as "Sch Appt Dt/Tm"
      , ORDERS.encntr_ID as "Ortho OPD Rad Orders:Order Enc"
      , ORDERS.order_mnemonic as "Order Mnemonic"
      , cclsql_utc_cnvt (ORDERS.orig_order_dt_tm, 1,514) as "Ordered DT/TM"
      , SQL_GET_NAME_DISPLAY(OA_ORDER.ACTION_PERSONNEL_ID, OMF_GET_CVALUE(213,'PRSNL'), cclsql_cnvtdatetimeutc(sysdate, 1, 511, 1)) as "Ordering Personnel"
    FROM ENCOUNTER ENC
      , PERSON PER
      , ORDERS ORDERS
      , ENCNTR_LOC_HIST ELH
      , SCH_APPT SCH_APPT_PERS
      , ORDER_ACTION OA_ORDER
      , SCH_APPT SCH_APPT
    WHERE (ENC.PERSON_ID = PER.PERSON_ID)
    AND (sch_appt_pers.person_id=per.person_id)
    AND (ENC.ACTIVE_IND=1)
    AND (enc.encntr_id = elh.encntr_id(+) 

and elh.active_ind(+)=1)
    AND (sch_appt_pers.encntr_id=enc.encntr_id and

sch_appt_pers.person_id=enc.person_id)
    AND (orders.active_ind=1)
    AND (oa_order.order_id(+) = orders.order_id and

oa_order.action_type_cd(+) = omf_get_cvalue(6003, 'ORDER'))
    AND (ORDERS.ENCNTR_ID=ENC.ENCNTR_ID AND 

ENC.ACTIVE_IND = 1  AND 

ORDERS.PERSON_ID = ENC.PERSON_ID)
    AND (per.active_ind=1)
    AND (sch_appt_PERS.role_meaning(+)='PATIENT'

  and sch_appt_pers.schedule_id(+)=sch_appt.schedule_id 

  and sch_appt_pers.sch_event_id(+)=sch_appt.sch_event_id

  and sch_appt_pers.active_ind(+)=1 and

sch_appt_pers.beg_effective_dt_tm(+) <= cclsql_cnvtdatetimeutc(sysdate, 1, 514, 1) AND 

sch_appt_pers.end_effective_dt_tm(+) > cclsql_cnvtdatetimeutc(sysdate, 1, 514, 1))
    AND ((orders.catalog_type_cd IN (2517.00))
      AND (ELH.MED_SERVICE_CD IN (87625391.00,86504090.00,98636040.00))
      AND sch_appt.beg_dt_tm BETWEEN to_date('2022-11-17 13:00:00','YYYY-MM-DD HH24:MI:SS') AND to_date('2022-11-24 12:59:59','YYYY-MM-DD HH24:MI:SS'))
    ORDER BY PM_GET_ALIAS('MRN', 0, per.PERSON_ID, 0, cclsql_cnvtdatetimeutc(sysdate, 1, 511, 1)) nulls first
      , omf_get_fin_nbr(enc.encntr_id) nulls first
      , OMF_GET_CV_DISPLAY(ELH.MED_SERVICE_CD) nulls first
      , cclsql_utc_cnvt(sch_appt.beg_dt_tm,1,514) nulls first
      , ORDERS.encntr_ID nulls first
      , ORDERS.order_mnemonic nulls first
      , cclsql_utc_cnvt (ORDERS.orig_order_dt_tm, 1,514) nulls first
      , SQL_GET_NAME_DISPLAY(OA_ORDER.ACTION_PERSONNEL_ID, OMF_GET_CVALUE(213,'PRSNL'), cclsql_cnvtdatetimeutc(sysdate, 1, 511, 1)) nulls first ) "Ortho OPD Rad Orders"
WHERE (ENC.PERSON_ID = PER.PERSON_ID)
AND (sch_appt_pers.person_id=per.person_id)
AND (ENC.ACTIVE_IND=1)
AND (enc.encntr_id = elh.encntr_id(+) 

and elh.active_ind(+)=1)
AND (sch_appt_pers.encntr_id=enc.encntr_id and

sch_appt_pers.person_id=enc.person_id)
AND (per.active_ind=1)
AND (sch_appt_PERS.role_meaning(+)='PATIENT'

  and sch_appt_pers.schedule_id(+)=sch_appt.schedule_id 

  and sch_appt_pers.sch_event_id(+)=sch_appt.sch_event_id

  and sch_appt_pers.active_ind(+)=1 and

sch_appt_pers.beg_effective_dt_tm(+) <= cclsql_cnvtdatetimeutc(sysdate, 1, 514, 1) AND 

sch_appt_pers.end_effective_dt_tm(+) > cclsql_cnvtdatetimeutc(sysdate, 1, 514, 1))
AND ((ENC.ENCNTR_STATUS_CD IN (854.00,856.00,666808.00))
  AND (ENC.ENCNTR_TYPE_CD IN (309309.00))
  AND (ELH.MED_SERVICE_CD IN (87625391.00,86504090.00,98636040.00))
  AND ENC.encntr_id = "Ortho OPD Rad Orders"."Ortho OPD Rad Orders:Order Enc"(+)
  AND sch_appt.beg_dt_tm BETWEEN to_date('2022-11-17 13:00:00','YYYY-MM-DD HH24:MI:SS') AND to_date('2022-11-24 12:59:59','YYYY-MM-DD HH24:MI:SS')
  AND (ENC.LOC_NURSE_UNIT_CD NOT IN (100766192.00,100766270.00,101716517.00,104285063.00)))
ORDER BY PM_GET_ALIAS('MRN', 0, per.PERSON_ID, 0, cclsql_cnvtdatetimeutc(sysdate, 1, 511, 1)) nulls first
  , per.NAME_FULL_FORMATTED nulls first
  , case when enc.reg_dt_tm is null 

  then TRUNC((cclsql_utc_cnvt(sysdate, 1,75) - Per.BIRTH_DT_TM)/365.25,0)

  else trunc((enc.REG_DT_TM - per.birth_dt_tm)/365.25,0) end nulls first
  , OMF_GET_CV_DISPLAY(per.SEX_CD) nulls first
  , omf_get_fin_nbr(enc.encntr_id) nulls first
  , OMF_GET_CV_DISPLAY(ENC.ENCNTR_TYPE_CD) nulls first
  , OMF_GET_CV_DISPLAY(ENC.ENCNTR_STATUS_CD) nulls first
  , OMF_GET_CV_DISPLAY(ELH.MED_SERVICE_CD) nulls first
  , cclsql_utc_cnvt(sch_appt.beg_dt_tm,1,514) nulls first
  , ENC.encntr_id nulls first
  , "Ortho OPD Rad Orders"."Ordering Personnel" nulls first
  , "Ortho OPD Rad Orders"."Ordered DT/TM" nulls first
  , "Ortho OPD Rad Orders"."Order Mnemonic" nulls first