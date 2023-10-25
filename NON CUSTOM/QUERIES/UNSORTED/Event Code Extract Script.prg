select	; event codes	
	event_code = cv.code_value	
	, patient_records = if(ce_count.result_count >"0") ce_count.result_count	
	else "0"	
	endif	
	, event_code_display = cv.display	
	, event_code_active = cv.active_ind	
	, event_code_last_update = format(cv.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, event_code_last_updater = if(cv.code_value > 0 and cv.updt_id = 0) "0"	
	else p_cv.name_full_formatted	
	endif	
		
from		
	code_value cv	
	, (left join prsnl p_cv on p_cv.person_id = cv.updt_id)	
	, (left join (select ce.event_cd, result_count = count(*) from clinical_event ce group by ce.event_cd) ce_count on ce_count.event_cd = cv.code_value)	
		
		
plan	cv	
where	cv.code_set = 72	; event codes
join	p_cv	
join	ce_count	
		
order by		
	cv.display_key	
	, cv.active_ind desc	
	, cv.code_value	
	, 0	
		
with	time = 180	
