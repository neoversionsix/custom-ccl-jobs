

;---OEF default field value correction--------;------------------------------------------------------------------------
update into
    oe_format_fields oef_fields
set
    oef_fields.default_value = "8,14,16,12,17,2,3,21,18,5,4,13,6,11,15,7,1,9,10,20,19" ; EDIT THIS!
    , oef_fields.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , oef_fields.updt_id = reqinfo->updt_id
    , oef_fields.updt_cnt = oef_fields.updt_cnt + 1
where
    oef_fields.oe_format_id = 7402275 ; EDIT THIS!
    and oef_fields.action_type_cd = 2534 ; EDIT THIS!
    and oef_fields.oe_field_id = 106885321 ; EDIT THIS!
;----------------------------------------------------------------------------------------------------------------------
