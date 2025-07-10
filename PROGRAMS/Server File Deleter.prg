drop program wh_delete_a_file go
create program wh_delete_a_file

/**************************************************************
This program is designed to delete csv files that are not
to be stored on the server on a long term basis. For example,
when a large data extract saves a csv on the server.

INSTRUCTIONS:
Change the name of the csv file (2 places) below and then run
to delete the file. Be extremely careful to delete the correct
file.

You can use the below paths depending on the domain. Note
that the file path is different depending on the domain.
Olympus can be used to find the file path by using the file
browser.

CERT Example:
/cerner/w_custom/p2031_cust/code/script/prod_users.csv

PROD Example:
/cerner/w_custom/c2031_cust/code/script/path_orders_2024.csv

The rm before the filename is a linux command used for
deleting. It means 'remove'.

programmers: Jason W and Arlo R
date: June 2025
**************************************************************/
prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV


CALL DCL(
		"rm /cerner/w_custom/p2031_cust/code/script/change_this_filename.csv"
	, SIZE(
		TRIM(
		"rm /cerner/w_custom/p2031_cust/code/script/change_this_filename.csv"
		)
	)
	,0
)

; Can use the below to remove a program
;set rstat = remove("some_program.prg")

end
go
; This part makes it delete off the other node/s
execute wh_delete_a_file go
