/*
Programmer: Jason Whittle
*/

drop program wh_testing_query_88 go
create program wh_testing_query_88

prompt
	"Output to File/Printer/MINE" = "MINE"

WITH OUTDEV

declare tvar = VC with NoConstant('a_test'),Protect

SELECT INTO $OUTDEV
	D.USER
FROM DUMMYT D

HEAD REPORT
	tvar
	ROW +1
	, "END HEAD"
	ROW +1

FOOT REPORT
	"END FOOT"

WITH TIME = 10

end
go