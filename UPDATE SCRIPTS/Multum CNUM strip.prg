drop program WHS_bulk_updates  go
create program WHS_bulk_updates
 
prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV
 
;insert update scripts here

; CNUM update (non-domain-specific)
update into order_catalog_synonym ocs
set ocs.cki = null
, ocs.concept_cki = null
, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3)
, ocs.updt_id = reqinfo->updt_id
, ocs.updt_cnt = ocs.updt_cnt + 1
where ocs.mnemonic = "zzzSlinda 4 mg oral tablet" ; replace zzzSlinda 4 mg oral tablet with your item

end
go