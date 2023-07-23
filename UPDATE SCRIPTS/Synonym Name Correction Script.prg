; Name Swap for Synonym ID: <SYNONYM_ID> to <NEW_NAME>
update into order_catalog_synonym ocs
set 
    ocs.mnemonic = "MBS Billing Code - Ambulatory blood pressure recording cont.>24hrs (11607)"
    , ocs.mnemonic_key_cap = "MBS BILLING CODE - AMBULATORY BLOOD PRESSURE RECORDING CONT.>24HRS (11607)"
    , ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ocs.updt_id = reqinfo->updt_id
    , ocs.updt_cnt = ocs.updt_cnt + 1
where 
    ocs.synonym_id = 154167641

update into code_value cv_oc
set 
    cv_oc.display = "MBS Billing Code - Ambulatory blood pres"
    , cv_oc.display_key = "MBSBILLINGCODEAMBULATORYBLOODPRES"
    , cv_oc.description = "MBS Billing Code - Ambulatory blood pressure recording cont."
    , cv_oc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , cv_oc.updt_id = reqinfo->updt_id
    , cv_oc.updt_cnt = cv_oc.updt_cnt + 1
where 
    cv_oc.code_set = 200 ; 'order catalog' code set
    and cv_oc.code_value = 154167637

update into order_task ot
set 
    ot.task_description = "MBS Billing Code - Ambulatory blood pressure recording cont.>24hrs (11607)"
    , ot.task_description_key = "MBS BILLING CODE - AMBULATORY BLOOD PRESSURE RECORDING CONT.>24HRS (11607)"
    , ot.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ot.updt_id = reqinfo->updt_id
    , ot.updt_cnt = ot.updt_cnt + 1
    where ot.reference_task_id = 
        (select reference_task_id from order_task_xref where catalog_cd = 154167637)

update into code_value cv_es
set 
    cv_es.display = "MBS Billing Code - Ambulatory blood pres"
    , cv_es.display_key = "MBSBILLINGCODEAMBULATORYBLOODPRES"
    , cv_es.description = "MBS Billing Code - Ambulatory blood pressure recording cont."
    , cv_es.definition = "MBS Billing Code - Ambulatory blood pressure recording cont.>24hrs (11607)"
    , cv_es.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , cv_es.updt_id = reqinfo->updt_id
    , cv_es.updt_cnt = cv_es.updt_cnt + 1
where 
    cv_es.code_set = 93 ; 'event set' code set
    and cv_es.code_value = 
        (select event_set_cd from v500_event_set_code where event_set_name = 
            (select event_set_name from v500_event_code where event_cd = 
                (select event_cd from code_value_event_r where parent_cd = 154167637)
            ) 
        )

update into v500_event_set_code es
set 
    es.event_set_cd_disp = "MBS Billing Code - Ambulatory blood pres"
    , es.event_set_cd_disp_key = "MBSBILLINGCODEAMBULATORYBLOODPRES"
    , es.event_set_cd_descr = "MBS Billing Code - Ambulatory blood pressure recording cont."
    , es.event_set_cd_definition = "MBS Billing Code - Ambulatory blood pressure recording cont.>24hrs (11607)"
    , es.event_set_name = "MBS Billing Code - Ambulatory blood pres"
    , es.event_set_name_key = "MBSBILLINGCODEAMBULATORYBLOODPRES"
    , es.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , es.updt_id = reqinfo->updt_id
    , es.updt_cnt = es.updt_cnt + 1
where
    es.event_set_name = 
        (select event_set_name from v500_event_code where event_cd = 
            (select event_cd from code_value_event_r where parent_cd = 154167637)
        )

update into v500_event_code ec
    set ec.event_cd_disp = "MBS Billing Code - Ambulatory blood pres"
    , ec.event_cd_disp_key = "MBSBILLINGCODEAMBULATORYBLOODPRES"
    , ec.event_cd_descr = "MBS Billing Code - Ambulatory blood pressure recording cont."
    , ec.event_cd_definition = "MBS Billing Code - Ambulatory blood pressure recording cont.>24hrs (11607)"
    , ec.event_set_name = "MBS Billing Code - Ambulatory blood pres"
    , ec.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ec.updt_id = reqinfo->updt_id
    , ec.updt_cnt = ec.updt_cnt + 1
where ec.event_cd = 
    (select event_cd from code_value_event_r where parent_cd = 154167637)

update into code_value cv_ec
    set cv_ec.display = "MBS Billing Code - Ambulatory blood pres"
    , cv_ec.display_key = "MBSBILLINGCODEAMBULATORYBLOODPRES"
    , cv_ec.description = "MBS Billing Code - Ambulatory blood pressure recording cont."
    , cv_ec.definition = "MBS Billing Code - Ambulatory blood pressure recording cont.>24hrs (11607)"
    , cv_ec.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , cv_ec.updt_id = reqinfo->updt_id
    , cv_ec.updt_cnt = cv_ec.updt_cnt + 1
where cv_ec.code_set = 72 ; 'event code' code set
    and cv_ec.code_value = 
    (select event_cd from code_value_event_r where parent_cd = 154167637)

update into order_catalog oc
    set oc.primary_mnemonic = "MBS Billing Code - Ambulatory blood pressure recording cont.>24hrs (11607)"
    , oc.description = "MBS Billing Code - Ambulatory blood pressure recording cont.>24hrs (11607)"
    , oc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , oc.updt_id = reqinfo->updt_id
    , oc.updt_cnt = oc.updt_cnt + 1
where 
    oc.catalog_cd = 154167637