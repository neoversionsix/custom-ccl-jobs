;NOTES
    /*
    Program: wh_mdm_report
    Date Created: 27th of October 2022
    Description: Report for MDM Care Team Meeting
    Programmer: Jason Whittle

    */



;CREATE PROGRAM AND PROMPT
    ; drop program whs_physician_handover:dba go
    ; create program whs_physician_handover:dba

    drop program wh_mdm_report go   ;drop program wh_mdm_report:dba go
    create program wh_mdm_report    ;create program wh_mdm_report:dba

    prompt
    	"Output to File/Printer/MINE" = "MINE" ,
    	"JSON Request:" = ""
    with outdev ,jsondata

;DECLARE CONSTANTS
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
		2 PATIENT_NAME				= vc
		2 GENDER					= vc
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
	
	foot encounter
		null
	
	foot report
		data->cnt = cnt
		stat = alterlist(data->list,cnt)
	
	with nocounter

;Get patient information
	SELECT INTO "nl:"
	FROM
		PERSON P
	PLAN P
		WHERE EXPAND(idx,1,data->cnt,P.PERSON_ID,data->list[idx].PERSON_ID)
	ORDER BY P.PERSON_ID
	
	HEAD P.PERSON_ID
		pos = locateval(idx,1,data->cnt,P.PERSON_ID,data->list[idx].PERSON_ID)
		IF(pos > 0)
			data->list[pos].PATIENT_NAME = TRIM(P.NAME_FULL_FORMATTED,3)
			data->list[pos].GENDER = TRIM(UAR_GET_CODE_DISPLAY(P.SEX_CD),3)
		ENDIF
	
	foot P.PERSON_ID
		NULL
	
	WITH EXPAND = 2

;Add to 'patienthtml' variable, a HTML table for each patient
	call alterlist(html_log->list,data->cnt)
	for(x = 1 to data->cnt)
		set html_log->list[x].start = textlen(trim(patienthtml,3)) + 1
		set patienthtml = build2(patienthtml
			,"<p class=patient-info-name>", data->list[x].PATIENT_NAME,"</p>"
			,"<br>"

            ,"<table>"
              ,"<tr>"
			  	,"<th>URN</th>"
				,"<th>DOB</th>"
				,"<th>Age</th>"
				,"<th>Gender</th>"
              ,"</tr>"
              ,"<tr>"
                ,"<td>Alfreds Futterkiste</td>"
                ,"<td>Maria Anders</td>"
                ,"<td>Germany</td>"
				,"<td>France</td>"
              ,"</tr>"
            ,"</table>"

            ,"<table>"
              ,"<tr>"
				,"<th>Care Teams</th>"
                ,"<th>Consultant</th>"
                ,"<th>Clinical Notes</th>"
                ,"<th>Imaging</th>"
              ,"</tr>"
              ,"<tr>"
                ,"<td>Alfreds Futterkiste</td>"
                ,"<td>Maria Anders</td>"
                ,"<td>Germany</td>"
				,"<td>France</td>"
              ,"</tr>"
            ,"</table>"

            ,"<table>"
              ,"<tr>"
				,"<th>Pathology</th>"
				,"<th>MDM Question</th>"
				,"<th>MDM Date</th>"
				,"<th>Pre-op/Post-op Discussion</th>"
              ,"</tr>"
              ,"<tr>"
                ,"<td>Alfreds Futterkiste</td>"
                ,"<td>Maria Anders</td>"
                ,"<td>Germany</td>"
				,"<td>France</td>"
              ,"</tr>"
            ,"</table>"

            ,"<table>"
              ,"<tr>"
				,"<th>Clinic Appointment/Follow Up Planned</th>"
				,"<th>Scopes</th>"
				,"<th>Relevant Bloods</th>"
				,"<th>Cancer MDM or Surgical Meeting</th>"
              ,"</tr>"
              ,"<tr>"
                ,"<td>Alfreds Futterkiste</td>"
                ,"<td>Maria Anders</td>"
                ,"<td>Germany</td>"
				,"<td>France</td>"
              ,"</tr>"
            ,"</table>"
		)
    endfor

;Build HTML Page and substitute in the patient table
	set finalhtml = build2(
		"<!doctype html><html><head>"
		,"<meta charset=utf-8><meta name=description><meta http-equiv=X-UA-Compatible content=IE=Edge>"
		,"<title>MPage Print</title>"
		; CSS CODE IS BELOW
		    ,"<style type=text/css>"
		    ,".patient-info-name {font-size: 120%; border: 1px solid #dddddd; font-weight: 800; background-color:lightgrey}"
			,"table {"
			,"border: 1px solid;"
			,"width: 100%;"
			,"}"
			,"th, td {"
			,"border: 1px solid;"
  			,"padding: 15px;"
  			,"text-align: left;"
			,"}"
			,"tr:hover {background-color: coral;}"
		    ,"</style> </head>"
		; END OF CSS CODE START OF HEADER
		    ,"<div id = print-container> <div class=print-header> <div class=printed-by-user>"
		    ,"<span> Printed By:  </span> <span>",printuser_name,"</span>"
		    ,"<div class=printed-date> <span>"
		    , "PRINTED: "
		    ,format(cnvtdatetime(curdate,curtime),"dd/mm/yyyy hh:mm;;d")
		    ,"</span> </div> </div> </div>"
		    ,"</div> <div class=print-title> <h2> Cancer MDM Worklist </h2> </div>"
		; PATIENT DATA IN THE VARIABLE BELOW
		    ,patienthtml
		,"</body></html>")

;Send HTML string back to PowerChart for printing
	if(validate(_memory_reply_string) = 1)
		set _memory_reply_string = finalhtml
	else
		free record putrequest
		record putrequest (
		1 source_dir = vc
		1 source_filename = vc
		1 nbrlines = i4
		1 line [*]
			2 linedata = vc
		1 overflowpage [*]
			2 ofr_qual [*]
			3 ofr_line = vc
		1 isblob = c1
		1 document_size = i4
		1 document = gvc
		)
		set putrequest->source_dir =  $OUTDEV
		set putrequest->isblob = "1"
		set putrequest->document = finalhtml
		set putrequest->document_size = size (putrequest->document)
		execute eks_put_source with replace("REQUEST" ,putrequest), replace("REPLY" ,putreply)
	endif


	#exit_script
	end
	go