;  PBS mapping script
update into pbs_ocs_mapping ocsm
set
    ocsm.beg_effective_dt_tm = cnvtdatetime(curdate, 0004)
    , ocsm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    , ocsm.pbs_drug_id = 132771561
    , ocsm.synonym_id = 134100894
where
    ocsm.pbs_ocs_mapping_id = (
    select min(pbs_ocs_mapping_id)
    from pbs_ocs_mapping
    where end_effective_dt_tm < sysdate
    )
    and not exists (
    select 1
    from pbs_ocs_mapping
    where pbs_drug_id = 132771561
    and synonym_id = 134100894
    and end_effective_dt_tm > sysdate
    )
    and curdomain = "C2031"

;  PBS mapping script
update into
    pbs_ocs_mapping ocsm
    set ocsm.beg_effective_dt_tm = cnvtdatetime(curdate, 0004)
    , ocsm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    , ocsm.pbs_drug_id = 132771561
    , ocsm.synonym_id = 134100895
where
    ocsm.pbs_ocs_mapping_id =
        (
            select min(pbs_ocs_mapping_id)
            from pbs_ocs_mapping
            where end_effective_dt_tm < sysdate
        )
    and not exists
        (
            select 1
            from pbs_ocs_mapping
            where pbs_drug_id = 132771561
            and synonym_id = 134100895
            and end_effective_dt_tm > sysdate
        )
    and curdomain = "C2031"
