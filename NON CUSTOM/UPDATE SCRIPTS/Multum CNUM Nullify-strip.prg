drop program WHS_bulk_updates  go
create program WHS_bulk_updates

prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV

;insert update scripts here

; CNUM NULLIFY-STRIP (non-domain-specific)
update into order_catalog_synonym ocs
set ocs.cki = null ; CNUM
, ocs.concept_cki = null ; Used to be the Snomed Code, now blank
, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3) ; Update Time now
, ocs.updt_id = reqinfo->updt_id ; Updater to person running the program
, ocs.updt_cnt = ocs.updt_cnt + 1 ; Add 1 to the update count
; MAKE CHANGE TO THE LINE BELOW ONLY
where ocs.mnemonic = "zzzzChlorvescent 14 mmol oral effervescent tablet" ; replace zzzSlinda 4 mg oral tablet with your item

end
go