select  ; Medication primary orderable alignment 1 of 2 < M 
    catalog_type = uar_get_code_display(oc.catalog_type_cd) 
    , catalog_rank = dense_rank() over (partition by 0  
    order by    
    cv_cat.display_key  
    )   
    , activity_type = uar_get_code_display(oc.activity_type_cd) 
    , activity_rank = dense_rank() over (partition by 0 
    order by    
    cv_cat.display_key  
    , cv_act.display_key    
    )   
    , activity_subtype = uar_get_code_display(oc.activity_subtype_cd)   
    , sub_act_rank = dense_rank() over (partition by 0  
    order by    
    cv_cat.display_key  
    , cv_act.display_key    
    , nullval(cv_sub_act.display_key, 0)    
    )   
    , primary_description = oc.description  
    , mltm_mnemonic = if (mltmmanfdn.drug_synonym_id != null) mltmmanfdn.manufacturer_ordered_drug_name ; if mltmmanfdn.drug_synonym_id exists, return mltmmanfdn.manufacturer_ordered_drug_name
    elseif (mltmdn.drug_synonym_id != null) mltmdn.drug_name    ; if mltmmanfdn.drug_synonym_id does not exist, but mltmdn.drug_synonym_id does, return mltmdn.drug_name
    else "-"    ; if neither mltmmanfdn.drug_synonym_id nor mltmdn.drug_synonym_id exist, return "-"
    endif   
    , description_mltm_match = if (mltmmanfdn.drug_synonym_id != null)  ; if mltmmanfdn.drug_synonym_id exists
    if (oc.description = mltmmanfdn.manufacturer_ordered_drug_name) "1" ; if mltmmanfdn.drug_synonym_id exists and primary description matches mltmmanfdn.manufacturer_ordered_drug_name, return "1". 
    else "0"    ; if mltmmanfdn.drug_synonym_id exists but primary description does not match mltmmanfdn.manufacturer_ordered_drug_name, return "0". 
    endif   
    elseif (mltmdn.drug_synonym_id != null) ; if mltmdn.drug_synonym_id exists
    if (oc.description = mltmdn.drug_name) "1"  ; if mltmdn.drug_synonym_id and primary description matches mltmdn.drug_name, return "1". 
    else "0"    ; if mltmdn.drug_synonym_id exists but primary description does not match mltmdn.drug_name, return "0". 
    endif   
    else "-"    
    endif   
