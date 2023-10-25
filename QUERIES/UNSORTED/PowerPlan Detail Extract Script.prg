select	; PowerPlan component details
	plan_or_phase_description = p_cat.description
	, plan_or_phase_active_ind = p_cat.active_ind
	, plan_or_phase_version = p_cat.version
	, plan_or_phase_currency = if (p_cat.version = 0 or  p_cat.version = p_cat_curr_v.version) "current"
	else "obsolete"
	endif
	, plan_or_phase_status = if (p_cat.beg_effective_dt_tm > sysdate and p_cat.end_effective_dt_tm > sysdate) "testing"
	elseif (p_cat.beg_effective_dt_tm < sysdate and p_cat.end_effective_dt_tm > sysdate) "production"
	elseif (p_cat.end_effective_dt_tm < sysdate) "inactive"
	endif
	, plan_or_phase_type_meaning = p_cat.type_mean
	, plan_display = if(p_cat.type_mean in ("CAREPLAN", "PATHWAY")) p_cat.display_description
	else "-"
	endif
	, plan_type = if(p_cat.type_mean in ("CAREPLAN", "PATHWAY")) uar_get_code_display(p_cat.pathway_type_cd)
	else "-"
	endif
	, comp_clinical_category = uar_get_code_display(p_comp.dcp_clin_cat_cd)
	, comp_clinical_subcategory = uar_get_code_display(p_comp.dcp_clin_sub_cat_cd)
	, comp_sequence = cnvtstring(p_comp.sequence)
	, comp_type = if (p_comp.pathway_catalog_id > 0) uar_get_code_display(p_comp.comp_type_cd)
	elseif (p_rel.pw_cat_t_id > 0) "Phase"
	endif
	, comp_name = if (p_comp.comp_type_cd = 10734) "notes excluded from extract, due to rtf formatting tags" ;substring(1,500,pp_note.long_text)	; "Note"
	elseif (p_comp.comp_type_cd in (10736, 7326766, 7057725)) ocs.mnemonic	; "Order", "Prescription" (*Note: different "Prescription" codes for G1 and G2)
	elseif (p_comp.comp_type_cd = 10738) occ.description	; "Result Outcome"
	elseif (p_comp.comp_type_cd = 3606218) p_cat_sub.description	; "Sub Phase"
	elseif (p_rel.pw_cat_t_id > 0) p_cat_phase.description	; "Phase"
	elseif (p_comp.pathway_comp_id = 0) ""	; Not a component
	else "-  - component type not configured in extract script - -"
	endif
	, comp_active_in_system = if (p_comp.comp_type_cd = 10734 and pp_note.long_text_id = 0 ) "1"	; blank "Note"
	elseif (p_comp.comp_type_cd = 10734) evaluate (pp_note.active_ind, 0, "0", 1, "1")	; "Note"
	elseif (p_comp.comp_type_cd in (10736, 7326766, 7057725)) evaluate (ocs.active_ind, 0, "0", 1, "1")	; "Order", "Prescription" (*Note: different "Prescription" codes for G1 /G5/G6 and G2/G3/G4)
	elseif (p_comp.comp_type_cd = 10738) evaluate (occ.active_ind, 0, "0",1 , "1")	; "Result Outcome"
	elseif (p_comp.comp_type_cd = 3606218) evaluate (p_cat_sub.active_ind, 0, "0", 1, "1")	; "Sub Phase"
	elseif (p_rel.pw_cat_t_id > 0) evaluate (p_cat_phase.active_ind, 0, "0", 1, "1")	; "Phase"
	elseif (p_comp.pathway_comp_id = 0) ""	; Not a component
	else "-  - component type not configured in extract script - -"
	endif
	, comp_active_in_plan = if (p_comp.pathway_catalog_id > 0) evaluate (p_comp.active_ind, 0, "0", 1, "1")
	elseif (p_rel.pw_cat_t_id > 0) "1"
	else ""
	endif
	, comp_include = if (p_comp.pathway_comp_id > 0)
	if (p_comp.include_ind = 1) "1"
	else "0"
	endif
	 else ""	; do not return duplicate information if row is non-order sentence, or not first order sentence row
	 endif
	, comp_required = if (p_comp.pathway_comp_id > 0)
	if (p_comp.required_ind = 1) "1"
	else "0"
	endif
	 else ""
	 endif
	, comp_order_sentence = os.order_sentence_display_line
	, comp_order_sentence_comment = substring(1,500,os_comm.long_text)
	, comp_last_update = format(p_comp.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")
	, comp_last_updater = if(p_comp.pathway_comp_id > 0 and p_comp.updt_id = 0) "0"
	else p_p_comp.name_full_formatted
	endif
	, plan_or_phase_version_catalog_id = p_cat.pathway_catalog_id
	, plan_all_versions_id = if(p_cat.type_mean in ("CAREPLAN", "PATHWAY")) cnvtstring(p_cat.version_pw_cat_id)
	else "-"
	endif
	, comp_id = if (p_comp.pathway_comp_id > 0 )  cnvtstring(p_comp.pathway_comp_id)	; return if row is a component, but either non-order sentence, or first order sentence row
	elseif (p_rel.pw_cat_t_id > 0)  cnvtstring(p_rel.pw_cat_t_id)	; for components which are other powerplans ("Phase")
	else ""	; do not return duplicate information if row is non-order sentence, or not first order sentence row
	endif
	, comp_os_id = if (pw_os.order_sentence_id > 0) cnvtstring(pw_os.order_sentence_id)
	else ""
	endif
	, domain_alignment_comparison_test = if(p_cat.end_effective_dt_tm > sysdate and p_cat.active_ind = 1)
	build(
	 p_cat.description
	, "|", if (p_cat.beg_effective_dt_tm > cnvtdatetime(curdate, curtime3) and p_cat.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)) "testing"
	elseif (p_cat.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3) and p_cat.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)) "production"
	endif
	, "|", p_cat.type_mean
	, "|", if(p_cat.type_mean in ("CAREPLAN", "PATHWAY")) p_cat.display_description
	 else "-"
	 endif
	, "|", p_comp.sequence
	, "|", if (p_comp.comp_type_cd = 10734) "notes excluded from extract, due to rtf formatting tags" ;substring(1,500,pp_note.long_text)	; "Note"
	 elseif (p_comp.comp_type_cd in (10736, 7326766, 7057725)) ocs.mnemonic	; "Order", "Prescription" (*Note: different "Prescription" codes for G1 and G2)
	 elseif (p_comp.comp_type_cd = 10738) occ.description	; "Result Outcome"
	 elseif (p_comp.comp_type_cd = 3606218) p_cat_sub.description	; "Sub Phase"
	 elseif (p_rel.pw_cat_t_id > 0) p_cat_phase.description	; "Phase"
	 elseif (p_comp.pathway_comp_id = 0) ""	; Not a component
	 else "-  - component type not configured in extract script - -"
	 endif
	, "|", os.order_sentence_display_line
	)
	else ""
	endif
	, powerplan_rank = dense_rank() over (partition by 0
	order by p_cat.description_key
	, p_cat.version
	, p_cat.pathway_catalog_id
	)

