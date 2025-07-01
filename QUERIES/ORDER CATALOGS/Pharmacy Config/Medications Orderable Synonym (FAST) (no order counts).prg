select	; Medication synonyms	
	catalog_type = cv_cat.display	
;	, activity_type = cv_act.display	
;	, sub_activity_type = cv_sub_act.display	
	, primary_cki = oc.cki	
	, primary_mnemonic = oc.primary_mnemonic	
	, primary_orderable_type = evaluate (oc.orderable_type_flag	
	, 0, "Standard"	
	, 1, "Standard"	
	, 2, "Supergroup"	
	, 3, "CarePlan"	
	, 4, "AP Special"	
	, 5, "Department Only"	
	, 6, "Order Set"	
	, 7, "Home Health Problem"	
	, 8, "Multi-ingredient"	
	, 9, "Interval Test"	
	, 10, "Freetext"	
	)	
	, synonyms_under_primary = count (distinct ocs.synonym_id) over (partition by oc.catalog_cd)	
	, catalog_cd = oc.catalog_cd	
	, primary_rank = dense_rank() over (partition by 0	
	order by 	
	cv_cat.display_key	
	, cv_act.display_key	
	, nullval(cv_sub_act.display_key, 0)	; 'nullval' used as dense_rank fails when cv_sub_act.display_key = null
	, cnvtupper(oc.primary_mnemonic)	
	)	
	, synonym_cki = ocs.cki	
