/*
This Script Is used for mapping a PBS Code to a Catalog Item
It edits an unused line in the pbs_ocs_mapping table and switches the
PBS_DRUG_ID and SYNONYM_ID to the ones that are now related
 */

;  PBS mapping script for PBS_DRUG_ID: #PBS_DRUG_ID# and SYNONYM_ID: #SYNONYM_ID#
update into pbs_ocs_mapping ocsm
set
    ocsm.beg_effective_dt_tm = cnvtdatetime(curdate, 0004)
    ; Above line sets the activation time to today at 12:04 am, used to identify this type of update
    , ocsm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    , ocsm.pbs_drug_id = #PBS_DRUG_ID# ; Swap With Pbs Drug Id that maps to the synonym id
    , ocsm.synonym_id = #SYNONYM_ID# ; Swap With Synonym Id that maps to the pbs_drug_id
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
        where pbs_drug_id = #PBS_DRUG_ID# ; Swap With Pbs Drug Id
        and synonym_id = #SYNONYM_ID# ; Swap With Synonym Id
        and end_effective_dt_tm > sysdate
    )
    ;and curdomain = "C2031"; used to only run in a domain