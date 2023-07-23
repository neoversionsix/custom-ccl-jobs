drop program WHS_bulk_updates  go
create program WHS_bulk_updates

prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV

;insert update scripts here

; Cancel Order on Discharge Fixer
update into order_catalog oc
set
  oc.auto_cancel_ind = 1
, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3) ; Update Time now
, oc.updt_id = reqinfo->updt_id ; Updater to person running the program
, oc.updt_cnt = oc.updt_cnt + 1 ; Add 1 to the update count
; MAKE CHANGE TO THE BELOW ONLY

WHERE
	oc.auto_cancel_ind = 0 ; where 0 only
	AND
	oc.UPDT_ID = 13544112 ; Jason Whittle Only
	AND
	oc.CATALOG_TYPE_CD = 2516; pharmacy only
    AND
    oc.catalog_cd
        IN (
148124171

            )


end
go

/*CHECKING SCRIPT
SELECT
	oc.auto_cancel_ind
	,*
FROM ORDER_CATALOG OC
WHERE
	oc.UPDT_ID = 13544112 ; Jason Whittle Only
	and
	oc.UPDT_DT_TM > CNVTLOOKBEHIND("1,D")
 */