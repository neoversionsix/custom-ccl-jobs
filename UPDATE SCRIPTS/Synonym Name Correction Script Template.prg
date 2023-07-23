; Name Swap for Synonym ID: <SYNONYM_ID> 
; AND <CATALOG_CD> 
; to NEW NAME OF: <CHANGE_TO_NEW_PRIMARY_MNEMONIC>

update into order_catalog_synonym ocs
set 
    ocs.mnemonic = "<CHANGE_TO_NEW_PRIMARY_MNEMONIC>"
    , ocs.mnemonic_key_cap = "<CHANGE_TO_UPPERCASE>"
    , ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ocs.updt_id = reqinfo->updt_id
    , ocs.updt_cnt = ocs.updt_cnt + 1
where 
    ocs.synonym_id = <SYNONYM_ID>

update into code_value cv_oc
set 
    cv_oc.display = "<CHANGE_TO_FIRST_40_CHARS>"
    , cv_oc.display_key = "<CHANGE_TO_FIRST_40_CHARS_THEN_REMOVE_SPACES_AND_SPECIAL_CHARS>"
    , cv_oc.description = "<CHANGE_TO_FIRST_60_CHARS>"
    , cv_oc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , cv_oc.updt_id = reqinfo->updt_id
    , cv_oc.updt_cnt = cv_oc.updt_cnt + 1
where 
    cv_oc.code_set = 200 ; 'order catalog' code set
    and cv_oc.code_value = <CATALOG_CD>

update into order_task ot
set 
    ot.task_description = "<CHANGE_TO_NEW_PRIMARY_MNEMONIC>"
    , ot.task_description_key = "<CHANGE_TO_UPPERCASE>"
    , ot.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ot.updt_id = reqinfo->updt_id
    , ot.updt_cnt = ot.updt_cnt + 1
    where ot.reference_task_id = 
        (select reference_task_id from order_task_xref where catalog_cd = <CATALOG_CD>)

update into code_value cv_es
set 
    cv_es.display = "<CHANGE_TO_FIRST_40_CHARS>"
    , cv_es.display_key = "<CHANGE_TO_FIRST_40_CHARS_THEN_REMOVE_SPACES_AND_SPECIAL_CHARS>"
    , cv_es.description = "<CHANGE_TO_FIRST_60_CHARS>"
    , cv_es.definition = "<CHANGE_TO_NEW_PRIMARY_MNEMONIC>"
    , cv_es.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , cv_es.updt_id = reqinfo->updt_id
    , cv_es.updt_cnt = cv_es.updt_cnt + 1
where 
    cv_es.code_set = 93 ; 'event set' code set
    and cv_es.code_value = 
        (select event_set_cd from v500_event_set_code where event_set_name = 
            (select event_set_name from v500_event_code where event_cd = 
                (select event_cd from code_value_event_r where parent_cd = <CATALOG_CD>)
            ) 
        )

update into v500_event_set_code es
set 
    es.event_set_cd_disp = "<CHANGE_TO_FIRST_40_CHARS>"
    , es.event_set_cd_disp_key = "<CHANGE_TO_FIRST_40_CHARS_THEN_REMOVE_SPACES_AND_SPECIAL_CHARS>"
    , es.event_set_cd_descr = "<CHANGE_TO_FIRST_60_CHARS>"
    , es.event_set_cd_definition = "<CHANGE_TO_NEW_PRIMARY_MNEMONIC>"
    , es.event_set_name = "<CHANGE_TO_FIRST_40_CHARS>"
    , es.event_set_name_key = "<CHANGE_TO_FIRST_40_CHARS_THEN_REMOVE_SPACES_AND_SPECIAL_CHARS>"
    , es.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , es.updt_id = reqinfo->updt_id
    , es.updt_cnt = es.updt_cnt + 1
where
    es.event_set_name = 
        (select event_set_name from v500_event_code where event_cd = 
            (select event_cd from code_value_event_r where parent_cd = <CATALOG_CD>)
        )

update into v500_event_code ec
    set ec.event_cd_disp = "<CHANGE_TO_FIRST_40_CHARS>"
    , ec.event_cd_disp_key = "<CHANGE_TO_FIRST_40_CHARS_THEN_REMOVE_SPACES_AND_SPECIAL_CHARS>"
    , ec.event_cd_descr = "<CHANGE_TO_FIRST_60_CHARS>"
    , ec.event_cd_definition = "<CHANGE_TO_NEW_PRIMARY_MNEMONIC>"
    , ec.event_set_name = "<CHANGE_TO_FIRST_40_CHARS>"
    , ec.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ec.updt_id = reqinfo->updt_id
    , ec.updt_cnt = ec.updt_cnt + 1
where ec.event_cd = 
    (select event_cd from code_value_event_r where parent_cd = <CATALOG_CD>)

update into code_value cv_ec
    set cv_ec.display = "<CHANGE_TO_FIRST_40_CHARS>"
    , cv_ec.display_key = "<CHANGE_TO_FIRST_40_CHARS_THEN_REMOVE_SPACES_AND_SPECIAL_CHARS>"
    , cv_ec.description = "<CHANGE_TO_FIRST_60_CHARS>"
    , cv_ec.definition = "<CHANGE_TO_NEW_PRIMARY_MNEMONIC>"
    , cv_ec.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , cv_ec.updt_id = reqinfo->updt_id
    , cv_ec.updt_cnt = cv_ec.updt_cnt + 1
where cv_ec.code_set = 72 ; 'event code' code set
    and cv_ec.code_value = 
    (select event_cd from code_value_event_r where parent_cd = <CATALOG_CD>)

update into order_catalog oc
    set oc.primary_mnemonic = "<CHANGE_TO_NEW_PRIMARY_MNEMONIC>"
    , oc.description = "<CHANGE_TO_NEW_PRIMARY_MNEMONIC>"
    , oc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , oc.updt_id = reqinfo->updt_id
    , oc.updt_cnt = oc.updt_cnt + 1
where 
    oc.catalog_cd = <CATALOG_CD>
;-------------------------------------------------------------------------------


;