/* This allows the user to set custom outputs based on what's in the
database. eg if 1 then say 'yes' */

SELECT
	P.USERNAME
	, P.PHYSICIAN_IND
    ; 1-> yes    0->no
	, PHYSICIAN = EVALUATE(P.PHYSICIAN_IND, 1, "YES", 0, "NO")

FROM
	PRSNL   P

WITH MAXREC = 100, NOCOUNTER, SEPARATOR=" ", FORMAT