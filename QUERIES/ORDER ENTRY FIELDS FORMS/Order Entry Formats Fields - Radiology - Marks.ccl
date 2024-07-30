select	; Radiology order entry format alignment
	domain = concat( trim(curdomain) ,' (', format(sysdate,"yyyymmdd hhmm;3;q"), ")" )
	, catalog_type = uar_get_code_display(oef.catalog_type_cd)
	, oef_name = oef.oe_format_name
	, synonyms_using_oef = if(oef_synonyms.count > "0") oef_synonyms.count
	else "0"
	endif
	, orders_using_oef = if(oef_orders.count > "0") oef_orders.count
	else "0"
	endif
	, oef_ID = oef.oe_format_id
	, order_action = uar_get_code_display(oef.action_type_cd)
	, action_type_cd = oef.action_type_cd
	, field_description = o_e_fields.description
	, field_label = oef_fields.label_text
	, accepted = if(oef_fields.oe_format_id = 0) ""
	else evaluate(oef_fields.accept_flag
	, 1, "Optional"
	, 2, "Do Not Display"
	, 3, "Display Only"
	, 4, "Required"
	)
	endif
	, status_line = oef_fields.status_line
	, default_value = if (oef_fields.default_parent_entity_id > 0) cnvtstring (oef_fields.default_parent_entity_id)
	else oef_fields.default_value
	endif
	, default_value_code_display = uar_get_code_display(oef_fields.default_parent_entity_id)
	, filter_parameters = oef_fields.filter_params
	, field_catalog_type_filters = if(field_cat_filters.count > "0") field_cat_filters.count
	else "0"
	endif
	, field_activity_type_filters = if(field_act_filters.count > "0") field_act_filters.count
	else "0"
	endif
	, field_orderable_filters = if(field_ord_filters.count > "0") field_ord_filters.count
	else "0"
	endif
	, field_synonym_filters = if(field_syn_filters.count > "0") field_syn_filters.count
	else "0"
	endif
	, max_occurances = if(oef_fields.oe_format_id = 0) ""
	else cnvtstring(oef_fields.max_nbr_occur)
	endif
	, decimal_places = oef_fields.input_mask
	, carry_field_forward = evaluate(oef_fields.def_prev_order_ind,
	0,"",
	1,"x")
	, do_not_copy_for_PP = if(oef_fields.oe_format_id = 0) ""
	else evaluate(oef_fields.carry_fwd_plan_ind
	, 0, "x"
	, 1, ""
	)
	endif
	, value_required = evaluate(oef_fields.value_required_ind
	, 0, ""
	, 1, "x"
	)
	, lock_on_modify = evaluate(oef_fields.lock_on_modify_flag
	, 0, ""
	, 1, "x"
	)
	, modification_triggers_nurse_review = evaluate(oef_fields.require_review_ind
	, 0, ""
	, 1, "x"
	)
	, modification_triggers_doctor_cosign = evaluate(oef_fields.require_cosign_ind
	, 0, ""
	, 1, "x"
	)
	, modification_triggers_pharmacist_verify = evaluate(oef_fields.require_verify_ind
	, 0, ""
	, 1, "x"
	)
	, group_sequence = if(oef_fields.oe_format_id = 0) ""
	else cnvtstring(oef_fields.group_seq)
	endif
	, field_sequence = if(oef_fields.oe_format_id = 0) ""
	else cnvtstring(oef_fields.field_seq)
	endif
	, display_on_cdl = evaluate(oef_fields.clin_line_ind
	, 0, ""
	, 1, "x"
	)
	, cdl_label = oef_fields.clin_line_label
	, display_cdl_label_after_value = evaluate(oef_fields.clin_suffix_ind
	, 0, ""
	, 1, "x"
	)
	, display_values_on_cdl = if(oef_fields.oe_format_id = 0) ""
	else evaluate(oef_fields.disp_yes_no_flag
	, 0, "Display yes and no values"
	, 1, "Display yes values"
	, 2, "Display no values"
	)
	endif
	, display_on_ddl = evaluate(oef_fields.dept_line_ind
	, 0, ""
	, 1, "x"
	)
	, ddl_label = oef_fields.dept_line_label
	, display_ddl_label_after_value = evaluate(oef_fields.dept_suffix_ind
	, 0, ""
	, 1, "x"
	)
	, display_values_on_ddl = if(oef_fields.oe_format_id = 0) ""
	else evaluate(oef_fields.disp_dept_yes_no_flag
	, 0, "Display yes and no values"
	, 1, "Display yes values"
	, 2, "Display no values"
	)
	endif
	, order_details_using_field = concat(
	"=IFNA(VLOOKUP(CONCAT(INDIRECT(",CHAR(34),"$F",CHAR(34),"&ROW()),",CHAR(34),"|",CHAR(34),"
	,INDIRECT(",CHAR(34),"$H",CHAR(34),"&ROW()),",CHAR(34),"|",CHAR(34),"
	,INDIRECT(",CHAR(34),"$AN",CHAR(34),"&ROW())),'order_details'!$B:$C,2,FALSE), 0)"
	)
