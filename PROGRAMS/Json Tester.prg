/*
Used to check what's in the JSON file passed from Powerchart to Dvdev
This one checks if the care team id's are in there
*/

; Change program name is required
drop program wh_physician_handover go
create program wh_physician_handover

; The two prompts below are recieved by the program ans stored in the two variables
; in the with section of the program
prompt
	"Output to File/Printer/MINE" = "MINE" ,
	"JSON Request:" = "" ; jsondata is passed to this program from powerchart

with
	  outdev
	, jsondata ; jsondata is passed to this program from powerchart

;Declare Vars
	declare test_string_var = vc with noconstant(""),protect
    declare total_number_of_encounters = i4 with noconstant(0),protect
    declare html_var = vc with noconstant(""),protect

;Add json patients to data record called print_options as inherited by PChart
	set stat = cnvtjsontorec($jsondata,0,0,0,0)

;Get the total number of encounters passed over from powerchart
	SET total_number_of_encounters = SIZE(PRINT_OPTIONS->QUAL,5)

;;Check if there thing you're after existing in the data structure (inherited from the json file)
;;use this loop for multiple values
for(x = 1 to total_number_of_encounters)
    set test_string_var = build2(test_string_var, "x = ", x, " - ",  PRINT_OPTIONS->QUAL[x].CARE_TEAM_ID, "<BR>")
endfor

;; To check just a single value
;set test_string_var = build2(cnvtstring(test_string_var), "<BR>", PRINT_OPTIONS->QUAL[x].CARE_TEAM_ID)

set html_var = build2(
'<!DOCTYPE html>'
,'<html lang="en">'
,'<head>'
    ,'<meta charset="UTF-8">'
    ,'<meta name="viewport" content="width=device-width, initial-scale=1.0">'
    ,'<title>Output</title>'
,'</head>'
,'<body>'
    ,'<p>', test_string_var,'</p>'
,'</body>'
,'</html>'
)

set _memory_reply_string = html_var

end
go