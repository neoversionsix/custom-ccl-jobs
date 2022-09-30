select distinct	; PowerForm details	; 'distinct' used for multiple codified_response_options
/*
Is there a way that this audit can be broken down by timeframes?

This part sets the timeframe (line 149)

    ce_cd_res.updt_dt_tm between
        CNVTDATETIME("01-JUL-2022 00:00:00.00")
        and
        CNVTDATETIME("01-JUL-2022 00:00:00.00")     

 */

	form_display = form_ref.description
;	, form_name = form_ref.definition	
	, form_active_ind = form_ref.active_ind	
	, form_beg_date = format(form_ref.beg_effective_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, form_end_date = format(form_ref.end_effective_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, form_instance_id = form_ref.dcp_form_instance_id	
	, form_ref_id =  form_ref.dcp_forms_ref_id	
	, section = form_sec.description	
	, section_active_ind = form_sec.active_ind	
	, section_beg_date = format(form_sec.beg_effective_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, section_end_date = format(form_sec.end_effective_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, section_instance_id = form_sec.dcp_section_instance_id	
	, section_ref_id = form_sec.dcp_section_ref_id	
	, input_seq = form_input.input_ref_seq	
 	, input_type = evaluate(form_input.input_type	
 	, 1, "Label Control"	
 	, 2, "Numeric Control"	
 	, 3, "FlexUnit Control"	
 	, 4, "List Control"	
 	, 5, "MAGrid Control"	
 	, 6, "FreeText Control"	
 	, 7, "Calculation Control"	
 	, 8, "StaticUnit Control"	
 	, 9, "AlphaCombo Control"	
 	, 10, "DateTime Control"	
 	, 11, "Allergy Control"	
 	, 12, "ImageHolder Control"	
 	, 13, "RTFEditor Control"	
 	, 14, "Discrete Grid"	
 	, 15, "RAlpha Grid"	
 	, 16, "Comment Control"	
 	, 17, "Power Grid"	
 	, 18, "Provider Control"	
 	, 19, "Ultra Grid"	
 	, 20, "Tracking Control1"	
 	, 21, "Conversion Control"     	
 	, 22, "Numeric Control2"	
 	, 23, "Nomenclature Control"	
 	, "Unknown Type"	
	)	
	, input_description = evaluate(form_input.input_type 	
	, 1, nvp_lbl.pvc_value	
	, 4, concat("DTA: ", char(34), trim(uar_get_code_display(dta.task_assay_cd)), char(34))	
	, 6,  concat("DTA: ", char(34), trim(uar_get_code_display(dta.task_assay_cd)), char(34))	
	, 10,  concat("DTA: ", char(34), trim(uar_get_code_display(dta.task_assay_cd)), char(34))	
	)	
	, font_pvc_value = nvp_font_effects.pvc_value	
	, dta_display = uar_get_code_display(dta.task_assay_cd)	
;	, dta_description = dta.description	
;	, dta_mnemonic = dta.mnemonic	
;	, dta_result_type = uar_get_code_display(dta.default_result_type_cd)  	
	, dta_cd = if(dta.task_assay_cd > 0) cnvtstring(dta.task_assay_cd)	
	else ""	
	endif	
;	, codified_response_options = listagg (n.source_string, "; ") over (partition by form_ref.dcp_form_instance_id	; comment out if returning a row for each codified response.
;	, form_sec.dcp_section_instance_id	;                                                              " "
;	, form_input.dcp_input_ref_id	;                                                              " "
;	, rrf.reference_range_factor_id	;                                                              " "
;	order by ar.sequence	;                                                              " "
;	)	;                                                              " "
;	, codified_response_nomenclature_ids = listagg (n.nomenclature_id, ", ") over (partition by form_ref.dcp_form_instance_id	;                                                              " "
;	, form_sec.dcp_section_instance_id	;                                                              " "
;	, form_input.dcp_input_ref_id	;                                                              " "
;	, rrf.reference_range_factor_id	;                                                              " "
;	order by ar.sequence	;                                                              " "
;	)	;                                                              " "
	, codified_response_option = n.source_string	; comment back in to return a row for each codified response.
	, nomenclature_id = if(n.nomenclature_id > 0) cnvtstring(n.nomenclature_id)	;                                                              " "
	else ""	;                                                              " "
	endif	;                                                              " "
	, mapped_event_code_display = uar_get_code_display(dta.event_cd)	
	, mapped_event_code = if (dta.task_assay_cd > 0) cnvtstring(dta.event_cd)	
	else ""	
	endif	
;	, event_code_results = if(dta.task_assay_cd > 0 and dta_ces.count >"0") cnvtstring(dta_ces.count)	; if row is for a DTA, and DTA clinical event count > 0, return DTA clinical event count
;	elseif (dta.task_assay_cd > 0) "0"	; elseif row is for a DTA, return 0
;	elseif (form_input.input_ref_seq = 1) cnvtstring(form_ces.count)	; else row is form label, return form clinical event count
;	else ""	
;	endif	
	, nomenclature_results = if(ar.nomenclature_id> 0 and nom_ces.count >"0") cnvtstring(nom_ces.count)	; comment back in to return a row for each codified response.
	elseif (ar.nomenclature_id> 0) "0"	;                                                              " "
	else ""	;                                                              " "
	endif	;                                                              " "
	, input_ref_id = form_input.dcp_input_ref_id	
	, form_rank = dense_rank() over (partition by 0	
	order by 	
	form_ref.description	
	, form_ref.dcp_form_instance_id	
	)	
		
from		
	dcp_forms_ref form_ref_curr_v	
	, (left join dcp_forms_ref form_ref on form_ref.dcp_forms_ref_id = form_ref_curr_v.dcp_forms_ref_id)	
	, (left join prsnl p_form_ref on p_form_ref.person_id = form_ref.updt_id)	
	, (left join dcp_forms_def form_def on form_def.dcp_form_instance_id = form_ref.dcp_form_instance_id	
;	and form_def.active_ind = 1	
	)	
	, (left join dcp_section_ref form_sec on form_sec.dcp_section_ref_id = form_def.dcp_section_ref_id	
	and form_sec.active_ind = 1	; must be set to '1', else rows will return that correspond to previous versions of the section
	)	
	, (left join dcp_input_ref form_input on form_input.dcp_section_instance_id = form_sec.dcp_section_instance_id	
;	and form_input.active_ind = 1	
	)	
	, (left join name_value_prefs nvp_lbl on nvp_lbl.parent_entity_id = form_input.dcp_input_ref_id	; PowerForm Labels
	and nvp_lbl.parent_entity_name = "DCP_INPUT_REF"	
	and nvp_lbl.pvc_name = "caption"	
;	and nvp_lbl.merge_id > 0	
;	and nvp_lbl.active_ind = 1	
	)	
	, (left join name_value_prefs nvp_font_effects on nvp_font_effects.parent_entity_id = form_input.dcp_input_ref_id	; PowerForm Label Fonts
	and nvp_font_effects.parent_entity_name = "DCP_INPUT_REF"	
	and nvp_font_effects.pvc_name = "fonteffects"	
;	and nvp_font_effects.merge_id > 0	
;	and nvp_font_effects.active_ind = 1	
	)	
	, (left join name_value_prefs nvp_dta on nvp_dta.parent_entity_id = form_input.dcp_input_ref_id	
	and nvp_dta.parent_entity_name = "DCP_INPUT_REF"	
	and nvp_dta.pvc_name = "discrete_task_assay"	
;	and nvp_dta.merge_id > 0	
;	and nvp_dta.active_ind = 1	
	)	
	, (left join discrete_task_assay dta on dta.task_assay_cd = nvp_dta.merge_id	
;	and dta.active_ind = 1	
	)	
	, (left join reference_range_factor rrf on rrf.task_assay_cd = dta.task_assay_cd	
	and rrf.active_ind = 1	; must be set to '1', else junk rows will return that correspond to previous versions of the rrf
	)	
	, (left join alpha_responses ar on ar.reference_range_factor_id = rrf.reference_range_factor_id)	
	, (left join nomenclature n on n.nomenclature_id = ar.nomenclature_id)	
	, (left join (select ce.event_cd, count = count(*) from clinical_event ce group by ce.event_cd) dta_ces on dta_ces.event_cd = dta.event_cd)	; DTA results
	, (left join (select ce.event_cd, count = count(*) from clinical_event ce group by ce.event_cd) form_ces on form_ces.event_cd = form_ref.event_cd)	; form results
	, (left join (select ce_cd_res.nomenclature_id, count = count(*) 	; nomenclature results  (comment back in to return a row for each codified response).
	from ce_coded_result ce_cd_res 	; comment back in to return a row for each codified response.
	where ce_cd_res.nomenclature_id > 0 	;
    and
    ce_cd_res.updt_dt_tm between
        CNVTDATETIME("01-JAN-2022 00:00:00.00")
        and
        CNVTDATETIME("01-FEB-2022 00:00:00.00")                           
	group by ce_cd_res.nomenclature_id	;                                      
	) nom_ces on nom_ces.nomenclature_id = ar.nomenclature_id	;
	)	;                 
		
plan	form_ref_curr_v	
where	form_ref_curr_v.dcp_form_instance_id = (select max(dcp_form_instance_id)	
	from dcp_forms_ref	
	where dcp_forms_ref_id = form_ref_curr_v.dcp_forms_ref_id	
	)	
and	form_ref_curr_v.description = "Nutrition Assessment"	; PowerForm Display
;and	form_ref_curr_v.dcp_forms_ref_id = 239315865	; PowerForm ref ID
join	form_ref	
where	form_ref.dcp_form_instance_id = form_ref_curr_v.dcp_form_instance_id	; only return most recent form version. Comment out for all form versions.
join	p_form_ref	
join	form_def	
join	form_sec	
where	form_sec.description = "Nutrition Diagnosis (PES Statement)"	
join	form_input	
join	nvp_lbl	
join	nvp_font_effects	
join	nvp_dta	
join	dta	
join	rrf	
join	ar	
join	n	
join	dta_ces	
join	form_ces	
join	nom_ces	
		
order by		
	form_ref_curr_v.description	
	, cnvtint(form_ref.dcp_forms_ref_id)	
	, cnvtint(form_ref.dcp_form_instance_id)	
	, cnvtint(form_def.section_seq)	
	, cnvtint(form_sec.dcp_section_instance_id)	
	, cnvtint(form_input.input_ref_seq)	
	, cnvtint(dta.task_assay_cd)	
	, cnvtint(ar.nomenclature_id)	; comment back in to return a row for each codified response.
	, 0 	
		
with	time = 120	
