drop program wh_prompt_program_template:group1 go
create program wh_prompt_program_template:group1

/* INSTRUCTIONS
To Use this as a template: 
1) File -> Save As
2) Choose a file name beggining with 'wh_'
3) Replace in the notes below
4) Delete the instructions section from your new program
5) Replace the code on lines 41-50 and choose new values on line
	57 for maxrec and time.
*/


/* NOTES
Programmer: Jason Whittle jason.whittle@wh.org.au
Data Requestor: Example User example.user@wh.org.au
Date: 17-OCT-2022
Purpose:
Used as a template for creating promt programs. This code 
will return all the usernames for accounts that were updated
from the date chosen to the current date.
*/

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Starting Date" = "CURDATE" 

with OUTDEV, FROMDT


;    Your Code Goes Here
SELECT into $OUTDEV
	P.USERNAME
FROM
	PRSNL P
WHERE P.UPDT_DT_TM
	BETWEEN
		CNVTDATETIME($FROMDT)
		AND
		CNVTDATETIME(CURDATE,CURTIME)

with time = 120, SEPARATOR=" ", format

end
go
