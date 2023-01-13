delete		
from	PBS_LISTING list	
where	list.pbs_listing_id not in (select item.pbs_listing_id	
	from PBS_ITEM item	
	where item.end_effective_dt_tm > sysdate	
	)	
		
delete		
from	PBS_PRICING pric	
where	pric.pbs_listing_id not in (select item.pbs_listing_id	
	from PBS_ITEM item	
	where item.end_effective_dt_tm > sysdate	
	)	
		
delete		
from	PBS_ITEM item	
where	(	
	item.pbs_listing_id not in (select list.pbs_listing_id	
	from pbs_listing list)	
	or	
	item.end_effective_dt_tm < sysdate	
	or	
	item.pbs_item_id not in (select drug.pbs_item_id	
	from pbs_drug drug	
	where drug.end_effective_dt_tm  > sysdate)	
	)	
		
delete		
from	PBS_DRUG drug	
where	(	
	drug.end_effective_dt_tm  < sysdate	
	or	
	drug.pbs_item_id not in (select pbs_item_id	
	from pbs_item	
	where end_effective_dt_tm > sysdate	
	)	
	)	
		
delete		
from	PBS_CAUTION_RELTN caut_rel	
where	caut_rel.pbs_item_id not in (select pbs_item_id	
	from pbs_item	
	where end_effective_dt_tm > sysdate	
	)	
		
delete		
from	PBS_CAUTION caut	
where	caut.pbs_caution_id not in (select pbs_caution_id	
	from PBS_CAUTION_RELTN	
	)	
		
delete		
from	PBS_INDICATION ind	
where	ind.end_effective_dt_tm < sysdate	
		
delete		
from	PBS_AUTHORITY auth	
where	auth.pbs_indication_id not in (select pbs_indication_id	
	from pbs_indication	
	where end_effective_dt_tm > sysdate	
	)	
		
update into	PBS_OCS_MAPPING ocsm	
set	ocsm.end_effective_dt_tm = cnvtdatetime(curdate, 0005)	
	, ocsm.pbs_drug_id = 11111111	
	, ocsm.synonym_id = 1111111	
where	(	; use to clean up mappings
	ocsm.end_effective_dt_tm < sysdate	
	or	
	ocsm.pbs_drug_id not in (select pbs_drug_id	
	from pbs_drug	
	where end_effective_dt_tm > sysdate	
	)	
	or	
	ocsm.synonym_id not in (select synonym_id	
	from order_catalog_synonym	
	where active_ind = 1	
	)	
	)	
	;ocsm.pbs_ocs_mapping_id in ()	; use to inactivate mappings
and	ocsm.pbs_drug_id != 11111111	
