drop program wh_enc_discharge_dest_report go
create program wh_enc_discharge_dest_report

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "From_Date" = "SYSDATE"
	, "To_Date" = "SYSDATE"
	, "Med_Service" = 0
	, "Facility" = 85758822.0
	, "Nurse_Unit" = 0 

with OUTDEV, From_Date, To_Date, Med_Service, Facility, Nurse_Unit

/**************************************************************
; DVDev DECLARED VARIABLES
*************************************************************/
declare cnt = i4
declare opr_ms = c2
if(substring(1,1,reflect(parameter(parameter2($Facility),0))) = "L")  
	set opr_ms = "IN"
elseif(parameter(parameter2($Facility),1)= 0.0) 
	set opr_ms = "!=" 
else 
	set opr_ms = "="
endif

declare opr_fac = c2
if(substring(1,1,reflect(parameter(parameter2($Facility),0))) = "L")  
	set opr_fac = "IN"
elseif(parameter(parameter2($Facility),1)= 0.0) 
	set opr_fac = "!=" 
else 
	set opr_fac = "="
endif

declare opr_nu = c2
if(substring(1,1,reflect(parameter(parameter2($Nurse_Unit),0))) = "L")  
	set opr_nu = "IN"
elseif(parameter(parameter2($Nurse_Unit),1)= 0.0) 
	set opr_nu = "!=" 
else 
	set opr_nu = "="
endif

record data (
	1 total_count = f8
	1 elist [*]
		2 type = c40
		2 type_count = f8
		)



select into $outdev
	e.reg_dt_tm
	, uar_Get_code_display(E.disch_disposition_cd)
	, type_count = count(*) over (partition by e.disch_disposition_cd)
FROM
	encounter e
		where e.disch_dt_tm between cnvtdatetime($From_Date) and cnvtdatetime($To_Date)
			and operator(e.med_service_cd, opr_ms, $Med_Service)
			and operator(e.loc_facility_cd, opr_fac, $Facility)
			and operator(e.loc_nurse_unit_cd, opr_nu, $Nurse_Unit)
			;and e.disch_disposition_cd > 0.0
			;and e.encntr_type_cd not in (87933542.00, 309310.00)
			;and e.encntr_type_class_cd not in (393.0, 395.0, 399.0)

head report
	cnt = 0

	call alterlist(data->elist,100)
	head e.disch_disposition_cd
		cnt += 1

	if(mod(cnt,10) = 1 and cnt > 100)
		call alterlist(data->elist, cnt + 10)
	endif
	
	foot e.disch_disposition_cd
		data->elist[cnt].type = uar_get_code_display(e.disch_disposition_cd)
		data->elist[cnt].type_count = type_count
foot report
	data->total_count = count(e.seq)
call alterlist(data->elist, cnt)
WITH  SEPARATOR = " ", FORMAT, TIME = 30


SELECT into $outdev
	discharge_dest = data->elist[d1.seq].type
	,count               = data->elist[d1.seq].type_count
	, percent 		= (data->elist[d1.seq].type_count/data->total_count)*100
FROM (dummyt d1 with seq = value(cnt))
PLAN d1
ORDER discharge_dest desc

with nocounter, separator = " ", format

End go
