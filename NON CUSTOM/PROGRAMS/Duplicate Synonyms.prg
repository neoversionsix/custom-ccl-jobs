/*
Programmer: Jason Whittle
*/

drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Primary Name?" = ""

with OUTDEV, PRIMARY_NAME

select into $OUTDEV 	; duplicate synonym mnemonic audit	; 'distinct' used for multiple virtual view joins on ocs_facility_r table and multiple orders on the orders table.
	domain = curdomain
	, catalog_type = cv_cat.display
	, activity_type = cv_act.display
	, activity_subtype = cv_sub.display
	, primary_cki = oc.cki
	, orderable_type = evaluate (oc.orderable_type_flag
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
	, primary_mnemonic = oc.primary_mnemonic
	, synonym_cki = ocs.cki
 	, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd )
 	, synonym_mnemonic = ocs.mnemonic
	, synonym_active = ocs.active_ind
	, synonym_oef = oef.oe_format_name
	, synonym_hide = ocs.hide_flag
	, synonym_last_update = format(ocs.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")
	, synonym_last_updater = if(ocs.synonym_id > 0 and ocs.updt_id = 0) "0"
	else p_ocs.name_full_formatted
	endif
	, synonym_id = ocs.synonym_id

 	, times_ordered = nullval(o.o_ttl,"0") ; "excluded from audit due to time-out"	; orders may need to excluded from PRDD2
	, fac.vv_facility


from
	order_catalog_synonym ocs
	, (left join prsnl p_ocs on p_ocs.person_id = ocs.updt_id)	; synonym last updater
	, (left join order_catalog oc on oc.catalog_cd = ocs.catalog_cd
	and oc.orderable_type_flag not in (6,8)
	)
	, (left join order_entry_format oef on oef.oe_format_id = ocs.oe_format_id
	and oef.action_type_cd = 2534
	)
	, (left join long_text l on l.long_text_id = ocs.high_alert_long_text_id)	; alert text
	, (left join code_value cv_cat on cv_cat.code_value = oc.catalog_type_cd)
	, (left join code_value cv_act on cv_act.code_value = oc.activity_type_cd)
	, (left join code_value cv_sub on cv_sub.code_value = oc.activity_subtype_cd)


	, (left join

	(select fac.synonym_id,
	vv_facility = listagg(fac_cv.display,", ") over (order by fac_cv.display)
	from ocs_facility_r fac
	, (left join code_value fac_cv on fac_cv.code_value = fac.facility_cd)
	group by fac.synonym_id)
	fac on fac.synonym_id = ocs.synonym_id 	; synonym virtual view table
;	and fac.facility_cd = 0	; only return 'All Facilities' joins
	)


	, (inner join order_catalog_synonym ocs_dup on ocs_dup.mnemonic_key_cap = ocs.mnemonic_key_cap
	and ocs_dup.synonym_id != ocs.synonym_id
	and (ocs_dup.cki = null or ocs.cki = null)	; ignore if duplicates are both Multum synonyms.
	and (ocs_dup.catalog_type_cd != 2519 or ocs.catalog_type_cd != 2519)	; ignore if duplicates are both surgery synonyms
	)
	, (left join (select o_cnt.synonym_id, O_ttl = count(*) from orders o_cnt
	group by o_cnt.synonym_id) o on o.synonym_id = ocs.synonym_id)

plan	ocs

;where 	ocs.catalog_type_cd not in (2513,2515,2516,2517)	; code values for 'Laborotory', 'Patient Care', 'Pharmacy' and 'Radiology' from code set 6000
;where 	ocs.catalog_type_cd = 2513 	; code value for 'Laboratory' from code set 6000
;where 	ocs.catalog_type_cd = 2515	; code value for 'Patient Care' from code set 6000
;where 	ocs.catalog_type_cd = 2516	; code value for 'Pharmacy' from code set 6000
;where 	ocs.catalog_type_cd = 2517 	; code value for 'Radiology' from code set 6000

join	p_ocs
join	oc
join 	oef
join	l
join	cv_cat
join	cv_act
join	cv_sub
join	fac
join	ocs_dup
join	o

order by
	ocs.mnemonic_key_cap
	, ocs.active_ind desc	; show active synonyms on top
;	, cv_cat.display_key	; corrupts the 'select distinct' if included where only one instance of some duplicate synonyms are displayed.
;	, cv_act.display_key	; corrupts the 'select distinct' if included where only one instance of some duplicate synonyms are displayed.
;	, cv_sub.display_key	; for some reason, corrupts the 'select distinct' if included.
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
	, ocs.synonym_id
	, 0	; in case 'select distinct' is used

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 200


end
go