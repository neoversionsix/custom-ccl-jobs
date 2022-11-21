drop program WH_Orthopedics_Rad_Orders go
create program WH_Orthopedics_Rad_Orders

prompt 
	"Output to File/Printer/MINE" = "MINE"                   ;* Enter or select the printer or file name to send this report to.
	, "Start date for Appointment filtering" = "CURDATE"
	, "END date for for Appointment filtering" = "CURDATE" 

with OUTDEV, START_DT_ENC, END_DT_ENC

SELECT into $OUTDEV








ORDER BY
	, E.ARRIVE_DT_TM ASC


WITH TIME = 120, SEPARATOR=" ", FORMAT


END
GO