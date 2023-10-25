select	*
/*
PBS drug replacement corrections
\\whoffice\shared\EMR\BAU\Audit Spreadsheets\PBS audits\Spreadsheets\PBS Processing 1 - monthly drug replacement corrections.xlsx
*/
from	(		
	(select		
		pbs_code = list.pbs_item_code	
		, orig_form_strength = drug_orig.form_strength	
		, new_form_strength = drug_new.form_strength	
		, product_brand_name = drug_orig.brand_name	
	;	, new_product_brand_name = drug_new.brand_name	
	;	, orig_manufacturer_code = manf_orig.manufacturer_code	
	;	, new_manufacturer_code = manf_new.manufacturer_code	
		, orig_brand_ident = drug_orig.brand_ident	
		, new_brand_ident = drug_new.brand_ident	
	;	, orig_product_beg_date = format(drug_orig.beg_effective_dt_tm, "dd/MMM/yy")	
	;	, new_product_beg_date = format(drug_new.beg_effective_dt_tm, "dd/MMM/yy")	
	;	, orig_product_end_date = format(drug_orig.end_effective_dt_tm, "dd/MMM/yy")	
	;	, new_product_end_date = format(drug_new.end_effective_dt_tm, "dd/MMM/yy")	
	;	, ocs.mnemonic	
		, orig_drug_pbs_drug_id = drug_orig.pbs_drug_id	
		, new_drug_pbs_drug_id = drug_new.pbs_drug_id	
	;	, ocsm.pbs_ocs_mapping_id	
		, orig_rank = dense_rank () over (partition by list.pbs_item_code	
		, drug_orig.brand_name	
		order by drug_orig.pbs_drug_id desc	
		)	
		, new_rank = dense_rank () over (partition by list.pbs_item_code	
		, drug_new.brand_name	
		order by drug_new.pbs_drug_id desc	
		)	
			
	from		
		pbs_listing list	
		, pbs_item item	
		, pbs_drug drug_orig	
		, pbs_manf manf_orig	
	;	, pbs_ocs_mapping ocsm	
	;	, order_catalog_synonym ocs	
		, pbs_drug drug_new	
		, pbs_manf manf_new	
			
	;where	list.pbs_item_code = "10391X"	
			
	where	item.pbs_listing_id = list.pbs_listing_id	
			
	and	drug_orig.pbs_item_id = item.pbs_item_id	
	;and	drug_orig.end_effective_dt_tm = cnvtdatetime("30-NOV-2016 23:59:59")	
	and	exists (select 1	
		from pbs_ocs_mapping ocsm	
		where ocsm.pbs_drug_id = drug_orig.pbs_drug_id	
		and ocsm.end_effective_dt_tm > sysdate	
		)	
			
	and	manf_orig.pbs_manufacturer_id = drug_orig.pbs_manufacturer_id	
			
	;and	ocsm.pbs_drug_id = drug_orig.pbs_drug_id	
			
	;and	ocs.synonym_id = ocsm.synonym_id	
			
	and	drug_new.pbs_item_id = drug_orig.pbs_item_id	
	;and	drug_new.form_strength = drug_orig.form_strength	
	and	drug_new.brand_name = drug_orig.brand_name	
	;and	drug_new.brand_ident = drug_orig.brand_ident	
	and	drug_new.pbs_manufacturer_id = drug_orig.pbs_manufacturer_id	
	and	drug_new.beg_effective_dt_tm > drug_orig.end_effective_dt_tm	
	and	drug_new.beg_effective_dt_tm != cnvtdatetime(curdate, 0001)	; exclude already updated rows
			
	and	manf_new.pbs_manufacturer_id = drug_new.pbs_manufacturer_id	
			
	order by		
		list.pbs_item_code	
		, drug_orig.brand_name	
		, drug_orig.pbs_drug_id  desc	; for multiple 'form/strength' PBS codes
		, drug_new.brand_name	
		, drug_new.pbs_drug_id  desc	
			
	with	sqltype ("vc", "vc", "vc", "vc", "vc", "vc", "f8", "f8", "i2", "i2")) x	
	)		
			
where	x.new_rank = x.orig_rank
