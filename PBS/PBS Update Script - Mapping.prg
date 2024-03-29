/*
This Script Is used for mapping a PBS Code to a Catalog Item
It edits an unused line in the pbs_ocs_mapping table and switches the
PBS_DRUG_ID and SYNONYM_ID to the ones that are now related

Checker Script - recent updated lines
select * from pbs_ocs_mapping where updt_dt_tm > cnvtlookbehind("1,H")

;and curdomain = "C2031"; used to only run in a domain. Add to end of query if required
 */




;________________________________________________
;  PBS mapping script for PBS_DRUG_ID: _PBS_DRUG_ID_ and SYNONYM_ID: _SYNONYM_ID_
update into pbs_ocs_mapping ocsm
set
    ocsm.beg_effective_dt_tm = cnvtdatetime(curdate, 0004)
    ; Above line sets the activation time to today at 12:04 am, used to identify this type of update
    , ocsm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    /*CHANGE THE ROW BELOW MAP_PBS_DRUG_ID__1*/
    , ocsm.pbs_drug_id = MAP_PBS_DRUG_ID__1 ; Swap With Pbs Drug Id that maps to the synonym id
    /*CHANGE THE ROW BELOW MAP_SYNONYM_ID__2*/
    , ocsm.synonym_id = MAP_SYNONYM_ID__2 ; Swap With Synonym Id that maps to the pbs_drug_id
    , ocsm.drug_synonym_id = 0 ; clear multum mapping (multum mappings are not used)
    , ocsm.main_multum_drug_code = 0 ; clear multum mapping
    , ocsm.drug_identifier = "0" ; clear multum mapping
    , ocsm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ocsm.updt_id = reqinfo->updt_id
    , ocsm.updt_cnt = ocsm.updt_cnt + 1
where
    ;Update the next unused row
    ocsm.pbs_ocs_mapping_id =
    (select min(pbs_ocs_mapping_id) from pbs_ocs_mapping where end_effective_dt_tm < sysdate)
    ; Only Update if the item is NOT already mapped
    and not exists
    (
        select 1
        from pbs_ocs_mapping
        /*CHANGE THE ROW BELOW MAP_PBS_DRUG_ID__1*/
        where pbs_drug_id = MAP_PBS_DRUG_ID__1 ; Swap With Pbs Drug Id
        /*CHANGE THE ROW BELOW MAP_SYNONYM_ID__2*/
        and synonym_id = MAP_SYNONYM_ID__2 ; Swap With Synonym Id
        and end_effective_dt_tm > sysdate
    )
;________________________________________________