;	if(oef.action_type_cd = 614533)	; 'Discharge Order' from code set
;	if(field_dis_o_ds.count = null) "0"
;	else field_dis_o_ds.count
;	endif
;	else
;	if(oef_fields.oe_field_id > 0 and field_o_ds.count = null) "0"
;	else field_o_ds.count
;	endif
;	endif
	, field_id = if(oef_fields.oe_format_id > 0) cnvtstring(oef_fields.oe_field_id)
	else ""
	endif
	, oef_field_last_update = format(oef_fields.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")
	, oef_field_last_updater = if(oef_fields.oe_format_id > 0 and p_oef_fields.name_full_formatted = null) cnvtstring(oef_fields.updt_id)
	else p_oef_fields.name_full_formatted
	endif
	, domain_alignment_comparison_text = build(
	uar_get_code_display(oef.catalog_type_cd)
	, "|", oef.oe_format_name
	, "|", uar_get_code_display(oef.action_type_cd)
	, "|", o_e_fields.description
	, "|", oef_fields.label_text
	, "|", oef_fields.accept_flag
	, "|", oef_fields.status_line
	, "|", if (oef_fields.default_parent_entity_id > 0) uar_get_code_display(oef_fields.default_parent_entity_id)
	else oef_fields.default_value
	endif
	, "|", oef_fields.filter_params
	, "|", oef_fields.max_nbr_occur
	, "|", oef_fields.input_mask
	, "|", oef_fields.def_prev_order_ind
	, "|", oef_fields.carry_fwd_plan_ind
	, "|", oef_fields.value_required_ind
	, "|", oef_fields.lock_on_modify_flag
	, "|", oef_fields.require_review_ind
	, "|", oef_fields.require_cosign_ind
	, "|", oef_fields.require_verify_ind
	, "|", oef_fields.group_seq
	, "|", oef_fields.field_seq
	, "|", oef_fields.clin_line_ind
	, "|", oef_fields.clin_line_label
	, "|", oef_fields.clin_suffix_ind
	, "|", oef_fields.disp_yes_no_flag
	, "|", oef_fields.dept_line_ind
	, "|", oef_fields.dept_line_label
	, "|", oef_fields.dept_suffix_ind
	, "|", oef_fields.disp_dept_yes_no_flag
	)
	, oef_rank = dense_rank() over (partition by 0
	order by
	cv_oef_cat.display_key
	, cnvtupper(substring(1,100,oef.oe_format_name))
	)

from
	order_entry_format oef
	, (left join code_value cv_oef_cat on cv_oef_cat.code_value = oef.catalog_type_cd)
	, (left join oe_format_fields oef_fields on oef_fields.oe_format_id = oef.oe_format_id
	and oef_fields.action_type_cd = oef.action_type_cd
	)
	, (left join prsnl p_oef_fields on p_oef_fields.person_id = oef_fields.updt_id)
	, (left join order_entry_fields o_e_fields on o_e_fields.oe_field_id = oef_fields.oe_field_id)
	, (left join (select ocs.oe_format_id, count = count(*) from order_catalog_synonym ocs group by ocs.oe_format_id) oef_synonyms on oef_synonyms.oe_format_id = oef.oe_format_id)
	, (left join (select oc.catalog_type_cd, der.entity3_id, count = count(distinct der.entity1_id)
	from dcp_entity_reltn der, order_catalog oc
	where der.entity_reltn_mean = "CT/*"
	and der.entity1_id = oc.catalog_type_cd
	group by oc.catalog_type_cd, der.entity3_id
	) field_cat_filters on field_cat_filters.catalog_type_cd = oef.catalog_type_cd
	and field_cat_filters.entity3_id = oef_fields.oe_field_id
	)
	, (left join (select oc.catalog_type_cd, der.entity3_id, count = count(distinct der.entity1_id)
	from dcp_entity_reltn der, order_catalog oc
	where der.entity_reltn_mean = "AT/*"
	and der.entity1_id = oc.activity_type_cd
	group by oc.catalog_type_cd, der.entity3_id
	) field_act_filters on field_act_filters.catalog_type_cd = oef.catalog_type_cd
	and field_act_filters.entity3_id = oef_fields.oe_field_id
	)
	, (left join (select oc.catalog_type_cd, der.entity3_id, ocs.oe_format_id, count = count(distinct der.entity1_id)
	from dcp_entity_reltn der, order_catalog oc, order_catalog_synonym ocs
	where der.entity_reltn_mean = "ORC/*"
	and der.entity1_id = oc.catalog_cd
	and ocs.catalog_cd = oc.catalog_cd
	group by oc.catalog_type_cd, der.entity3_id, ocs.oe_format_id
	) field_ord_filters on field_ord_filters.catalog_type_cd = oef.catalog_type_cd
	and field_ord_filters.entity3_id = oef_fields.oe_field_id
	and field_ord_filters.oe_format_id = oef.oe_format_id
	)
	, (left join (select ocs.catalog_type_cd, der.entity3_id, ocs.oe_format_id, count = count(distinct der.entity1_id)
	from dcp_entity_reltn der, order_catalog_synonym ocs
	where der.entity_reltn_mean = "OCS/*"
	and der.entity1_id = ocs.synonym_id
	group by ocs.catalog_type_cd, der.entity3_id, ocs.oe_format_id
	) field_syn_filters on field_syn_filters.catalog_type_cd = oef.catalog_type_cd
	and field_syn_filters.entity3_id = oef_fields.oe_field_id
	and field_syn_filters.oe_format_id = oef.oe_format_id
	)
	, (left join (select o.oe_format_id, count = count(*)
	from orders o
;	where o.catalog_type_cd not in (2513, 2516, 2517, 0)
;	where o.catalog_type_cd = 2513
;	where o.catalog_type_cd = 2515
;	where o.catalog_type_cd = 2516
	where o.catalog_type_cd = 2517
;	where o.catalog_type_cd in (2519, 84871493)
	group by o.oe_format_id
	) oef_orders on oef_orders.oe_format_id = oef.oe_format_id
	)
;	, (left join (select o.oe_format_id, o_a.action_type_cd, o_d.oe_field_id, count = count(*)
;	from orders o, order_detail o_d, order_action o_a
;;	where o.catalog_type_cd not in (2513, 2516, 2517, 0)	; code values for 'Laboratory', 'Pharmacy' and 'Radiology' from code set 6000. '0' prevents '0 row' on oc table from returning.
;;	where o.catalog_type_cd = 2513 	; code value for 'Laboratory' from code set 6000
;;	where o.catalog_type_cd = 2515	; code value for 'Patient Care' from code set 6000
;;	where o.catalog_type_cd = 2516	; code value for 'Pharmacy' from code set 6000
;	where o.catalog_type_cd = 2517 	; code value for 'Radiology' from code set 6000
;;	where o.catalog_type_cd in (2519, 84871493)	; code values for 'Surgery' and 'CMBS Code - SN' from code set 6000
;	and o_a.order_id = o.order_id
;	and o_d.order_id = o_a.order_id
;	and o_d.action_sequence = o_a.action_sequence
;	group by o.oe_format_id, o_d.oe_field_id, o_a.action_type_cd
;	) field_o_ds on field_o_ds.oe_format_id = oef_fields.oe_format_id
;	and field_o_ds.action_type_cd = oef_fields.action_type_cd
;	and field_o_ds.oe_field_id = oef_fields.oe_field_id
;	)
;	, (left join (select o.oe_format_id, o_d.oe_field_id, count = count(*)
;	from orders o, order_detail o_d, order_action o_a
;;	where o.catalog_type_cd not in (2513, 2516, 2517, 0)	; code values for 'Laboratory', 'Pharmacy' and 'Radiology' from code set 6000. '0' prevents '0 row' on oc table from returning.
;;	where o.catalog_type_cd = 2513 	; code value for 'Laboratory' from code set 6000
;;	where o.catalog_type_cd = 2515	; code value for 'Patient Care' from code set 6000
;;	where o.catalog_type_cd = 2516	; code value for 'Pharmacy' from code set 6000
;	where o.catalog_type_cd = 2517 	; code value for 'Radiology' from code set 6000
;;	where o.catalog_type_cd in (2519, 84871493)	; code values for 'Surgery' and 'CMBS Code - SN' from code set 6000
;	and o.orig_ord_as_flag = 1	; 'Prescription/Discharge Order'
;	and o_a.order_id = o.order_id
;	and o_a.action_type_cd = 2534	; 'Order' from code set 6003
;	and o_d.order_id = o_a.order_id
;	and o_d.action_sequence = o_a.action_sequence
;	group by o.oe_format_id, o_d.oe_field_id
;	) field_dis_o_ds on field_dis_o_ds.oe_format_id = oef.oe_format_id
;	and field_dis_o_ds.oe_field_id = oef_fields.oe_field_id
;	)

plan	oef
;where 	oef.catalog_type_cd not in (2513, 2516, 2517, 0)	; code values for 'Laboratory', 'Pharmacy' and 'Radiology' from code set 6000. '0' prevents '0 row' on oc table from returning.
;where 	oef.catalog_type_cd = 2513 	; code value for 'Laboratory' from code set 6000
;where 	oef.catalog_type_cd = 2515	; code value for 'Patient Care' from code set 6000
;where 	oef.catalog_type_cd = 2516	; code value for 'Pharmacy' from code set 6000
where 	oef.catalog_type_cd = 2517 	; code value for 'Radiology' from code set 6000
;where	oef.catalog_type_cd in (2519, 50010734, 84670240, 84695079 , 84871493)	; code values for 'Surgery' and 'CMBS Code - SN' from code set 6000 for G1, G2, G3 and G4
;and	oef.oe_format_id = 12345678
;and	oef.action_type_cd = 2534
;and	cnvtupper(oef.oe_format_name)  <= "RAD MAMMO"
;and	cnvtupper(oef.oe_format_name)  > "RAD MAMMO"
join	cv_oef_cat
join	oef_fields
join	p_oef_fields
join	o_e_fields
join	oef_synonyms
join	field_cat_filters
join	field_act_filters
join	field_ord_filters
join	field_syn_filters
join	oef_orders
;join	field_o_ds
;join	field_dis_o_ds

order by
	cv_oef_cat.display_key
	, cnvtupper(substring(1,100,oef.oe_format_name))	; This field is 200 characters long, which is too long for 'order by' to function correctly.
	, evaluate(uar_get_code_display(oef.action_type_cd)
	, "Order", 1
	, "Suspend", 2
	, "Resume", 3
	, "Cancel", 4
	, "Discontinue", 5
	, "Delete", 6
	, "Discharge Order", 7
	 ,"History Order", 8
	)
	, oef_fields.group_seq
	, oef_fields.field_seq
	, oef_fields.rowid desc
	, 0

with	time = 60
