
; P2031 AoF event_code merge	"

; Inactivate the add on the fly for 314527569
update into code_value cv
set cv.active_ind = 0
, cv.active_dt_tm = cnvtdatetime(curdate,curtime3)
, cv.active_status_prsnl_id = reqinfo->updt_id
, cv.data_status_cd = 25 ; 'Auth (Verified)' from code set 8
, cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3)
, cv.data_status_prsnl_id = reqinfo->updt_id
, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, cv.updt_id = reqinfo->updt_id
, cv.updt_cnt = cv.updt_cnt + 1
where cv.code_value = 314527569

; Move the Add on the fly to the correct folder
update into v500_event_set_explode ese_es
set ese_es.event_set_cd = 127911405
, ese_es.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, ese_es.updt_id = reqinfo->updt_id
, ese_es.updt_cnt = ese_es.updt_cnt + 1
where ese_es.event_cd = 314527569
and ese_es.event_set_level = 0
and exists (select 1 from code_value where code_value = 127911405 and code_set = 93 and active_ind = 1)

; As above
update into v500_event_code ec
set ec.event_set_name = "Blood Group & Antibodies & Hold comm"
, ec.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, ec.updt_id = reqinfo->updt_id
, ec.updt_cnt = ec.updt_cnt + 1
where ec.event_cd = 314527569
and exists (select 1 from v500_event_set_code where event_set_name = "Blood Group & Antibodies & Hold comm")

; Flip alias to new one
update into code_value_alias cva
set cva.code_value = 82584099
, cva.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, cva.updt_id = reqinfo->updt_id
, cva.updt_cnt = cva.updt_cnt + 1
where cva.code_value = 314527569
and exists (select 1 from code_value where code_value = 82584099 and code_set = 72 and active_ind = 1)

; Flip alias to new one
update into code_value_outbound cvo
set cvo.code_value = 82584099
, cvo.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, cvo.updt_id = reqinfo->updt_id
, cvo.updt_cnt = cvo.updt_cnt + 1
where cvo.code_value = 314527569
and exists (select 1 from code_value where code_value = 82584099 and code_set = 72 and active_ind = 1)

; Move patient records to the correct one
update into clinical_event ce
set ce.event_cd = 82584099
, ce.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, ce.updt_id = reqinfo->updt_id
, ce.updt_cnt = ce.updt_cnt + 1
where ce.event_cd = 314527569
and exists (select 1 from code_value where code_value = 82584099 and code_set = 72 and active_ind = 1)
;"