drop program wh_physician_handover go
create program wh_physician_handover
; [1] changed 2 lines above: swapped "msj_ph_custom_print" with "whs_physician_handover" to identify the program name in
; in non-prod env without destroying the current print format
prompt
	"Output to File/Printer/MINE" = "MINE" ,
	"JSON Request:" = "" ; jsondata is passed to this program from powerchart


with
	  outdev
	, jsondata ; jsondata is passed to this program from powerchart

declare finalhtml = vc with noconstant(" "),protect
declare jsontext = vc with noconstant(" "),protect

set jsontext = $jsondata

set finalhtml build2
	(
'<!DOCTYPE html>'
,'<html lang="en">'
,'<head>'
    ,'<meta charset="UTF-8">'
    ,'<meta name="viewport" content="width=device-width, initial-scale=1.0">'
    ,'<title>Hello Page</title>'
,'</head>'
,'<body>'
    ,'<p>'
	, jsontext
	,'</p>'
,'</body>'
,'</html>'
	)
; Send the finalhtml to the output device
set _memory_reply_string = finalhtml

end
go