from
	pathway_catalog p_cat
	, pathway_catalog p_cat_curr_v
	, pathway_comp p_comp
	, prsnl p_p_comp
	, code_value clin_cat_cv	; for p_comp.dcp_clin_cat_cd sequence
	, long_text pp_note	; note within a plan
	, order_catalog_synonym ocs	; synonym (orderable or presription) within a plan
	, outcome_catalog occ
	, pathway_catalog p_cat_sub	; sub-phase within a care plan
	, pw_cat_reltn p_rel	; phase / pathway relationship
	, pathway_catalog p_cat_phase	; phase within pathway
	, pw_comp_os_reltn pw_os
	, order_sentence os
	, long_text os_comm

plan	p_cat
where	p_cat.pathway_catalog_id > 0	; to remove dummy row from results
;and	p_cat.pathway_catalog_id in (select pathway_catalog_id	; PowerPlan
;	from pathway_comp
;	where parent_entity_id in (select synonym_id	;containing a pathway component
;	from order_catalog_synonym
;	where active_ind = 0	; that is inactive
;	)
;	)
;and	p_cat.description_key < "D*"
;and	p_cat.description_key >= "D*"

join	p_cat_curr_v
where	p_cat_curr_v.version_pw_cat_id = p_cat.version_pw_cat_id
and	(
	p_cat_curr_v.version = (select max(version)
	from pathway_catalog
	where version_pw_cat_id = p_cat_curr_v.version_pw_cat_id
	and p_cat.type_mean not in ("DOT", "PHASE")
	)
	or
	p_cat_curr_v.pathway_catalog_id = (select max(pathway_catalog_id)
	from pathway_catalog
	where version_pw_cat_id = p_cat_curr_v.version_pw_cat_id
	and p_cat.type_mean in ("DOT", "PHASE")
	)
	)

join	p_comp
where	p_comp.pathway_catalog_id = outerjoin(p_cat.pathway_catalog_id)

join	p_p_comp
where	p_p_comp.person_id = outerjoin(p_comp.updt_id)

join	clin_cat_cv
where	clin_cat_cv.code_value = outerjoin(p_comp.dcp_clin_cat_cd)

join	pp_note
where	pp_note.long_text_id = outerjoin(p_comp.parent_entity_id)
and	pp_note.parent_entity_name = outerjoin("PATHWAY_COMP")

join	ocs
where	ocs.synonym_id = outerjoin(p_comp.parent_entity_id)

join	occ
where	occ.outcome_catalog_id = outerjoin(p_comp.parent_entity_id)

join	p_cat_sub
where	p_cat_sub.pathway_catalog_id = outerjoin(p_comp.parent_entity_id)

join	p_rel
where	p_rel.pw_cat_s_id = outerjoin(p_cat.pathway_catalog_id)
and	p_rel.type_mean = outerjoin("GROUP")

join	p_cat_phase
where	p_cat_phase.pathway_catalog_id = outerjoin(p_rel.pw_cat_t_id)

join	pw_os
where	pw_os.pathway_comp_id = outerjoin(p_comp.pathway_comp_id)

join	os
where	os.order_sentence_id = outerjoin(pw_os.order_sentence_id)

join	os_comm
where	os_comm.long_text_id = outerjoin(os.ord_comment_long_text_id)

order by
	p_cat.description_key
	, p_cat.version
	, p_cat.pathway_catalog_id
;	, clin_cat_cv.collation_seq
	, p_comp.sequence
	, pw_os.order_sentence_seq

with	time = 60
