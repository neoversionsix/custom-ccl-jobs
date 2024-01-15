drop program wh_dcmedsrecstatement:dba go
create program wh_dcmedsrecstatement:dba

SET rhead = "{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Tahoma;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
set wr = "\plain \f0 \fs20 \cb2 "
set reol = "\par"
set rtfeof = "}"

declare RECONCILEDMEDS = f8
declare COMPLETEDMEDSREC = f8 with constant(uar_get_code_by("DISPLAYKEY",4002695,"COMPLETE")) ,protect ;completed status meds rec

; get the encntr level information
select into "nl:"

from
  order_recon o
plan
  o
where
  o.encntr_id = request->visit[1].encntr_id
and
  o.recon_status_cd = COMPLETEDMEDSREC
and
  o.no_known_meds_ind = 0 ;reconciled meds exist
and
  o.recon_type_flag = 3 ;Discharge rec
detail
  RECONCILEDMEDS = o.order_recon_id

with nocounter

if (RECONCILEDMEDS = null)
        set reply->text = concat(rhead, wr, "\b Note: Medication reconciliation has NOT been performed so this medication list may NOT be accurate  \b", reol, rtfeof)
endif


end
go