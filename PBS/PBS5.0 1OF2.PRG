select	; pbs mapping extract PART 1 OF 2 (ROW 79/80 SWITCH)	
	extract_meta = concat( trim(curdomain) ,' (', format(sysdate,"yyyymmdd hhmm;3;q"), ")" )	
	, pbs_code = list.pbs_item_code	
	, item_beg_date = format(item.beg_effective_dt_tm, "dd/MMM/yyyy")	
	, item_end_date = format(item.end_effective_dt_tm, "dd/MMM/yyyy") 	
	, schedule = list.drug_type_mean	
	, item_drug_name = item.drug_name	
	, form_strength = drug.form_strength	
	, product_brand_name = drug.brand_name	
	, product_manufacturer_code = manf.manufacturer_code	
	, product_package_size = drug.pack_size	
	, product_beg_date = format(drug.beg_effective_dt_tm, "dd/MMM/yyyy")	
	, product_end_date = format(drug.end_effective_dt_tm, "dd/MMM/yyyy")	
	, product_brand_indent = drug.brand_ident	
	, product_drug_id = drug.pbs_drug_id	
	, mapped_synonym_mnemonic = ocs.mnemonic	
	, mapped_synonym_cki = ocs.cki	
	, mapped_synonym_mnemonic_type_mean = uar_get_code_meaning(ocs.mnemonic_type_cd)	
	, mapped_synonym_active_ind = if (ocsm.pbs_ocs_mapping_id > 0) cnvtstring(ocs.active_ind)	
	else ""	
	endif	
	, synonym_id = if (ocsm.pbs_ocs_mapping_id > 0) cnvtstring(ocs.synonym_id)	
	else ""	
	endif	
	, mapping_last_update = format(ocsm.updt_dt_tm, "dd/mm/yy hh:mm:ss")	
	, mapping_last_updater = pocsm.name_full_formatted	
	, mapped_synonyms_to_product = count(ocsm.pbs_drug_id) over (partition by drug.pbs_drug_id)	
;	, duplicate_mappings = count(ocsm.synonym_id) over (partition by ocsm.pbs_drug_id	
;	, ocsm.synonym_id	
;	)	
	, form_strength_count = count(distinct drug.form_strength) over (partition by item.pbs_item_id	
	, drug.brand_ident	
	)	
	, pbs_drug_row_identification_text =  build(list.pbs_item_code	
	, "|", drug.form_strength	
	, "|", drug.brand_name	
	, "|", manf.manufacturer_code	
	, "|", drug.brand_ident	
	)	
	, domain_alignment_comparison_text = if (ocsm.pbs_ocs_mapping_id > 0)	
	 build(list.pbs_item_code	
	, "|", drug.form_strength	
	, "|", drug.brand_name	
	, "|", manf.manufacturer_code	
	, "|", drug.brand_ident	
	, "|", ocs.mnemonic	
;	, "|", uar_get_code_meaning(ocs.mnemonic_type_cd)	
	)	
	else "-"	
	endif	
	, pbs_ocs_mapping_id = if (ocsm.pbs_ocs_mapping_id > 0) cnvtstring(ocsm.pbs_ocs_mapping_id)	
	else ""	
	endif	
	, product_rank = dense_rank() over (partition by 0	
	order by	
	cnvtint(substring(1,TEXTLEN(list.pbs_item_code)-1,list.pbs_item_code))	
	, drug.brand_name	
	, drug.beg_effective_dt_tm desc	
	, drug.pbs_drug_id  desc	
	)	
		
from		
	pbs_listing list	
	, (inner join pbs_item item on item.pbs_listing_id = list.pbs_listing_id	
	and item.end_effective_dt_tm > sysdate	; current items only
	)	
	, (inner join pbs_drug drug on drug.pbs_item_id = item.pbs_item_id	
	and drug.end_effective_dt_tm > sysdate	; current products only
	)	
	, (inner join pbs_manf manf on manf.pbs_manufacturer_id = drug.pbs_manufacturer_id)	
	, (left join pbs_ocs_mapping ocsm on ocsm.pbs_drug_id = drug.pbs_drug_id	
	and ocsm.end_effective_dt_tm > sysdate	; current mappings only
	)	
	, (left join prsnl pocsm on pocsm.person_id = ocsm.updt_id)	
	, (left join order_catalog_synonym ocs on ocs.synonym_id = ocsm.synonym_id)	
		
		
plan	list	
where	cnvtint(substring(1,TEXTLEN(list.pbs_item_code)-1,list.pbs_item_code)) <9000	; used to split audit in two if DVDev times out
;where	cnvtint(substring(1,TEXTLEN(list.pbs_item_code)-1,list.pbs_item_code)) >= 9000	; used to split audit in two if DVDev times out
and	(	
	list.drug_type_mean not in ("DB", "HS", "IN", "PQ", "TY")	
	or	
	(	
	list.drug_type_mean in ("DB", "HS", "IN", "PQ", "TY")	
	and exists (select 1	
	from pbs_ocs_mapping	
	where ocsm.end_effective_dt_tm > sysdate	
	and pbs_drug_id in (select pbs_drug_id	
	 from pbs_drug 	
	where pbs_item_id = (select pbs_item_id	
	 from pbs_item	
	where pbs_listing_id = list.pbs_listing_id	
	)	
	)	
	)	
	)	
	)	
		
;where	list.pbs_item_code = "1003T"	
join	item	
join	drug	
join	manf	
join	ocsm	
join	pocsm	
join	ocs	
		
order by		
	product_rank	
	, trim(ocs.mnemonic_key_cap)	
	, cnvtint(ocs.mnemonic_type_cd)	; for duplicate synonym names. PBSTool doesn't use this sort.
	, 0	
		
with	time = 60
