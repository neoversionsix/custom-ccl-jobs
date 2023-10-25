;  PBS mapping script for PBSDRUGID: #PBSDRUGID# and SYNONYMID: #SYNONYMID#
update into pbs_ocs_mapping ocsm
set
    ocsm.beg_effective_dt_tm = cnvtdatetime(curdate, 0004)
    ; Above line sets the activation time to today at 12:04 am, used to identify this type of update
    , ocsm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    , ocsm.pbs_drug_id = #PBSDRUGID# ; Swap With Pbs Drug Id
    , ocsm.synonym_id = #SYNONYMID# ; Swap With Synonym Id
    , ocsm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ocsm.updt_id = reqinfo->updt_id
    , ocsm.updt_cnt = ocs.updt_cnt + 1
where
    ocsm.pbs_ocs_mapping_id =
    (select min(pbs_ocs_mapping_id) from pbs_ocs_mapping where end_effective_dt_tm < sysdate)
    and not exists ; Make Sure the PBS item is not already mapped
    (
        select 1
        from pbs_ocs_mapping
        where pbs_drug_id = #PBSDRUGID# ; Swap With Pbs Drug Id
        and synonym_id = #SYNONYMID# ; Swap With Synonym Id
        and end_effective_dt_tm > sysdate
    )
    ;and curdomain = "C2031"; used to only run in a domain