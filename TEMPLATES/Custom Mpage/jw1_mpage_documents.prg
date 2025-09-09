drop program jw1_mpage_documents:dba go
create program jw1_mpage_documents:dba
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Person Id:" = 0.0
	, "Encounter Id:" = 0.0
 with outdev, personid, encntrid
free record documents
record documents (
	1 document[*]
		2 event_id = f8
		2 title = vc
		2 date = vc
)
declare inErrorCd = f8 with public, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
declare DOCCd  = f8 with public,constant(uar_get_code_by("MEANING", 53, "DOC"))

/******************************************************
 *     Get the Document Title, Date and Event_Id      *
 ******************************************************/
select into "nl:"
   evtDate = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;dq"),
   evtTitle = ce.event_tag,
   evtId = cnvtstring(ceb.event_id)
from
   clinical_event ce,
   ce_blob ceb
plan ce
  where ce.person_id = $PersonId
  	 and ce.event_end_dt_tm >= cnvtlookbehind("6 M",cnvtdatetime(curdate,curtime3))
     and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     and ce.encntr_id = $encntrid
     and ce.result_status_cd != inErrorCd
     and ce.event_class_cd = DOCCd
join ceb
   where ceb.event_id = ce.event_id
      and ceb.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
order by ce.event_end_dt_tm desc
head report
	cnt = 0
head ceb.event_id
	cnt = cnt + 1
	if (size(documents->document,5)<cnt)
		stat = alterlist(documents->document, cnt+10)
	endif
	documents->document[cnt].event_id = ceb.event_id
	documents->document[cnt].title = ce.event_tag
	documents->document[cnt].date = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;dq")
foot report
stat = alterlist(documents->document, cnt)
with nocounter
call echorecord(documents)

set _Memory_Reply_String = CNVTRECTOJSON(documents)
end
go