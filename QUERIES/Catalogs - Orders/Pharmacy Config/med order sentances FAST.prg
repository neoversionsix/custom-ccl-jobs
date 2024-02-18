select	; Medication order sentence alignment	
	catalog_type = cv_cat.display	
	, catalog_rank = dense_rank() over (partition by 0	
	order by	
	cv_cat.display_key	
	)	
	, activity_type = cv_act.display	
	, activity_rank = dense_rank() over (partition by 0	
	order by	
	cv_cat.display_key	
	, cv_act.display_key	
	)	
	, sub_activity_type = cv_sub_act.display	
	, sub_act_rank = dense_rank() over (partition by 0	
	order by	
	cv_cat.display_key	
	, cv_act.display_key	
	, nullval(cv_sub_act.display_key, 0)	
	)	
	, primary_cki = oc.cki	
	, primary_mnemonic = oc.primary_mnemonic	
;	, primary_orderable_type = evaluate (oc.orderable_type_flag	
;	, 0, "Standard"	
;	, 1, "Standard"	
;	, 2, "Supergroup"	
;	, 3, "CarePlan"	
;	, 4, "AP Special"	
;	, 5, "Department Only"	
;	, 6, "Order Set"	
;	, 7, "Home Health Problem"	
;	, 8, "Multi-ingredient"	
;	, 9, "Interval Test"	
;	, 10, "Freetext"	
;	)	
;	, synonyms_under_primary = count (distinct ocs.synonym_id) over (partition by oc.catalog_cd)	
;	, catalog_cd = oc.catalog_cd	
	, primary_rank = dense_rank() over (partition by 0	
	order by	
;	cv_cat.display_key	
	cv_act.display_key	
	, nullval(cv_sub_act.display_key, 0)	; 'nullval' used as dense_rank fails when cv_sub_act.display_key = null
	, cnvtupper(oc.primary_mnemonic)	
	)	
	, synonym_cki = ocs.cki	
;	, synonym_cki_count = count(distinct ocs.synonym_id) over (partition by ocs.cki)	
	, synonym_type = uar_get_code_display (ocs.mnemonic_type_cd )	
	, synonym_mnemonic = ocs.mnemonic	
	, synonym_oef = oef_ocs.oe_format_name	
	, synonym_active = ocs.active_ind	
 	, synonym_hide = ocs.hide_flag	
