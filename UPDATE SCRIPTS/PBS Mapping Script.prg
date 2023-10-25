;  PBS mapping script
update into pbs_ocs_mapping ocsm
set
    ocsm.beg_effective_dt_tm = cnvtdatetime(curdate, 0004)
    , ocsm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    , ocsm.pbs_drug_id = #PBSDRUGID# ; SWAP WITH PBS DRUG ID
    , ocsm.synonym_id = #SYNONYMID# ; SWAP WITH SYNONYM ID
    , ocsm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , ocsm.updt_id = reqinfo->updt_id
    , ocsm.updt_cnt = ocs.updt_cnt + 1
where
    ocsm.pbs_ocs_mapping_id = (
    select min(pbs_ocs_mapping_id)
    from pbs_ocs_mapping
    where end_effective_dt_tm < sysdate
    )
    and not exists (
    select 1
    from pbs_ocs_mapping
    where pbs_drug_id = #PBSDRUGID# ; SWAP WITH PBS DRUG ID
    and synonym_id = #SYNONYMID# ; SWAP WITH SYNONYM ID
    and end_effective_dt_tm > sysdate
    )
    and curdomain = "C2031"