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
,132694918
,133320830
,132694960
,144792920
,132460778
,126529788
,126593740
,143467604
,124216741
,126529747
,146341986
,133282463
,124237288
,111661322
,144760353
,126529773
,125971181
,125971202
,133282868
,132490563
,129187868
,106948832
,126593723
,115048540
,82299400
,124217002
,82300612
,82292261
,124216755
,132490549
,111661230
,103172766
,82640369
,124217011
,152019749
,124237300
,64153663
,64172247
,64172252
,64172269
,64172279
,64172283
,64172224
,86488731
,64153584
,32413855
,37096484
,26770861
,82299452
,64153524
,64153562
,64172071
,64153528
,82868978
,85749636
,86604934
,84871023
,85748729
,91044841
,91044835
,89180701
,91044853
,97620177
,152026725
,152032101
,152031495
,132490556
,151898351
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