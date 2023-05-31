drop program whs_def_coll_time_T1_0600 go

create program whs_def_coll_time_T1_0600



;prompt

; "Output to File/Printer/MINE" = "MINE"

;with OUTDEV



update into collection_priority coll_p

set coll_p.default_start_dt_tm = "T+1;0600" ; tomorrow at 0600 hrs

, coll_p.updt_dt_tm = cnvtdatetime(curdate,curtime3)

, coll_p.updt_id = 1 ; SYSTEM, SYSTEM

where coll_p.collection_priority_cd = 311045 ; Phlebotomy Round



commit



Set reply->status_data->status = "S"



end

go