;	, synonym_rxmask = concat (	
;	if (mod(cnvtint(ocs.rx_mask), 2) = 1 and cnvtint(ocs.rx_mask) >= 2) "Diluent; "	
;	elseif (mod(cnvtint(ocs.rx_mask), 2) = 1) "Diluent"	
;	else trim("") endif	
;	, if (mod(cnvtint(ocs.rx_mask), 4) >= 2 and cnvtint(ocs.rx_mask) >= 4) "Additive; "	
;	elseif (mod(cnvtint(ocs.rx_mask), 4) >= 2) "Additive"	
;	else trim("") endif	
;	, if (mod(cnvtint(ocs.rx_mask), 8) >= 4 and cnvtint(ocs.rx_mask) >= 8) "Med; "	
;	elseif (mod(cnvtint(ocs.rx_mask), 8) >= 4) "Med"	
;	else trim("") endif	
;	, if (mod(cnvtint(ocs.rx_mask), 16) >= 8 and cnvtint(ocs.rx_mask) >= 16) "TPN; "	
;	elseif (mod(cnvtint(ocs.rx_mask), 16) >= 8) "TPN"	
;	else trim("") endif	
;	, if (mod(cnvtint(ocs.rx_mask), 32) >= 16 and cnvtint(ocs.rx_mask) >= 32) "Sliding Scale; "	
;	elseif (mod(cnvtint(ocs.rx_mask), 32) >= 16) "Sliding Scale"	
;	else trim("") endif	
;	, if (mod(cnvtint(ocs.rx_mask), 64) >= 32 and cnvtint(ocs.rx_mask) >= 64) "Tapering Dose; "	
;	elseif (mod(cnvtint(ocs.rx_mask), 64) >= 32) "Tapering Dose"	
;	else trim("") endif	
;	, if (mod(cnvtint(ocs.rx_mask), 128) >= 64) "PCA Pump"	
;	else trim("") endif	
;	)	
;	, allow_as_intermittent = if (ocs.intermittent_ind = 1) "x"	
;	else ""	
;	endif	
;	, titrateable = if (ocs.ingredient_rate_conversion_ind = 1) "x"	
;	else ""	
;	endif	
;	, med_admin_witness = if (ocs.witness_flag = 1) "Required"	
;	else "Not Required"	
;	endif	
;	, high_alert_display_as_alert_order = if (ocs.high_alert_ind = 1) "x"	
;	else ""	
;	endif	
;	, high_alert_message_text = substring(1,500,l.long_text)	
;	, high_alert_auto_display_text = if (ocs.high_alert_required_ntfy_ind = 1) "x"	
;	else ""	
;	endif	
;	, display_additive_first = if (ocs.display_additives_first_ind = 1) "x"	
;	else ""	
;	endif	
;	, dose_calc_rounding_rules = uar_get_code_display(ocs.rounding_rule_cd)	
;	, dose_calc_lock_target_dose = if (ocs.lock_target_dose_ind = 1) "x"	
;	else ""	
;	endif	
;	, dose_calc_final_dose_cap = if (ocs.max_final_dose = 0) ""	
;	elseif (mod(ocs.max_final_dose*1000,1000) = 0) cnvtstring(ocs.max_final_dose,10,0)	; else if ocs.max_final_dose is a whole number, show no decimal places
;	elseif (mod(ocs.max_final_dose*1000,100) = 0) cnvtstring(ocs.max_final_dose,10,1)	; else if ocs.max_final_dose has one decimal place, show one decimal place
;	elseif (mod(ocs.max_final_dose*1000,10) = 0) cnvtstring(ocs.max_final_dose,10,2)	; else if ocs.max_final_dose has two decimal places, show two decimal places
;	else cnvtstring(ocs.max_final_dose,10,3)	; else show three decimal places.
;	endif	
;	, dose_calc_final_dose_cap_unit = uar_get_code_display(ocs.max_final_dose_unit_cd)	
;	, dose_calc_bsa_cap = if (ocs.max_dose_calc_bsa_value = 0) ""	
;	elseif (mod(ocs.max_dose_calc_bsa_value*1000,1000) = 0) cnvtstring(ocs.max_dose_calc_bsa_value,10,0)	; else if ocs.max_dose_calc_bsa_value is a whole number, show no decimal places
;	elseif (mod(ocs.max_dose_calc_bsa_value*1000,100) = 0) cnvtstring(ocs.max_dose_calc_bsa_value,10,1)	; else if ocs.max_dose_calc_bsa_value has one decimal place, show one decimal place
;	elseif (mod(ocs.max_dose_calc_bsa_value*1000,10) = 0) cnvtstring(ocs.max_dose_calc_bsa_value,10,2)	; else if ocs.max_dose_calc_bsa_value has two decimal places, show two decimal places
;	else cnvtstring(ocs.max_dose_calc_bsa_value,10,3)	; else show three decimal places.
;	endif	
;	, ignore_hide_on_autoconvert = if (ocs.ignore_hide_convert_ind = 1) "x"	
;	else ""	
;	endif	
;	, prefer_strength_dose = if (ocs.preferred_dose_flag = 1) "x"	
;	else ""	
;	endif
    , synonym_orders = "X"
