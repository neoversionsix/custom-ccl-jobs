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