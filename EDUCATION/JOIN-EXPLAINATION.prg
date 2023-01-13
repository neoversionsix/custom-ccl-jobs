SELECT
	PERSON.PERSON_ID
    , PERSON.NAME_FIRST
    , PERSON.NAME_LAST
	, ORDERS.*
    , CODE_VALUE.CODE_VALUE
    , CODE_VALUE.DISPLAY

FROM
    ORDERS ; This is the base table
    , (LEFT JOIN PERSON ON ORDERS.PERSON_ID = PERSON.PERSON_ID) ; This is the join
PLAN
    ORDERS ; This is the (base) table you intend to read first, this is the table you want to restrict the data to.
JOIN
    PERSON ; This is the table that you want bolted on
;WHERE
WITH
    MAXREC=5
    TIME=20
