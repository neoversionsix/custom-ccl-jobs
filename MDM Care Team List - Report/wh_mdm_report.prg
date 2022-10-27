/*
Program: wh_mdm_report
Date Created: 27th of October 2022
Description: Report for MDM Care Team Meeting
Programmer: Jason Whittle

 */

drop program wh_mdm_report go   ;drop program wh_mdm_report:dba go
create program wh_mdm_report    ;create program wh_mdm_report:dba

prompt
	"Output to File/Printer/MINE" = "MINE" ,
	"JSON Request:" = ""
with outdev ,jsondata

;Declare Constants
	declare 319_URN_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",319,"URN")),protect
	;[1] 319 is the code set for URN on the CODE_VALUE table "URN" is the DISPLAY_KEY for urn


;Call Constants
    call echo(build2("319_URN_CD: ",319_URN_CD))

;Declare Variables
	declare idx = i4 with noconstant(0),protect
	declare patienthtml = vc with noconstant(" "),protect
	declare finalhtml = vc with noconstant(" "),protect
	declare newsize = i4 with noconstant(0),protect
	declare printuser_name = vc with noconstant(" "),protect

;Declare Records
	record data (
    1 cnt							= i4
	1 list[*]
		2 PERSON_ID					= f8
		2 ENCNTR_ID					= f8

    ) with protect

;HTML Log
    record html_log (
	1 list[*]
		2 start				= i4
		2 stop				= i4
		2 patient_text		= vc
	) with protect

;Set printuser_name
	select into "nl:"
	from
		prsnl p
	plan p
		where p.PERSON_ID = reqinfo->updt_id
	
	detail
		printuser_name = trim(p.name_full_formatted, 3)
	
	with nocounter

;Add json patients to data record
	set stat = cnvtjsontorec($jsondata)
	
	select into "nl:"
		encounter = print_options->qual[d1.seq].ENCNTR_ID
	from
		(dummyt d1 with seq = evaluate(size(print_options->qual,5),0,1,size(print_options->qual,5)))
	plan d1
		where size(print_options->qual,5) > 0
	order by encounter
	
	head report
		cnt = 0
	
	head encounter
		cnt += 1
		if(mod(cnt, 20) = 1)
			stat = alterlist(data->list,cnt + 19)
		endif
		data->list[cnt].ENCNTR_ID = print_options->qual[d1.seq].ENCNTR_ID
		data->list[cnt].PERSON_ID = print_options->qual[d1.seq].PERSON_ID
		data->list[cnt].age = trim(print_options->qual[d1.seq].pat_age,3)
	
	foot encounter
		null
	
	foot report
		data->cnt = cnt
		stat = alterlist(data->list,cnt)
	
	with nocounter