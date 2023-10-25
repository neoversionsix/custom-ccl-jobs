select
/*
Sourcce: https://community.cerner.com/t5/CCL-Discern-Explorer-Client-and-Cerner-Collaboration/Orders-within-a-Powerplan/m-p/414975
 */
   pc.description
 , pc.pathway_catalog_id
 , pcr.pw_cat_s_id
 , pcr.pw_cat_t_id
 , pcr.type_mean
 , pc1.description
 , o.catalog_cd
 , oc.description

from  pathway_catalog pc
 , pw_cat_reltn pcr
 , pathway_catalog pc1
 , pathway_comp pcp
 , order_catalog_synonym o
 , order_catalog oc

plan pc
where pc.active_ind = 1
and pc.end_effective_dt_tm > sysdate
and pc.description_key like "Power_Plan_Name"

join pcr
where pcr.pw_cat_s_id = pc.pathway_catalog_id

join pc1
where pc1.pathway_catalog_id = pcr.pw_cat_t_id

join pcp
where pcp.pathway_catalog_id = pc1.pathway_catalog_id
and pcp.parent_entity_name = "ORDER_CATALOG_SYNONYM"

join o
where o.synonym_id = pcp.parent_entity_id

join oc
where oc.catalog_cd = o.catalog_cd

with format, time = 60, separator = " "