; ORDERS
    /* 
    , synonym_orders = if(o_count.synonym_orders >"0") o_count.synonym_orders	
	else "0"	
	endif
    */	
	, synonym_last_update = format (ocs.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, synonym_last_updater = if(ocs.synonym_id > 0 and p_ocs.name_full_formatted = null) cnvtstring(ocs.updt_id)	
	else p_ocs.name_full_formatted	
	endif	
	, synonym_id = ocs.synonym_id 	
	, synonym_rank = dense_rank() over (partition by 0	
	order by 	
	cv_cat.display_key	
	, cv_act.display_key	
	, nullval(cv_sub_act.display_key, 0)	; 'nullval' used as dense_rank fails when cv_sub_act.display_key = null
	, cnvtupper(oc.primary_mnemonic)	
	, evaluate(ocs.mnemonic_type_cd	; synonym_type custom list with "Primary" first, as per DCP tools.
	, 2583, 01	; "Primary"
	, 2579, 02	; "Ancillary"
	, 2580, 03	; "Brand Name"
	, 614542, 04	; "C - Dispensable Drug Names"
	, 2581, 05	; "Direct Care Provider"
	, 614543, 06	; "E - IV Fluids and Nicknames"
	, 2582, 07	; "Generic Name"
	, 614544, 08	; "M - Generic Miscellaneous Products"
	, 614545, 09	; "N - Trade Miscellaneous Products"
	, 614546, 10	; "Outreach"
	, 614547, 11	; "PathLink"
	, 2584, 12	; "Rx Mnemonic"
	, 2585, 13	; "Surgery Med"
	, 614548, 14	; "Y - Generic Products"
	, 614549, 15	; "Z - Trade Products"
	)	
	, substring(1,40,ocs.mnemonic_key_cap)	
	)	
;	, synonym_virtual_views = count (distinct fac.facility_cd) over (partition by ocs.synonym_id)	
;	, synonym_virtual_view = if (fac.synonym_id = 0) "-no facilities-" 	
;	elseif (fac.synonym_id > 0 and fac.facility_cd = 0) "All Facilities"	
;	elseif (fac.synonym_id > 0 and fac.facility_cd > 0)  uar_get_code_display(fac.facility_cd)	
;	endif	
;	, vv_last_update = format (fac.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
;	, vv_last_updater = if(fac.synonym_id > 0 and fac.updt_id = 0) "0"	
;	else p_fac.name_full_formatted	
;	endif	
	, os_display_line = ocsr.order_sentence_disp_line	
	, os_sequence = if (ocsr.order_sentence_id > 0 and ocsr.display_seq = 0) "0"	
	elseif (ocsr.order_sentence_id > 0) cnvtstring(ocsr.display_seq)	
	else ""	
	endif	
	, sequence_last_update = format (ocsr.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, sequence_last_updater = if(ocsr.order_sentence_id > 0 and p_ocsr.name_full_formatted = null) cnvtstring(ocsr.updt_id)	
	else p_ocsr.name_full_formatted	
	endif	
	, os_comments = substring (1, 100, longt.long_text)	; only the first 100 charaters are shown to prevent the extract timing out
	, os_oef = oef_os.oe_format_name	
	, oef_match = if (os.order_sentence_id > 0 and oef_ocs.oe_format_name = oef_os.oe_format_name) "1"	; order sentence exists and oefs match
	elseif (os.order_sentence_id > 0) "0"	; order sentence exists but oefs don't match
	else ""	; order sentence doesn't exist
	endif	
	, os_last_update = format (os.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, os_last_updater = if(os.order_sentence_id > 0 and p_os.name_full_formatted = null) cnvtstring(os.updt_id)	
	else p_os.name_full_formatted	
	endif	
	, os_virtual_views = if(os.order_sentence_id > 0 and os_vv_count.virtual_views > "0") os_vv_count.virtual_views	
	elseif(os.order_sentence_id > 0) "0"	
	else ""	
	endif	
	, os_id = if (os.order_sentence_id > 0) cnvtstring(os.order_sentence_id)	
	else ""	
	endif	
	, os_virtual_view = if (fer.filter_entity_reltn_id > 0 and fer.filter_entity1_id = 0) "All Facilities"	; os exists on fer and filter_entity1_id = 0
	elseif (fer.filter_entity_reltn_id > 0) uar_get_code_display (fer.filter_entity1_id)	; os exists on fer and filter_entity1_id is not  0
	elseif (os.order_sentence_id > 0) "No Facilities"	; os exists on os, but not on fer
	else ""	; os does not exist
	endif	
	, facility_cd = if (fer.filter_entity_reltn_id > 0 and fer.filter_entity1_id = 0) "0"	
	elseif (fer.filter_entity_reltn_id > 0) cnvtstring(fer.filter_entity1_id)	
	else ""	
	endif	
	, vv_last_update = format (fer.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, vv_last_updater = if(fer.parent_entity_id > 0 and p_fer.name_full_formatted = null) cnvtstring(fer.updt_id)	
	else p_fer.name_full_formatted	
	endif	
	, encounter_group = if(os.order_sentence_id >0 and os.order_encntr_group_cd = 0) "All"	
	else uar_get_code_display (os.order_encntr_group_cd)	
	endif	
	, os_age_restrictions = if(osf.age_min_value = 0 and osf.age_max_value = 0) ""	
	elseif(osf.age_min_value = 0 and osf.age_max_value > 0) concat("Less Than ", trim(cnvtstring(osf.age_max_value)), " ", uar_get_code_display(osf.age_unit_cd)) 	
	elseif(osf.age_min_value > 0 and osf.age_max_value = 0) concat("Greater Than or Equal to ", trim(cnvtstring(osf.age_min_value)), " ", uar_get_code_display(osf.age_unit_cd)) 	
	elseif(osf.age_min_value > 0 and osf.age_max_value > 0) concat(trim(cnvtstring(osf.age_min_value)), " -  ", trim(cnvtstring(osf.age_max_value)), " ", uar_get_code_display(osf.age_unit_cd))	
	endif	
	, os_pma_restrictions = if(osf.pma_min_value = 0 and osf.pma_max_value = 0) ""	
	elseif(osf.pma_min_value = 0 and osf.pma_max_value > 0) concat("Less Than ", trim(cnvtstring(osf.pma_max_value)), " ", uar_get_code_display(osf.pma_unit_cd)) 	
	elseif(osf.pma_min_value > 0 and osf.pma_max_value = 0) concat("Greater Than or Equal to ", trim(cnvtstring(osf.pma_min_value)), " ", uar_get_code_display(osf.pma_unit_cd)) 	
	elseif(osf.pma_min_value > 0 and osf.pma_max_value > 0) concat(trim(cnvtstring(osf.pma_min_value)), " -  ", trim(cnvtstring(osf.pma_max_value)), " ", uar_get_code_display(osf.pma_unit_cd))	
	endif	
	, os_weight_restrictions = if(osf.weight_min_value = 0 and osf.weight_max_value = 0) ""	
	elseif(osf.weight_min_value = 0 and osf.weight_max_value > 0) concat("Less Than ", trim(cnvtstring(osf.weight_max_value)), " ", uar_get_code_display(osf.weight_unit_cd)) 	
	elseif(osf.weight_min_value > 0 and osf.weight_max_value = 0) concat("Greater Than or Equal to ", trim(cnvtstring(osf.weight_min_value)), " ", uar_get_code_display(osf.weight_unit_cd)) 	
	elseif(osf.weight_min_value > 0 and osf.weight_max_value > 0) concat(trim(cnvtstring(osf.weight_min_value)), " -  ", trim(cnvtstring(osf.weight_max_value)), " ", uar_get_code_display(osf.weight_unit_cd))	
	endif	
	, restrictions_last_update = format(osf.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, restrictions_last_updater  = if(osf.order_sentence_id > 0 and p_osf.name_full_formatted = null) cnvtstring(osf.updt_id)	
	else p_osf.name_full_formatted	
	endif	
	, domain_alignment_comparison_text =if (ocs.active_ind = 1 and os.order_sentence_id > 0)	
	build(oc.primary_mnemonic	
	, "|", uar_get_code_display(ocs.mnemonic_type_cd )	
	, "|", ocs.mnemonic	
	, "|", oef_ocs.oe_format_name	
	, "|", ocs.hide_flag	
;	, "|", if (fac.synonym_id = 0) ""	
;	else cnvtstring(fac.facility_cd)	
;	endif	
	, "|", ocsr.order_sentence_disp_line	
	, "|", ocsr.display_seq	
	, "|", substring (1, 500, longt.long_text)	
	, "|", if (fer.filter_entity_reltn_id > 0 and fer.filter_entity1_id = 0) "All Facilities"	; os exists on fer and filter_entity1_id = 0
	elseif (fer.filter_entity_reltn_id > 0) uar_get_code_display (fer.filter_entity1_id)	; os exists on fer and filter_entity1_id is not  0
	elseif (os.order_sentence_id > 0) "No Facilities"	; os exists on os, but not on fer
	else ""	; os does not exist
	endif	
	, "|", trim(cnvtstring(os.order_encntr_group_cd))	
	, "|", trim(cnvtstring(osf.age_min_value))	
	, "|", trim(cnvtstring(osf.age_max_value))	
	, "|", uar_get_code_display(osf.age_unit_cd)	
	, "|", trim(cnvtstring(osf.pma_min_value))	
	, "|", trim(cnvtstring(osf.pma_max_value))	
	, "|", uar_get_code_display(osf.pma_unit_cd)	
	, "|", trim(cnvtstring(osf.weight_min_value))	
	, "|", trim(cnvtstring(osf.weight_max_value))	
	, "|", uar_get_code_display(osf.weight_unit_cd)	
	)	
	else ""	
	endif	
;	, facility_cd = if (fac.synonym_id = 0) ""	
;	else cnvtstring(fac.facility_cd)	
;	endif	
	, order_sentence_rank = dense_rank() over (partition by 0	
	order by 	
;	cv_cat.display_key	
	cv_act.display_key	
	, nullval(cv_sub_act.display_key, 0)	; 'nullval' used as dense_rank fails when cv_sub_act.display_key = null
	, cnvtupper(oc.primary_mnemonic)	
	, evaluate(ocs.mnemonic_type_cd	; synonym_type custom list with "Primary" first, as per DCP tools.
	, 2583, 01	; "Primary"
	, 2579, 02	; "Ancillary"
	, 2580, 03	; "Brand Name"
	, 614542, 04	; "C - Dispensable Drug Names"
	, 2581, 05	; "Direct Care Provider"
	, 614543, 06	; "E - IV Fluids and Nicknames"
	, 2582, 07	; "Generic Name"
	, 614544, 08	; "M - Generic Miscellaneous Products"
	, 614545, 09	; "N - Trade Miscellaneous Products"
	, 614546, 10	; "Outreach"
	, 614547, 11	; "PathLink"
	, 2584, 12	; "Rx Mnemonic"
	, 2585, 13	; "Surgery Med"
	, 614548, 14	; "Y - Generic Products"
	, 614549, 15	; "Z - Trade Products"
	)	
	, substring(1,40,ocs.mnemonic_key_cap)	
	, nullval(ocsr.display_seq, 0)	; 'nullval' used as dense_rank fails when ocsr.display_seq = 0
	, nullval(os.order_sentence_id, 0)	; 'nullval' used as dense_rank fails when os.order_sentence_id = 0
	)	
		
from		
	order_catalog  oc	
	, (left join code_value cv_cat on cv_cat.code_value = oc.catalog_type_cd)	
	, (left join code_value cv_act on cv_act.code_value = oc.activity_type_cd)	
	, (left join code_value cv_sub_act on cv_sub_act.code_value = oc.activity_subtype_cd)	
 	, (left join order_catalog_synonym  ocs on ocs.catalog_cd = oc.catalog_cd)	
	, (left join prsnl p_ocs on p_ocs.person_id = ocs.updt_id)	
	, (left join order_entry_format oef_ocs on oef_ocs.oe_format_id = ocs.oe_format_id	
	and oef_ocs.action_type_cd = 2534	; code value for 'Order' from code set 6003
	)	
;ORDERS JOIN	, (left join (select o.synonym_id, synonym_orders = count(*) from orders o group by o.synonym_id) o_count on o_count.synonym_id = ocs.synonym_id)	
 ;	, (left join ocs_facility_r fac on fac.synonym_id = ocs.synonym_id	
 ;	 and fac.facility_cd != 11111111	; This is a dummy facility code used to save such rows for future use
 ;	)	
 ;	, (left join code_value cv_fac on cv_fac.code_value = fac.facility_cd)	
 ;	, (left join prsnl p_fac on p_fac.person_id = fac.updt_id)	
	, (left join order_sentence os on os.parent_entity_id = ocs.synonym_id	
	and os.parent_entity_name = "ORDER_CATALOG_SYNONYM"	; exclude powerplan comp and powerplan rule order sentences
	and os.parent_entity2_id = 0	; exclude folder and careset order sentences
	)	
	, (left join prsnl p_os on p_os.person_id = os.updt_id)	
	, (left join order_entry_format oef_os on oef_os.oe_format_id = os.oe_format_id	
	and oef_os.action_type_cd = 2534	; oef for 'Order' action to prevent duplicate rows created by the other actions
	)	
	, (left join long_text longt on longt.parent_entity_id = os.order_sentence_id	
	and longt.parent_entity_name = "ORDER_SENTENCE"	
	)	
	, (left join ord_cat_sent_r ocsr on ocsr.order_sentence_id = os.order_sentence_id)	
	, (left join prsnl p_ocsr on p_ocsr.person_id = ocsr.updt_id)	
	, (left join (select fer.parent_entity_id, virtual_views = count(*) from filter_entity_reltn fer group by fer.parent_entity_id) os_vv_count on os_vv_count.parent_entity_id = os.order_sentence_id)	
	, (left join filter_entity_reltn fer on fer.parent_entity_id = os.order_sentence_id	
	and fer.filter_type_cd = 4006099	; code value for 'order sentence' from code set 30620
	)	
	, (left join prsnl p_fer on p_fer.person_id = fer.updt_id)	
	, (left join order_sentence_filter osf on osf.order_sentence_id = os.order_sentence_id)	
	, (left join prsnl p_osf on p_osf.person_id = osf.updt_id)	
 		
plan 	oc 	
;where	oc.catalog_type_cd not in (2513, 2516, 2517, 0)	; code values for 'Laboratory', 'Pharmacy' and 'Radiology' from code set 6000. '0' prevents '0 row' on oc table from returning.
;where	oc.catalog_type_cd = 2513 	; code value for 'Laboratory' from code set 6000
;where	oc.catalog_type_cd = 2515	; code value for 'Patient Care' from code set 6000
where	oc.catalog_type_cd = 2516	; code value for 'Pharmacy' from code set 6000
;where	oc.catalog_type_cd = 2517 	; code value for 'Radiology' from code set 6000
;where	oc.catalog_type_cd in (2519, 50010734, 84670240, 84695079 , 84871493)	; code values for 'Surgery' and 'CMBS Code - SN' from code set 6000 for G1, G2, G3 and G4
and	oc.orderable_type_flag not in (2,3,6,8)	; exclude 'Supergroup','CarePlan', 'Order Set', and 'Multi-ingredient' (IV Set) orderables
;and	cnvtupper (oc.primary_mnemonic) = "Aspirin*"	
and	cnvtupper (oc.primary_mnemonic) < "F*"	; use these if the audit fails in any domain
;and	cnvtupper (oc.primary_mnemonic) between "F*" and "O*"	; (synonym_rank may be corrupted between the audit divisions)
;and	cnvtupper (oc.primary_mnemonic) >= "O*"	
;and	oc.catalog_cd = 1234567	
join	cv_cat	
join	cv_act	
join	cv_sub_act	
join	ocs 	
join	p_ocs	
join	oef_ocs	
;ORDERS             join	o_count	
;join 	fac 	
;join 	cv_fac	
;join 	p_fac	
join	os	
join	p_os	
join	oef_os	
join	longt	
join 	ocsr 	
join	p_ocsr	
join	os_vv_count	
join	fer	
join	p_fer	
join	osf	
join	p_osf	
		
order by		
	catalog_rank	
	, activity_rank	
	,sub_act_rank	
	, primary_rank	
	, synonym_rank	
;	, fac.facility_cd	
	, ocsr.display_seq	
	, os.order_sentence_id	
	, uar_get_code_display (fer.filter_entity1_id)	
	, 0	; in case 'select distinct' is used
		
with	time = 60	