;	, synonym_cki_count = count(distinct ocs.synonym_id) over (partition by ocs.cki)	
	, synonym_type = uar_get_code_display (ocs.mnemonic_type_cd )	
	, synonym_mnemonic = ocs.mnemonic	
	, synonym_oef = oef.oe_format_name	
	, synonym_active = ocs.active_ind	
 	, synonym_hide = ocs.hide_flag	
	, synonym_rxmask = concat (	
	if (mod(cnvtint(ocs.rx_mask), 2) = 1 and cnvtint(ocs.rx_mask) >= 2) "Diluent; "	
	elseif (mod(cnvtint(ocs.rx_mask), 2) = 1) "Diluent"	
	else trim("") endif	
	, if (mod(cnvtint(ocs.rx_mask), 4) >= 2 and cnvtint(ocs.rx_mask) >= 4) "Additive; "	
	elseif (mod(cnvtint(ocs.rx_mask), 4) >= 2) "Additive"	
	else trim("") endif	
	, if (mod(cnvtint(ocs.rx_mask), 8) >= 4 and cnvtint(ocs.rx_mask) >= 8) "Med; "	
	elseif (mod(cnvtint(ocs.rx_mask), 8) >= 4) "Med"	
	else trim("") endif	
	, if (mod(cnvtint(ocs.rx_mask), 16) >= 8 and cnvtint(ocs.rx_mask) >= 16) "TPN; "	
	elseif (mod(cnvtint(ocs.rx_mask), 16) >= 8) "TPN"	
	else trim("") endif	
	, if (mod(cnvtint(ocs.rx_mask), 32) >= 16 and cnvtint(ocs.rx_mask) >= 32) "Sliding Scale; "	
	elseif (mod(cnvtint(ocs.rx_mask), 32) >= 16) "Sliding Scale"	
	else trim("") endif	
	, if (mod(cnvtint(ocs.rx_mask), 64) >= 32 and cnvtint(ocs.rx_mask) >= 64) "Tapering Dose; "	
	elseif (mod(cnvtint(ocs.rx_mask), 64) >= 32) "Tapering Dose"	
	else trim("") endif	
	, if (mod(cnvtint(ocs.rx_mask), 128) >= 64) "PCA Pump"	
	else trim("") endif	
	)	
	, allow_as_intermittent = if (ocs.intermittent_ind = 1) "x"	
	else ""	
	endif	
	, titrateable = if (ocs.ingredient_rate_conversion_ind = 1) "x"	
	else ""	
	endif	
	, med_admin_witness = if (ocs.witness_flag = 1) "Required"	
	else "Not Required"	
	endif	
	, high_alert_display_as_alert_order = if (ocs.high_alert_ind = 1) "x"	
	else ""	
	endif	
	, high_alert_message_text = substring(1,500,l_ha.long_text)	
	, high_alert_auto_display_text = if (ocs.high_alert_required_ntfy_ind = 1) "x"	
	else ""	
	endif	
	, display_additive_first = if (ocs.display_additives_first_ind = 1) "x"	
	else ""	
	endif	
	, dose_calc_rounding_rules = uar_get_code_display(ocs.rounding_rule_cd)	
	, dose_calc_lock_target_dose = if (ocs.lock_target_dose_ind = 1) "x"	
	else ""	
	endif	
	, dose_calc_final_dose_cap = if (ocs.max_final_dose = 0) ""	
	elseif (mod(ocs.max_final_dose*1000,1000) = 0) cnvtstring(ocs.max_final_dose,10,0)	; else if ocs.max_final_dose is a whole number, show no decimal places
	elseif (mod(ocs.max_final_dose*1000,100) = 0) cnvtstring(ocs.max_final_dose,10,1)	; else if ocs.max_final_dose has one decimal place, show one decimal place
	elseif (mod(ocs.max_final_dose*1000,10) = 0) cnvtstring(ocs.max_final_dose,10,2)	; else if ocs.max_final_dose has two decimal places, show two decimal places
	else cnvtstring(ocs.max_final_dose,10,3)	; else show three decimal places.
	endif	
	, dose_calc_final_dose_cap_unit = uar_get_code_display(ocs.max_final_dose_unit_cd)	
	, dose_calc_bsa_cap = if (ocs.max_dose_calc_bsa_value = 0) ""	
	elseif (mod(ocs.max_dose_calc_bsa_value*1000,1000) = 0) cnvtstring(ocs.max_dose_calc_bsa_value,10,0)	; else if ocs.max_dose_calc_bsa_value is a whole number, show no decimal places
	elseif (mod(ocs.max_dose_calc_bsa_value*1000,100) = 0) cnvtstring(ocs.max_dose_calc_bsa_value,10,1)	; else if ocs.max_dose_calc_bsa_value has one decimal place, show one decimal place
	elseif (mod(ocs.max_dose_calc_bsa_value*1000,10) = 0) cnvtstring(ocs.max_dose_calc_bsa_value,10,2)	; else if ocs.max_dose_calc_bsa_value has two decimal places, show two decimal places
	else cnvtstring(ocs.max_dose_calc_bsa_value,10,3)	; else show three decimal places.
	endif	
	, ignore_hide_on_autoconvert = if (ocs.ignore_hide_convert_ind = 1) "x"	
	else ""	
	endif	
	, prefer_strength_dose = if (ocs.preferred_dose_flag = 1) "x"	
	else ""	
	endif	
	, synonym_last_update = format (ocs.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, synonym_last_updater = if(ocs.synonym_id > 0 and p_ocs.name_full_formatted = null) cnvtstring(ocs.updt_id)	
	else p_ocs.name_full_formatted	
	endif	
	, synonym_orders = "OMITTED"
    /* 
    if(o_count.count >"0") o_count.count	
	else "0"	
	endif
    */	
	, powerplan_usage = if(pp_count.count >"0") pp_count.count	
	else "0"	
	endif	
	, careset_and_IV_usage = if(cs_count.count >"0") cs_count.count	
	else "0"	
	endif	
	, synonym_virtual_views = ;count (distinct fac.facility_cd) over (partition by ocs.synonym_id)	; used when each virtual view appears in its own row, with multiple rows per synonym
	( if(fac_All.synonym_id > 0) 1 else 0 endif	; used when each virtual view appears in its own column, and only one row per synonym
	+ if(fac_Demo1.synonym_id > 0) 1 else 0 endif	
	+ if(fac_Foots.synonym_id > 0) 1 else 0 endif	
	+ if(fac_Sunb.synonym_id > 0) 1 else 0 endif	
	+ if(fac_Suns.synonym_id > 0) 1 else 0 endif	
	+ if(fac_Will.synonym_id > 0) 1 else 0 endif	
	)	
	, synonym_id = ocs.synonym_id 	
	, synonym_virtual_view = "<not included in extract>" ;if (fac.synonym_id = 0) "-no facilities-" 	
;	elseif (fac.synonym_id > 0 and fac.facility_cd = 0) "All Facilities"	
;	elseif (fac.synonym_id > 0 and fac.facility_cd > 0)  uar_get_code_display(fac.facility_cd)	
;	endif	
	, facility_cd = "<not included in extract>" ;if (fac.synonym_id = 0) ""	
;	else cnvtstring(fac.facility_cd)	
;	endif	
	, vv_last_update = "<not included in extract>" ;format (fac.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, vv_last_updater = "<not included in extract>" ;if(fac.synonym_id > 0 and p_fac.name_full_formatted = null) cnvtstring(fac.updt_id)	
;	else p_fac.name_full_formatted	
;	endif	
	, All_fac_vv = if(fac_All.synonym_id > 0) "x"	
	else ""	
	endif	
	, Demo1_vv = if(fac_Demo1.synonym_id > 0) "x"	
	else ""	
	endif	
	, Foots_vv = if(fac_Foots.synonym_id > 0) "x"	
	else ""	
	endif	
	, Sunb_vv = if(fac_Sunb.synonym_id > 0) "x"	
	else ""	
	endif	
	, Suns_vv = if(fac_Suns.synonym_id > 0) "x"	
	else ""	
	endif	
	, Will_vv = if(fac_Will.synonym_id > 0) "x"	
	else ""	
	endif	
		
	, domain_alignment_comparison_text =if (ocs.active_ind = 1)	
	build(	
	oc.primary_mnemonic	
	, "|", uar_get_code_display(ocs.mnemonic_type_cd )	
	, "|", ocs.cki	
	, "|", ocs.mnemonic	
	, "|", oef.oe_format_name	
	, "|", ocs.hide_flag	
	, "|", ocs.rx_mask	
	, "|", ocs.intermittent_ind	
;	, "|", if (fac.synonym_id = 0) ""	; used when each virtual view appears in its own row, with multiple rows per synonym
;	else cnvtstring(fac.facility_cd)	
;	endif	
	, "|", if( fac_All.synonym_id > 0) "All Facilities"	; used when each virtual view appears in its own column, and only one row per synonym
	else build ("|", uar_get_code_display(fac_Demo1.facility_cd )	
	, "|", uar_get_code_display(fac_Foots.facility_cd )	
	, "|", uar_get_code_display(fac_Sunb.facility_cd )	
	, "|", uar_get_code_display(fac_Suns.facility_cd )	
	, "|", uar_get_code_display(fac_Will.facility_cd )	
	)	
	endif	
	)	
	else ""	
	endif	
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
		
from		
	order_catalog  oc	
	, (left join code_value cv_cat on cv_cat.code_value = oc.catalog_type_cd)	
	, (left join code_value cv_act on cv_act.code_value = oc.activity_type_cd)	
	, (left join code_value cv_sub_act on cv_sub_act.code_value = oc.activity_subtype_cd)	
 	, (left join order_catalog_synonym  ocs on ocs.catalog_cd = oc.catalog_cd)	
	, (left join prsnl p_ocs on p_ocs.person_id = ocs.updt_id)	
	, (left join order_entry_format oef on oef.oe_format_id = ocs.oe_format_id	
	and oef.action_type_cd = 2534	; code value for 'Order' from code set 6003
	)	
	, (left join long_text l_ha on l_ha.long_text_id = ocs.high_alert_long_text_id)	; alert text
; ORDERS TABLE JOIN	, (left join (select o.synonym_id, count = count(*) from orders o group by o.synonym_id) o_count on o_count.synonym_id = ocs.synonym_id)	
	, (left join (select p_comp.parent_entity_id, count = count(*) from pathway_comp p_comp group by  p_comp.parent_entity_id) pp_count on pp_count.parent_entity_id = ocs.synonym_id)	
	, (left join (select cs_comp.comp_id, count = count(*) from cs_component cs_comp group by  cs_comp.comp_id) cs_count on cs_count.comp_id = ocs.synonym_id)	
;	, (left join ocs_facility_r fac on fac.synonym_id = ocs.synonym_id	; used when each virtual view appears in its own row, with multiple rows per synonym
;	 and fac.facility_cd != 11111111	; This is a dummy facility code used to save such rows for future use
;	)	
;	, (left join code_value cv_fac on cv_fac.code_value = fac.facility_cd)	; used when each virtual view appears in its own row, with multiple rows per synonym
;	, (left join prsnl p_fac on p_fac.person_id = fac.updt_id)	; used when each virtual view appears in its own row, with multiple rows per synonym
	, (left join ocs_facility_r fac_All on fac_All.synonym_id = ocs.synonym_id	; used when each virtual view appears in its own column, and only one row per synonym
	 and fac_All.facility_cd = 0	; 'All Facilities'
	)	
	, (left join ocs_facility_r fac_Demo1 on fac_Demo1.synonym_id = ocs.synonym_id	; used when each virtual view appears in its own column, and only one row per synonym
	 and fac_Demo1.facility_cd = 4038465	; 'DEMO 1 HOSPITAL' facility from code set 220
	)	
	, (left join ocs_facility_r fac_Foots on fac_Foots.synonym_id = ocs.synonym_id	; used when each virtual view appears in its own column, and only one row per synonym
	 and fac_Foots.facility_cd = 85758822	; 'Footscray' facility from code set 220
	)	
	, (left join ocs_facility_r fac_Sunb on fac_Sunb.synonym_id = ocs.synonym_id	; used when each virtual view appears in its own column, and only one row per synonym
	 and fac_Sunb.facility_cd = 86163538	; 'Sunbury Day' facility from code set 220
	)	
	, (left join ocs_facility_r fac_Suns on fac_Suns.synonym_id = ocs.synonym_id	; used when each virtual view appears in its own column, and only one row per synonym
	 and fac_Suns.facility_cd = 86163400	; 'Sunshine' facility from code set 220
	)	
	, (left join ocs_facility_r fac_Will on fac_Will.synonym_id = ocs.synonym_id	; used when each virtual view appears in its own column, and only one row per synonym
	 and fac_Will.facility_cd = 86163477	; 'Williamstown' facility from code set 220
	)	
 		
plan 	oc 	
;where	oc.catalog_type_cd not in (2513, 2516, 2517, 0)	; code values for 'Laboratory', 'Pharmacy' and 'Radiology' from code set 6000. '0' prevents '0 row' on oc table from returning.
;where	oc.catalog_type_cd = 2513 	; code value for 'Laboratory' from code set 6000
;where	oc.catalog_type_cd = 2515	; code value for 'Patient Care' from code set 6000
where	oc.catalog_type_cd = 2516	; code value for 'Pharmacy' from code set 6000
;where	oc.catalog_type_cd = 2517 	; code value for 'Radiology' from code set 6000
;where	oc.catalog_type_cd in (2519, 50010734, 84670240, 84695079 , 84871493)	; code values for 'Surgery' and 'CMBS Code - SN' from code set 6000 for G1, G2, G3 and G4
and	oc.orderable_type_flag not in (2,3,6,8)	; exclude 'Supergroup','CarePlan', 'Order Set', and 'Multi-ingredient' (IV Set) orderables
;and	cnvtupper (oc.primary_mnemonic) = "Aspirin*"
;and	cnvtupper (oc.primary_mnemonic) < "N*"	; use these if the audit fails in any domain
and	cnvtupper (oc.primary_mnemonic) >= "N*"	; use these if the audit fails in any domain
;and	cnvtupper (oc.primary_mnemonic) between "E*" and "N*"	; (synonym_rank may be corrupted between the audit divisions)
;and	cnvtupper (oc.primary_mnemonic) >= "N*"	; (synonym_rank may be corrupted between the audit divisions)
;and	oc.catalog_cd = 1234567	
join	cv_cat	
join	cv_act	
join	cv_sub_act	
join	ocs 	
join	p_ocs	
join	oef	
join	l_ha	
; ORDERS    join	o_count	
join	pp_count	
join	cs_count	
;join 	fac 	; used when each virtual view appears in its own row, with multiple rows per synonym
;join	cv_fac	; used when each virtual view appears in its own row, with multiple rows per synonym
;join	p_fac	; used when each virtual view appears in its own row, with multiple rows per synonym
join	fac_All	; used when each virtual view appears in its own column, and only one row per synonym
join	fac_Demo1	; used when each virtual view appears in its own column, and only one row per synonym
join	fac_Foots	; used when each virtual view appears in its own column, and only one row per synonym
join	fac_Sunb	; used when each virtual view appears in its own column, and only one row per synonym
join	fac_Suns	; used when each virtual view appears in its own column, and only one row per synonym
join	fac_Will	; used when each virtual view appears in its own column, and only one row per synonym
		
order by		
;	cv_cat.display_key	
;	, cv_act.display_key	
;	, cv_sub_act.display_key	
	cnvtupper (oc.primary_mnemonic)	
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
	, ocs.synonym_id	; in case 'select distinct' is used
;	, uar_get_code_display(fac.facility_cd)	
	, 0	; in case 'select distinct' is used
		
with	time = 10	
