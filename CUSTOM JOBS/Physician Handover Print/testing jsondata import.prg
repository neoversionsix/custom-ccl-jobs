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