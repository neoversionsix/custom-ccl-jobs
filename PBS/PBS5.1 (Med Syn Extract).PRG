select	; Medication synonyms (PBS MOD. Only needs to be run in C2031)	
	extract_meta = concat( trim(curdomain) ,' (', format(sysdate,"yyyymmdd hhmm;3;q"), ")" )	
	, primary_cki = oc.cki	
	, primary_mnemonic = oc.primary_mnemonic	
	, primary_rank = dense_rank() over (partition by 0	
	order by 	
	cv_cat.display_key	
	, cv_act.display_key	
	, nullval(cv_sub_act.display_key, 0)	; 'nullval' used as dense_rank fails when cv_sub_act.display_key = null
	, cnvtupper(oc.primary_mnemonic)	
	)	
	, synonym_cki = ocs.cki	
	, synonym_type_meaning = uar_get_code_meaning (ocs.mnemonic_type_cd )	
	, synonym_mnemonic = ocs.mnemonic	
	, synonym_active = ocs.active_ind	
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
		
		
from		
	order_catalog  oc	
	, (left join code_value cv_cat on cv_cat.code_value = oc.catalog_type_cd)	
	, (left join code_value cv_act on cv_act.code_value = oc.activity_type_cd)	
	, (left join code_value cv_sub_act on cv_sub_act.code_value = oc.activity_subtype_cd)	
 	, (left join order_catalog_synonym  ocs on ocs.catalog_cd = oc.catalog_cd)	
 		
plan 	oc 	
where	oc.catalog_type_cd = 2516	; code value for 'Pharmacy' from code set 6000
and	oc.orderable_type_flag not in (2,3,6,8)	; exclude 'Supergroup','CarePlan', 'Order Set', and 'Multi-ingredient' (IV Set) orderables
join	cv_cat	
join	cv_act	
join	cv_sub_act	
join	ocs 	
where	ocs.mnemonic_type_cd not in (614542, 2584)	; exclude 'C-Dispensables' & 'RxMnemonics' as these are not PBS mapped.
		
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
	, 0	; in case 'select distinct' is used
		
with	time = 60	
