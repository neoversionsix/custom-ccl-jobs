select distinct

immunization_disp = uar_get_code_display(ce.event_cd),

date_added = format(ce.event_start_dt_tm, "MM/DD/YYYY HH:MM;;d"),

admin_date = format(cemr.valid_from_dt_tm, "MM/DD/YYYY HH:MM;;d"),

result_status = uar_get_code_display(ce.result_status_cd),

dose_number = ce.clinical_seq,

dose = cemr.admin_dosage,

dose_unit = uar_get_code_display(cemr.dosage_unit_cd),

route = uar_get_code_display(cemr.admin_route_cd),

site = uar_get_code_display(cemr.admin_site_cd),

manufacturer = uar_get_code_display(cemr.substance_manufacturer_cd),

lot_number = cemr.substance_lot_number,

exp_date = format(cemr.substance_exp_dt_tm, "MM/DD/YYYY HH:MM;;d"),

history_source = uar_get_code_display(ce.source_cd)

from

clinical_event ce,

ce_med_result cemr,

v500_event_set_code esc,

v500_event_set_explode ese,

v500_event_code ec

plan esc

where esc.event_set_name like "Immunizations"

join ese

where ese.event_set_cd = esc.event_set_cd

join ec

where ec.event_cd = ese.event_cd

join ce

where ce.event_cd = ec.event_cd

;and ce.person_id = 758652

and ce.event_tag != "Date\Time Correction"

and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)

and ce.result_status_cd in (25, 34)

join cemr

where cemr.event_id = outerjoin(ce.event_id)

go