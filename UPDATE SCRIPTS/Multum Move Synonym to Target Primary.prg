update into	order_catalog_synonym ocs

set	ocs.catalog_cd  = (select catalog_cd
	                              from order_catalog
	                              where cki = "[MUL.ORD!d####]"	;'target' Primary DNUM
	                              )
	, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3)
	, ocs.updt_id = reqinfo->updt_id
	, ocs.updt_cnt = ocs.updt_cnt+1

where	ocs.catalog_type_cd = 2516	;code value for 'Pharmacy' from code set 6000
and	ocs.mnemonic in (
	                             "[synonym mnemonic 1]"	;synonyms being moved to target
	                            , "[synonym mnemonic 2]"	;synonyms being moved to target
	                             )

update into
order_catalog_item_r ocir

set	ocir.catalog_cd  = (select catalog_cd
	                                from order_catalog
	                                where cki = "[MUL.ORD!d####]"	;'target' Primary DNUM
	                                )
	, ocir.updt_dt_tm = cnvtdatetime(curdate,curtime3)
	, ocir.updt_id = reqinfo->updt_id
	, ocir.updt_cnt = ocir.updt_cnt+1

where	ocir.synonym_id = (select synonym_id
	                                 from order_catalog_synonym
	                                 where mnemonic in (
	                                                                  "[synonym mnemonic 1]"	;synonyms being moved to target
	                                                                   , "[synonym mnemonic 2]"	;synonyms being moved to target
	                                                                  ))