;   , department_display_name = oc.dept_display_name    
    , primary_mnemonic = oc.primary_mnemonic    
    , primary_mnemonic_active = ocs.active_ind  
    , catalog_cki = oc.cki  
    , catalog_cki_count = count(oc.catalog_cd) over (partition by oc.cki)   
    , cat_concept_cki = oc.concept_cki  
    , primary_synonym_last_update = format(ocs.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")   
    , primary_synonym_last_updater = if(ocs.synonym_id > 0 and p_ocs.name_full_formatted = null) cnvtstring(ocs.updt_id)    
    else p_ocs.name_full_formatted  
    endif   
    , immunization_ind = if(cve_IMMUNIZATIONIND.field_value = "1") "x"  
    else "" 
    endif   
    , imm_ind_last_update = format(cve_IMMUNIZATIONIND.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")   
    , imm_ind_last_updater = if(cve_IMMUNIZATIONIND.code_value > 0 and p_cve_IMMUNIZATIONIND.name_full_formatted = null) cnvtstring(cve_IMMUNIZATIONIND.updt_id)    
    else p_cve_IMMUNIZATIONIND.name_full_formatted  
    endif   
    , orders_for_all_synonyms_under_primary = "OMITTED"
    /* 
    if(o_count.orderable_orders > "0") o_count.orderable_orders 
    else "0"    
    endif   
    */
    , results_for_all_synonyms_under_primary = if(res_count.results > "0") res_count.results    
    else "0"    
    endif   
    , alias_inbound_contributor_source = uar_get_code_display(cva_oc.contributor_source_cd) 
    , alias_inbound = if (cva_oc.code_value > 0 and cva_oc.alias = " ") "<sp>"  
    else cva_oc.alias   
    endif   
    , alias_inbound_last_update = format(cva_oc.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")  
    , alias_inbound_last_updater = if(cva_oc.code_value > 0 and  p_cva_oc.name_full_formatted = null) cnvtstring(cva_oc.updt_id)    
    else p_cva_oc.name_full_formatted   
    endif   
    , alias_outbound_contributor_source = uar_get_code_display(cvo_oc.contributor_source_cd)    
    , alias_outbound = if (cvo_oc.code_value > 0 and cvo_oc.alias = " ") "<sp>" 
    else cvo_oc.alias   
    endif   
    , alias_outbound_last_update = format(cvo_oc.updt_dt_tm, "dd/mm/yyyy hh:mm:ss") 
    , alias_outbound_last_updater = if(cvo_oc.code_value > 0 and p_cvo_oc.name_full_formatted  = null) cnvtstring(cvo_oc.updt_id)   
    else p_cvo_oc.name_full_formatted   
    endif   
    , mapped_task = ot.task_description 
    , mapped_task_id = if (ot.reference_task_id = 0) "" 
    else cnvtstring (ot.reference_task_id)  
    endif   
    , task_mapping_last_update = format(otxr.updt_dt_tm, "dd/mm/yyyy hh:mm:ss") 
    , task_mapping_last_updater = if(otxr.reference_task_id > 0 and  p_otxr.name_full_formatted = null) cnvtstring(otxr.updt_id)    
    else p_otxr.name_full_formatted 
    endif   
    , mapped_event_code_display = cv_ec.display 
    , mapped_event_code = if (cver.event_cd = 0) "" 
    else cnvtstring (cver.event_cd) 
    endif   
    , event_code_mapping_last_update = format(cver.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")   
    , event_code_mapping_last_updater = if(cver.event_cd > 0 and  p_cver.name_full_formatted = null) cnvtstring(cver.updt_id)   
    else p_cver.name_full_formatted 
    endif   
    , mapped_event_set = uar_get_code_display(ese_0.event_set_cd)   
    , immunization_event_set = if(esc_es.parent_event_set_cd > 0) "x"   
    else "" 
    endif   
    , mapped_event_set_cd = if (ese_0.event_set_cd = 0) ""  
    else cnvtstring (ese_0.event_set_cd)    
    endif   
    , primary_cki_status = if (oc.cki not in  (""," ",null,"IGNORE"))   ; if DNUM is populated
    if (mltmdn.is_obsolete = "F") "current" ; if mltmdm has drug listed as obsolete = false, return "current"
    elseif (mltmdn.is_obsolete = "T") "obsolete"    ; if mltmdm has drug listed as obsolete, return "obsolete"
    else "invalid"  ; if DNUM is not valid, return "invalid"
    endif   
    else "-"    ; if DNUM is not populated, return "-"
    endif   
    , description_mnemonic_match = if (oc.description = oc.primary_mnemonic) "1"    
    elseif (ocs.active_ind = 0 and oc.primary_mnemonic in (build("zzz",oc.description)  
    ,build("zzzz",oc.description)   
    ,build("zzzzz",oc.description)  
    ,build("zzzzzz",oc.description) 
    ,build("zzzzzzz",oc.description))) "1"  
    else "0"    
    endif   
    , alias_in_out_match = if (oc.active_ind = 1 and (cva_oc.code_value > 0 or cvo_oc.code_value > 0))  ; if primary is active and has either an alias inbound or outbound
    if (cva_oc.alias = cvo_oc.alias) "1"    ; if inbound alias matches outbound alias, return "1"
    else "0"    
    endif   
    else "-"    ; if is primary is inactive or has no aliases, return "-"
    endif   
    , task_mnemonic_match = if (ocs.active_ind = 1 and ot.reference_task_id > 0)    ; If primary is active and has a mapped task
    if (ot.task_description = oc.primary_mnemonic) "1"  ; if task description matches the primary mnemonic, return "1"
    else "0"    
    endif   
    else "-"    ; if primary is inactive or has no mapped task, return "-" 
    endif   
    , event_code_mnemonic_match = if (ocs.active_ind = 1 and cver.event_cd > 0 and oc.orderable_type_flag not in (2, 3, 6)) ; If primary is active and has a mapped event code, and is not a Supergroup, CarePlan or Order Set
    if (textlen(oc.primary_mnemonic) < 41 and uar_get_code_display(cver.event_cd) = oc.primary_mnemonic) "1"    ; if primary has 40 or less characters, and matches the event code, return "1"
    elseif ( textlen(oc.primary_mnemonic) > 40) "Primary Mnemonic > 40 characters"  ; if primary has more than 40 characters, return message
    else "0"    
    endif   
    else "-"    ; if primary is inactive or has no mapped event code or is a Supergroup, CarePlan or Order Set, return "-" 
    endif   
    , event_set_event_code_match = if (ocs.active_ind = 1 and cver.event_cd > 0 and oc.orderable_type_flag not in (2, 3, 6))    ; If primary is active and has a mapped event code, and is not a Supergroup, CarePlan or Order Set
    if ( text(uar_get_code_display(ese_0.event_set_cd)) = text(uar_get_code_display(cver.event_cd) )) "1"   ; if event set display matches event code display, return "1"
    else "0"    
    endif   
    else "-"    ; if primary is inactive or has no mapped event code or is a Supergroup, CarePlan or Order Set, return "-" 
    endif   
    , dup_check_level = evaluate (dcheck.dup_check_seq  
    ,0, ""  
    ,1, "Orderable" 
    , 2, "Catalog Type" 
    , 3, "Activity Type"    
    )   
    , dup_check_status = if( dcheck.catalog_cd > 0) cnvtstring(dcheck.active_ind)   
    else "" 
    endif   
    , dup_check_behind_action = uar_get_code_display(dcheck.min_behind_action_cd)   
    , dup_check_behind_min = if(dcheck.catalog_cd > 0) cnvtstring(dcheck.min_behind)    
    else "" 
    endif   
    , dup_check_ahead_action = uar_get_code_display(dcheck.min_ahead_action_cd) 
    , dup_check_ahead_min = if(dcheck.catalog_cd > 0) cnvtstring(dcheck.min_ahead)  
    else "" 
    endif   
    , dup_check_exact_action = uar_get_code_display(dcheck.exact_hit_action_cd) 
    , op_dup_check_status = dcheck.outpat_flex_ind  
    , op_dup_check_behind_action = uar_get_code_display(dcheck.outpat_min_ahead_action_cd)  
    , op_dup_check_behind_min = if(dcheck.catalog_cd > 0) cnvtstring(dcheck.outpat_min_behind)  
    else "" 
    endif   
    , op_dup_check_ahead_action = uar_get_code_display(dcheck.outpat_min_ahead_action_cd)   
    , op_dup_check_ahead_min = if( dcheck.catalog_cd > 0) cnvtstring(dcheck.outpat_min_ahead)   
    else "" 
    endif   
    , op_dup_check_exact_action = uar_get_code_display(dcheck.outpat_exact_hit_action_cd)   
    , dup_check_last_update = format(dcheck.updt_dt_tm, "dd/mm/yy hh:mm:ss")    
    , dup_check_last_updater = if(dcheck.catalog_cd > 0 and  p_dcheck.name_full_formatted = null) cnvtstring(dcheck.updt_id)    
    else p_dcheck.name_full_formatted   
    endif   
    , discontinue_display_days = oc.dc_display_days 
    , discontinue_interaction_days = oc.dc_interaction_days 
    , form_association_level = oc.form_level    
    , form_association_name =  form.description 
    , clinical_category = uar_get_code_display (oc.dcp_clin_cat_cd) 
    , autoverify_multum_interaction = evaluate (oc.ic_auto_verify_flag, 
    0,"No Setting", 
    1,"No (No Auto verification performed)",    
    2,"No - with clinical checking (If alerts exist, auto verification is not performed)",  
    3,"Yes - with reason (Only auto verify if a reason was provided with the alert(s))",    
    4,"Yes (Auto verify regardless of alerts)") 
    , autoverify_discern_rules = evaluate (oc.discern_auto_verify_flag, 
    0,"No Setting", 
    1,"No (No Auto verification performed)",    
    2,"No - with clinical checking (If alerts exist, auto verification is not performed)",  
    3,"Yes - with reason (Only auto verify if a reason was provided with the alert(s))",    
    4,"Yes (Auto verify regardless of alerts)") 
;   , radiology_vetting = evaluate (oc.vetting_approval_flag,   
;   0, "Not a vetting order",   
;   1, "Vetting, does not require approval",    
;   2, "Vetting, requries approval")    
    , stop_type = uar_get_code_display (oc.stop_type_cd)    
    , stop_duration = oc.stop_duration  
    , stop_duration_units = uar_get_code_display (oc.stop_duration_unit_cd) 
;   , print_consent_form = oc.consent_form_ind  
;   , consent_form_format = uar_get_code_display (oc.consent_form_format_cd)    
;   , consent_form_routing = dorcon.route_description   
    , print_requisitions = oc.print_req_ind 
    , requisition_format = uar_get_code_display (oc.requisition_format_cd)  
    , requisition_routing = dorreq.route_description    
    , complete_on_order = oc.complete_upon_order_ind    
    , cancel_order_upon_discharge = oc.auto_cancel_ind  
    , disable_order_comment = oc.disable_order_comment_ind  
    , continuing_order_indicator = evaluate (oc.cont_order_method_flag, 
    0,"order",  
    1,"task",   
    2,"pharmacy")   
    , orderable_type = evaluate(oc.orderable_type_flag, 
    0,"Standard",   
            1,"Standard",   
            2,"Supergroup", 
            3,"CarePlan",   
            4,"AP Special", 
            5,"Department Only",    
            6,"Order Set",  
            7,"Home Health Problem",    
            8,"Multi-ingredient",   
            9,"Interval Test",  
            10,"Freetext")  
    , primary_settings_last_update = format(oc.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")   
    , primary_settings_last_updater = if(oc.catalog_cd > 0 and  p_oc.name_full_formatted = null) cnvtstring(oc.updt_id) 
    else p_oc.name_full_formatted   
    endif   
    , catalog_code = oc.catalog_cd  
    , domain_alignment_comparison_text1 = if (ocs.active_ind = 1)   
    build(  
    uar_get_code_display (oc.catalog_type_cd)   
    , "|", uar_get_code_display (oc.activity_type_cd)   
    , "|", uar_get_code_display (oc.activity_subtype_cd)    
    , "|", oc.description   
;   , "|", oc.dept_display_name 
    , "|", oc.primary_mnemonic  
    , "|", oc.cki   
    , "|", cve_IMMUNIZATIONIND.field_value  
    , "|", cva_oc.alias 
    , "|", cvo_oc.alias 
    , "|", ot.task_description  
    , "|", cv_ec.display    
    , "|", uar_get_code_display(ese_0.event_set_cd) 
    , "|", if(dcheck.active_ind = 1) uar_get_code_display(dcheck.min_behind_action_cd) else "-" endif   
    , "|", if(dcheck.active_ind = 1) cnvtstring(dcheck.min_behind) else "-" endif   
    , "|", if(dcheck.active_ind = 1) uar_get_code_display(dcheck.min_ahead_action_cd) else "-" endif    
    , "|", if(dcheck.active_ind = 1) cnvtstring(dcheck.min_ahead) else "-" endif    
    , "|", if(dcheck.active_ind = 1) uar_get_code_display(dcheck.exact_hit_action_cd) else "-" endif    
    , "|", oc.cki   
    )   
    else "" 
    endif   
    , domain_alignment_comparison_text2 = if (ocs.active_ind = 1)   
    build(  
    uar_get_code_display (oc.catalog_type_cd)   
    , "|", uar_get_code_display (oc.activity_type_cd)   
    , "|", uar_get_code_display (oc.activity_subtype_cd)    
    , "|", oc.primary_mnemonic  
    , "|", oc.dc_display_days   
    , "|", oc.dc_interaction_days   
    , "|", oc.form_level    
    , "|", form.description 
    , "|", uar_get_code_display (oc.dcp_clin_cat_cd)    
    , "|", oc.ic_auto_verify_flag   
    , "|", oc.discern_auto_verify_flag  
    , "|", oc.vetting_approval_flag 
    , "|", uar_get_code_display (oc.stop_type_cd)   
    , "|", oc.stop_duration 
    , "|", uar_get_code_display (oc.stop_duration_unit_cd)  
    , "|", oc.consent_form_ind  
    , "|", uar_get_code_display (oc.consent_form_format_cd) 
    , "|", dorcon.route_description 
    , "|", oc.print_req_ind 
    , "|", uar_get_code_display (oc.requisition_format_cd)  
    , "|", dorreq.route_description 
    , "|", oc.complete_upon_order_ind   
    , "|", oc.auto_cancel_ind   
    , "|", oc.disable_order_comment_ind 
    , "|", oc.cont_order_method_flag    
    , "|", oc.orderable_type_flag   
    )   
    else "" 
    endif   
    , primary_rank = dense_rank() over (partition by 0  
    order by    
    cv_cat.display_key  
    , cv_act.display_key    
    , nullval(cv_sub_act.display_key, 0)    ; 'nullval' used as dense_rank fails when cv_sub_act.display_key = null
    , cnvtupper(oc.primary_mnemonic)    
    )   
;   , corresponding_result = uar_get_code_display(cva_ec.code_value)    
        
from        
    order_catalog   oc  
    , (left join prsnl p_oc on p_oc.person_id = oc.updt_id) 
    , (left join code_value cv_cat on cv_cat.code_value = oc.catalog_type_cd)   
    , (left join code_value cv_act on cv_act.code_value = oc.activity_type_cd)  
    , (left join code_value cv_sub_act on cv_sub_act.code_value = oc.activity_subtype_cd)   
    , (left join order_catalog_synonym ocs on ocs.catalog_cd =  oc.catalog_cd   
    and ocs.mnemonic_type_cd = 2583 ; code value for 'Primary' from code set 6011
    )   
    , (left join prsnl p_ocs on p_ocs.person_id = ocs.updt_id)  
    , (left join code_value_alias cva_oc on cva_oc.code_value = oc.catalog_cd   
;   and cva_oc.contributor_source_cd = 10630393 ; code value for 'WH_LOCAL' contributor source
    )   
    , (left join prsnl p_cva_oc on p_cva_oc.person_id = cva_oc.updt_id) 
    , (left join code_value_outbound cvo_oc on cvo_oc.code_value = oc.catalog_cd    
;   and cvo_oc.contributor_source_cd = 10630393 ; code value for 'WH_LOCAL' contributor source
    )   
    , (left join prsnl p_cvo_oc on p_cvo_oc.person_id = cvo_oc.updt_id) 
    , (left join order_task_xref otxr on otxr.catalog_cd = oc.catalog_cd)   
    , (left join prsnl p_otxr on p_otxr.person_id = otxr.updt_id)   
    , (left join order_task ot on ot.reference_task_id = otxr.reference_task_id)    
    , (left join code_value_event_r cver on cver.parent_cd = oc.catalog_cd) 
    , (left join prsnl p_cver on p_cver.person_id = cver.updt_id)   
    , (left join code_value cv_ec on cv_ec.code_value = cver.event_cd)  
    , (left join v500_event_set_explode ese_0 on ese_0.event_cd = cver.event_cd 
    and ese_0.event_set_level = 0   ; primitive event set only
    )   
    , (left join v500_event_set_canon esc_es on esc_es.event_set_cd = ese_0.event_set_cd    ; primative event set canon
    and esc_es.parent_event_set_cd = (select code_value 
     from code_value    
    where code_set = 93 ; event sets code set
    and display = "Immunizations"   
    )   
    )   
    , (left join mltm_manufact_drug_name mltmmanfdn on concat("MUL.ORD-SYN!",trim(cnvtstring(mltmmanfdn.drug_synonym_id))) = ocs.cki)   
    , (left join mltm_drug_name mltmdn on concat("MUL.ORD-SYN!",trim(cnvtstring(mltmdn.drug_synonym_id))) = ocs.cki)    
    , (left join dup_checking dcheck on dcheck.catalog_cd = oc.catalog_cd)  
    , (left join prsnl p_dcheck on p_dcheck.person_id = dcheck.updt_id) 
    , (left join dcp_forms_ref form on form.dcp_forms_ref_id = oc.form_id   
    and form.active_ind = 1 
    )   
    , (left join dcp_output_route dorcon on dorcon.dcp_output_route_id = oc.consent_form_routing_cd)    
    , (left join dcp_output_route dorreq on dorreq.dcp_output_route_id = oc.requisition_routing_cd) 
/* ORDERS
    , (left join (select o.catalog_cd   
    , orderable_orders = count(*)   
    from orders o   
    group by o.catalog_cd   
    ) o_count on o_count.catalog_cd = oc.catalog_cd 
    )    
*/
    , (left join (select ce.catalog_cd  
    , results = count(*)    
    from clinical_event ce  
    where ce.view_level = 1 
    group by ce.catalog_cd  
    ) res_count on res_count.catalog_cd = oc.catalog_cd 
    )   
;   , (left join code_value_alias cva_ec on cva_ec.alias = cvo_oc.alias 
;   and cva_ec.code_set = 72    ; "EVENT_CODE" code set
;   and cva_ec.contributor_source_cd = 10630393 ; "WH_LOCAL" from code set 73
;   )   
    , (left join code_value_extension cve_IMMUNIZATIONIND on cve_IMMUNIZATIONIND.code_value = oc.catalog_cd 
    and cve_IMMUNIZATIONIND.field_name = "IMMUNIZATIONIND"  
    and cve_IMMUNIZATIONIND.field_value != " "  
    )   
    , (left join prsnl p_cve_IMMUNIZATIONIND on p_cve_IMMUNIZATIONIND.person_id = cve_IMMUNIZATIONIND.updt_id)  
        
plan    oc  
;where  oc.catalog_type_cd not in (2513, 2516, 2517, 0) ; code values for 'Laboratory', 'Pharmacy' and 'Radiology' from code set 6000. '0' prevents '0 row' on oc table from returning.
;where  oc.catalog_type_cd = 2513   ; code value for 'Laboratory' from code set 6000
;where  oc.catalog_type_cd = 2515   ; code value for 'Patient Care' from code set 6000
where   oc.catalog_type_cd = 2516   ; code value for 'Pharmacy' from code set 6000
;where  oc.catalog_type_cd = 2517   ; code value for 'Radiology' from code set 6000
;where  oc.catalog_type_cd in (2519, 84871493)  ; code values for 'Surgery' and 'CMBS Code - SN' from code set 6000
and oc.orderable_type_flag not in (2,3,6,8) ; exclude 'Supergroup','CarePlan', 'Order Set', and 'Multi-ingredient' (IV Set) orderables
;and    cnvtupper (oc.primary_mnemonic) = "Aspirin*"
and cnvtupper (oc.primary_mnemonic) < "M*"  ; use these if the audit fails in any domain
/*  LENGTH FILTERS
and cnvtupper (oc.primary_mnemonic) < "M*"  ; use these if the audit fails in any domain
;and    cnvtupper (oc.primary_mnemonic) >= "M*" ; (synonym_rank may be corrupted between the audit divisions)
*/
;and    oc.catalog_cd = 1234567 
join    p_oc    
join    cv_cat  
join    cv_act  
join    cv_sub_act  
join    ocs ; Primary synonym
join    p_ocs   
join    cva_oc  ; orderable inbound alias
join    p_cva_oc    
join    cvo_oc  ; orderable outbound alias
join    p_cvo_oc    
join    otxr    
join    p_otxr  
join    ot  ; order task
join    cver    
join    p_cver  
join    cv_ec   ; orderable linked event code
join    ese_0   ; event code primitive event set
join    esc_es  ; primative event set canon
join    mltmmanfdn  
join    mltmdn  
join    dcheck  
join    p_dcheck    
join    form    
join    dorcon  
join    dorreq  
;join   o_count ; ORDERS
join    res_count   
;join   cva_ec  
join    cve_IMMUNIZATIONIND 
join    p_cve_IMMUNIZATIONIND   
        
order by        
    catalog_rank    
    , activity_rank 
    , sub_act_rank  
    , primary_rank  
    , dcheck.dup_check_seq  
    , cva_oc.alias  
    , cvo_oc.alias  
    , ot.task_description   
    , cv_ec.display 
    , 0 
        
with    time = 1200 
