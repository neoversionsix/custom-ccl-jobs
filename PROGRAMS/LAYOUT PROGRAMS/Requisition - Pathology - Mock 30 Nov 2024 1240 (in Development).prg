drop program WH_AU_REQGEN07_LYT go
create program WH_AU_REQGEN07_LYT

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "break_seq" = 1

with OUTDEV, BREAK_SEQ



execute ReportRtl
declare ptAlerts = vc with Protect
declare printedDtTm = vc with Protect
declare order_cnt = i2 with Public
declare TEST_CONT_IND = i2 with Protect
declare page_break_cnt = i2 with Constant($BREAK_SEQ),Protect
declare total_order_cnt = i2 with Protect
declare accession_rpt_cnt = i2 with Protect
record request (
  1 person_id = f8
  1 print_prsnl_id = f8
  1 order_qual [*]
    2 order_id = f8
    2 encntr_id = f8
    2 conversation_id = f8
  1 printer_name = c50
)

record allergy (
  1 cnt = i2
  1 qual [*]
    2 list = vc
  1 line = vc
  1 line_cnt = i2
  1 line_qual [*]
    2 line = vc
)

record diagnosis (
  1 cnt = i2
  1 qual [*]
    2 diag = vc
  1 dline = vc
  1 dline_cnt = i2
  1 dline_qual [*]
    2 dline = vc
)

record pt (
  1 line_cnt = i2
  1 lns [*]
    2 line = vc
)

record alerts (
  1 qual [*]
    2 alert_disp = vc
)

record orders (
  1 name = vc
  1 pat_addr = vc
  1 pat_type = vc
  1 reprint_ind = i2
  1 age = vc
  1 dob = vc
  1 dob_dt = dq8
  1 mrn = vc
  1 ssn = vc
  1 concess_nbr = vc
  1 location = vc
  1 fin_class = vc
  1 hospital_name = vc
  1 hospital_addr = vc
  1 service_prov = vc
  1 orgset_name = vc
  1 facility = vc
  1 fasting = vc
  1 nurse_unit = vc
  1 copy_to = vc
  1 req_st_dt = vc
  1 req_st_dt_tm = dq8
  1 room = vc
  1 bed = vc
  1 sex = vc
  1 fnbr = vc
  1 med_service = vc
  1 clin_hist = vc
  1 admit_diagnosis = vc
  1 height = vc
  1 height_dt_tm = vc
  1 weight = vc
  1 weight_dt_tm = vc
  1 admit_dt = vc
  1 dischg_dt = vc
  1 health_plan = vc
  1 health_plan_nbr = vc
  1 los = i4
  1 attending = vc
  1 admitting = vc
  1 order_location = VC
  1 spoolout_ind = i2
  1 cnt = i2
  1 total_cnt = i2
  1 page_break_cnt = i2
  1 page_break [*]
    2 sequence = i2
    2 order_cnt = i2
    2 req_st_dt = vc
    2 activity_type = vc
    2 fasting = vc
    2 file_name = vc
    2 clin_hist = vc
    2 order_list [*]
      3 order_id = f8
  1 qual [*]
    2 order_id = f8
    2 page_break_id = i2
    2 sort_order_id = i2
    2 display_ind = i2
    2 fasting = vc
    2 template_order_flag = i2
    2 cs_flag = i2
    2 iv_ind = i2
    2 mnemonic = vc
    2 mnemonic_sort = vc
    2 mnem_ln_cnt = i2
    2 mnem_ln_qual [*]
      3 mnem_line = vc
    2 pager_nbr = vc
    2 display_line = vc
    2 display_line_rtf = vc
    2 disp_ln_cnt = i2
    2 disp_ln_qual [*]
      3 disp_line = vc
    2 order_dt = vc
    2 bp_required = vc
    2 bloodbank_req = i2
    2 special_requirements = vc
    2 dt_tm_product_required = vc
    2 preg_last_3_months = vc
    2 tx_last_3_months = vc
    2 prev_tx_reaction = vc
    2 red_cell_antibodies = vc
    2 signed_dt = vc
    2 specimen_type = vc
    2 status = vc
    2 accession = vc
    2 container_id = vc
    2 conversation_id = f8
    2 catalog = vc
    2 catalog_type_cd = f8
    2 activity = vc
    2 activity_type_cd = f8
    2 activity_subtype_cd = f8
    2 activity_subtype_mean = vc
    2 last_action_seq = i4
    2 enter_by = vc
    2 order_dr = vc
    2 order_docnbr = vc
    2 copy_to = vc
    2 clin_hist = vc
    2 type = vc
    2 action = vc
    2 action_type_cd = f8
    2 display_line_size = vc
    2 comment_ind = i2
    2 comment = vc
    2 com_ln_cnt = i2
    2 com_ln_qual [*]
      3 com_line = vc
    2 oe_format_id = f8
    2 clin_line_ind = i2
    2 stat_ind = i2
    2 d_cnt = i2
    2 d_qual [*]
      3 field_description = vc
      3 label_text = vc
      3 value = vc
      3 field_value = f8
      3 oe_field_meaning_id = f8
      3 group_seq = i4
      3 print_ind = i2
      3 clin_line_ind = i2
      3 label = vc
      3 suffix = i2
      3 accept_ind = i2
      3 oe_field_meaning = vc
    2 priority = vc
    2 req_st_dt = vc
    2 req_st_dt_tm = dq8
    2 frequency = vc
    2 rate = vc
    2 duration = vc
    2 duration_unit = vc
    2 nurse_collect = vc
    2 fmt_action_cd = f8
)


;**************************************************************
; DVDev DECLARED SUBROUTINES
;**************************************************************

declare _CreateFonts(dummy) = null with Protect
declare _CreatePens(dummy) = null with Protect
declare _CreateRTF(dummy) = null with Protect
declare Query1(dummy) = null with Protect
declare PageBreak(dummy) = null with Protect
declare FinalizeReport(sSendReport=vc) = null with Protect
declare OrgsetHeader(nCalc=i2) = f8 with Protect
declare OrgsetHeaderABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare OrganizationHeader(nCalc=i2) = f8 with Protect
declare OrganizationHeaderABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare PatientHeader(nCalc=i2) = f8 with Protect
declare PatientHeaderABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare ClinHistSection(nCalc=i2,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare ClinHistSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare CopyResultsSec(nCalc=i2,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare CopyResultsSecABS(nCalc=i2,OffsetX=f8,OffsetY=f8,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare OrderHeaderSection(nCalc=i2) = f8 with Protect
declare OrderHeaderSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare AccessionRepeatHeader(nCalc=i2,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare AccessionRepeatHeaderABS(nCalc=i2,OffsetX=f8,OffsetY=f8,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare AccessHead_sortSection(nCalc=i2,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare AccessHead_sortSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare OrderSectionTemp(nCalc=i2) = f8 with Protect
declare OrderSectionTempABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare OrderSection(nCalc=i2,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare OrderSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8,maxHeight=f8,bContinue=i2(Ref)) = f8 with Protect
declare WarningSection(nCalc=i2) = f8 with Protect
declare WarningSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare Footacc_sortSection(nCalc=i2) = f8 with Protect
declare Footacc_sortSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare NoBBContinueSection(nCalc=i2) = f8 with Protect
declare NoBBContinueSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare ContinueSection(nCalc=i2) = f8 with Protect
declare ContinueSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare CollectorStatement(nCalc=i2) = f8 with Protect
declare CollectorStatementABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare CollectionDetailsSection(nCalc=i2) = f8 with Protect
declare CollectionDetailsSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare LabUseOnlySection(nCalc=i2) = f8 with Protect
declare LabUseOnlySectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare EDTASection(nCalc=i2) = f8 with Protect
declare EDTASectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare BillingStatusSection(nCalc=i2) = f8 with Protect
declare BillingStatusSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare AssignmentFormSection(nCalc=i2) = f8 with Protect
declare AssignmentFormSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare PrivacyNoteSection(nCalc=i2) = f8 with Protect
declare PrivacyNoteSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare FootPageSection(nCalc=i2) = f8 with Protect
declare FootPageSectionABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare OrderBox(nCalc=i2) = f8 with Protect
declare OrderBoxABS(nCalc=i2,OffsetX=f8,OffsetY=f8) = f8 with Protect
declare _LoadImages(dummy) = null with Protect
declare InitializeReport(dummy) = null with Protect

;**************************************************************
; DVDev DECLARED VARIABLES
;**************************************************************

declare _hReport = H with NoConstant(0),protect
declare _YOffset = f8 with NoConstant(0.0),protect
declare _XOffset = f8 with NoConstant(0.0),protect
declare Rpt_Render = i2 with Constant(0),protect
declare _CRLF = vc with Constant(concat(char(13),char(10))),protect
declare RPT_CalcHeight = i2 with Constant(1),protect
declare _YShift = f8 with NoConstant(0.0),protect
declare _XShift = f8 with NoConstant(0.0),protect
declare _SendTo = vc with NoConstant($OutDev),protect
declare _rptErr = i2 with NoConstant(0),protect
declare _rptStat = i2 with NoConstant(0),protect
declare _oldFont = i4 with NoConstant(0),protect
declare _oldPen = i4 with NoConstant(0),protect
declare _dummyFont = i4 with NoConstant(0),protect
declare _dummyPen = i4 with NoConstant(0),protect
declare _fDrawHeight = f8 with NoConstant(0.0),protect
declare _rptPage = H with NoConstant(0),protect
declare _DIOTYPE = i2 with NoConstant(8),protect
declare _OutputType = i2 with noConstant(RPT_PostScript),protect
declare _RemclinHist = i4 with NoConstant(1),protect
declare _bHoldContinue = i2 with NoConstant(0),protect
declare _bContClinHistSection = i2 with NoConstant(0),protect
declare _RemptAlerts = i4 with NoConstant(1),protect
declare _bContCopyResultsSec = i2 with NoConstant(0),protect
declare _RemAccessionFormatted = i4 with NoConstant(1),protect
declare _bContAccessionRepeatHeader = i2 with NoConstant(0),protect
declare _RemAccessionFormatted = i4 with NoConstant(1),protect
declare _bContAccessHead_sortSection = i2 with NoConstant(0),protect
declare _RemordMnemonic = i4 with NoConstant(1),protect
declare _RemFieldName0 = i4 with NoConstant(1),protect
declare _bContOrderSection = i2 with NoConstant(0),protect
declare _hRTF_ordMnemonic = i4 with NoConstant(0),protect
declare _hRTF_FieldName0 = i4 with NoConstant(0),protect
declare _Helvetica90 = i4 with NoConstant(0),protect
declare _Helvetica14B0 = i4 with NoConstant(0),protect
declare _Helvetica12B0 = i4 with NoConstant(0),protect
declare _Times416777215 = i4 with NoConstant(0),protect
declare _Helvetica16B16777215 = i4 with NoConstant(0),protect
declare _Times100 = i4 with NoConstant(0),protect
declare _Helvetica6U0 = i4 with NoConstant(0),protect
declare _Helvetica6B0 = i4 with NoConstant(0),protect
declare _Helvetica100 = i4 with NoConstant(0),protect
declare _Helvetica60 = i4 with NoConstant(0),protect
declare _Helvetica8B255 = i4 with NoConstant(0),protect
declare _Helvetica9B0 = i4 with NoConstant(0),protect
declare _Helvetica8B0 = i4 with NoConstant(0),protect
declare _Helvetica9B16777215 = i4 with NoConstant(0),protect
declare _Helvetica80 = i4 with NoConstant(0),protect
declare _pen13S0C0 = i4 with NoConstant(0),protect
declare _pen14S0C0 = i4 with NoConstant(0),protect
declare _hImage1 = H with NoConstant(0),protect
subroutine _LoadImages(dummy)
set _hImage1 = uar_rptInitImageFromFile(_hReport,RPT_JPEG,"cust_script:whpathlg.jpg")
end;**************Load Images*************


;**************************************************************
; DVDev DEFINED SUBROUTINES
;**************************************************************

subroutine Query1(dummy)
SELECT INTO "NL:"
	acc_sort = orders->qual[d.seq].container_id
	, sort_thingy = orders->qual[d.seq].sort_order_id

FROM
	(DUMMYT   D  WITH seq = size(orders->qual,5))

PLAN D
	where orders->qual[d.seq].page_break_id = page_break_cnt

ORDER BY
	acc_sort
	, sort_thingy



Head Report
	_d0 = d.seq
; set bottom extent of page
_fEndDetail = RptReport->m_pageHeight-RptReport->m_marginBottom
_fEndDetail = _fEndDetail-NoBBContinueSection(RPT_CALCHEIGHT)
_fEndDetail = _fEndDetail-ContinueSection(RPT_CALCHEIGHT)
_fEndDetail = _fEndDetail-CollectorStatement(RPT_CALCHEIGHT)
_fEndDetail = _fEndDetail-CollectionDetailsSection(RPT_CALCHEIGHT)
_fEndDetail = _fEndDetail-LabUseOnlySection(RPT_CALCHEIGHT)
_fEndDetail = _fEndDetail-EDTASection(RPT_CALCHEIGHT)
_fEndDetail = _fEndDetail-BillingStatusSection(RPT_CALCHEIGHT)
_fEndDetail = _fEndDetail-AssignmentFormSection(RPT_CALCHEIGHT)
_fEndDetail = _fEndDetail-PrivacyNoteSection(RPT_CALCHEIGHT)
_fEndDetail = _fEndDetail-FootPageSection(RPT_CALCHEIGHT)


/****** YOUR CODE BEGINS HERE ******/
printedDtTm = concat("Printed Date/Time: ",format(cnvtdatetime(curdate,curtime),"dd/mm/yyyy hh:mm;;d"))
call echo(build("page_break_cnt=",page_break_cnt))
/*_fEndDetail = 8.39*/
/*_fEndDetail = 7.38 */
_fEndDetail = 8.39
total_order_cnt = 0
accession_rpt_cnt=0
/*----- YOUR CODE ENDS HERE -----*/



Head Page
if (curpage > 1)
	dummy_val = PageBreak(0)
endif

/****** YOUR CODE BEGINS HERE ******/
order_cnt = 0
TEST_CONT_IND = 0
/*----- YOUR CODE ENDS HERE -----*/


dummy_val = OrgsetHeader(RPT_RENDER)
dummy_val = OrganizationHeader(RPT_RENDER)
dummy_val = PatientHeader(RPT_RENDER)

/****** YOUR CODE BEGINS HERE ******/
for (altIdx = 1 to size(alerts->qual,5))
  if (altIdx = 1)
    ptAlerts = trim(alerts->qual[altIdx].alert_disp ,3)
  else
    ptAlerts = concat(ptAlerts,", ",trim(alerts->qual[altIdx].alert_disp ,3))
  endif
endfor
order_cnt = 0
/*----- YOUR CODE ENDS HERE -----*/


_bContClinHistSection = 0; initialize continue flag for page row
dummy_val = ClinHistSection(RPT_RENDER,RptReport->m_pageHeight-RptReport->m_marginBottom-_YOffset,_bContClinHistSection)
_bContCopyResultsSec = 0; initialize continue flag for page row
dummy_val = CopyResultsSec(RPT_RENDER,RptReport->m_pageHeight-RptReport->m_marginBottom-_YOffset,_bContCopyResultsSec)
dummy_val = OrderBoxABS(RPT_RENDER,_XOffset,3.000)
dummy_val = OrderHeaderSection(RPT_RENDER)
_bContAccessionRepeatHeader = 0; initialize continue flag for page row
dummy_val = AccessionRepeatHeader(RPT_RENDER,RptReport->m_pageHeight-RptReport->m_marginBottom-_YOffset,
_bContAccessionRepeatHeader)

Head acc_sort

/****** YOUR CODE BEGINS HERE ******/
if(orders->qual[d.seq].bloodbank_req = 1)
	_fEndDetail = 7.79
else
	_fEndDetail = 8.29
endif

if (_YOffset + (cnvtreal(orders->QUAL[d.seq].DISP_LN_CNT)*0.125) > _fEndDetail)
	break
endif
/*----- YOUR CODE ENDS HERE -----*/


_bContAccessHead_sortSection = 0
; begin grow loop
bFirstTime = 1
while (_bContAccessHead_sortSection=1 OR bFirstTime=1)

; calculate section height
_bHoldContinue = _bContAccessHead_sortSection
_fDrawHeight = AccessHead_sortSection(RPT_CALCHEIGHT,_fEndDetail-_YOffset,_bHoldContinue)

; break if bottom of page exceeded
if (_YOffset+_fDrawHeight>_fEndDetail)
	break
; keep section if doesn't fit (one time only)
elseif (_bHoldContinue=1 AND _bContAccessHead_sortSection = 0)
	break
endif

dummy_val = AccessHead_sortSection(RPT_RENDER,_fEndDetail-_YOffset,_bContAccessHead_sortSection)
bFirstTime = 0
endwhile

/****** YOUR CODE BEGINS HERE ******/
if(accession_rpt_cnt <= 0)
	accession_rpt_cnt = 1
endif
/*----- YOUR CODE ENDS HERE -----*/



Head sort_thingy
	row+0

Detail

/****** YOUR CODE BEGINS HERE ******/
/*if((d.seq > 1 and orders->qual[d.seq].activity_subtype_cd != orders->qual[d.seq-1].activity_subtype_cd)
	or orders->qual[d.seq].activity_subtype_cd = BLOODBANK_CD)
   break
endif
if (_YOffset > 6.0)
	break
endif
*/
if (_YOffset + (cnvtreal(orders->QUAL[d.seq].DISP_LN_CNT)*0.125) > _fEndDetail)

	break

endif
/*----- YOUR CODE ENDS HERE -----*/



/****** YOUR CODE BEGINS HERE ******/
;dob_wks = datetimediff(cnvtdatetime(curdate,curtime),orders->dob_dt,2)
/*----- YOUR CODE ENDS HERE -----*/


; calculate section height
_fDrawHeight = OrderSectionTemp(RPT_CALCHEIGHT)
; break if bottom of page exceeded
if (_YOffset+_fDrawHeight>_fEndDetail)
	break
endif

dummy_val = OrderSectionTemp(RPT_RENDER)
_bContOrderSection = 0
; begin grow loop
bFirstTime = 1
while (_bContOrderSection=1 OR bFirstTime=1)

; calculate section height
_bHoldContinue = _bContOrderSection
_fDrawHeight = OrderSection(RPT_CALCHEIGHT,_fEndDetail-_YOffset,_bHoldContinue)

; break if bottom of page exceeded
if (_YOffset+_fDrawHeight>_fEndDetail)
	break
endif

dummy_val = OrderSection(RPT_RENDER,_fEndDetail-_YOffset,_bContOrderSection)
bFirstTime = 0
endwhile

/****** YOUR CODE BEGINS HERE ******/
order_cnt = (order_cnt + 1)
total_order_cnt = (total_order_cnt + 1)
call echo("ENTERING FOOT PAGE SECTION")
call echo(build("check order_cnt = ",order_cnt))
call echo(build("check order->cnt=",orders->CNT))
if (total_order_cnt < orders->cnt)
	TEST_CONT_IND = 1
	call echo("need continue line")
elseif (total_order_cnt = orders->cnt)
	TEST_CONT_IND = 0
	call echo("turning off continue")
endif
/*----- YOUR CODE ENDS HERE -----*/


; calculate section height
_fDrawHeight = WarningSection(RPT_CALCHEIGHT)
; break if bottom of page exceeded
if (_YOffset+_fDrawHeight>_fEndDetail)
	break
endif

dummy_val = WarningSection(RPT_RENDER)

Foot sort_thingy
	row+0

Foot acc_sort

/****** YOUR CODE BEGINS HERE ******/

accession_rpt_cnt=0
/*----- YOUR CODE ENDS HERE -----*/


; calculate section height
_fDrawHeight = Footacc_sortSection(RPT_CALCHEIGHT)
; break if bottom of page exceeded
if (_YOffset+_fDrawHeight>_fEndDetail)
	break
endif

dummy_val = Footacc_sortSection(RPT_RENDER)

Foot Page
_YHold = _YOffset
_YOffset = _fEndDetail
dummy_val = NoBBContinueSection(RPT_RENDER)
dummy_val = ContinueSection(RPT_RENDER)
dummy_val = CollectorStatement(RPT_RENDER)
dummy_val = CollectionDetailsSection(RPT_RENDER)
dummy_val = LabUseOnlySection(RPT_RENDER)
dummy_val = EDTASection(RPT_RENDER)
dummy_val = BillingStatusSection(RPT_RENDER)
dummy_val = AssignmentFormSection(RPT_RENDER)
dummy_val = PrivacyNoteSection(RPT_RENDER)
dummy_val = FootPageSection(RPT_RENDER)
_YOffset = _YHold
WITH NOCOUNTER, SEPARATOR=" ", FORMAT


end ;LayoutQuery
subroutine PageBreak(dummy)
set _rptPage = uar_rptEndPage(_hReport)
set _rptPage = uar_rptStartPage(_hReport)
set _YOffset = RptReport->m_marginTop
end ; PageBreak

subroutine FinalizeReport(sSendReport)
set _rptPage = uar_rptEndPage(_hReport)
set _rptStat = uar_rptEndReport(_hReport)
declare sFilename = vc with NoConstant(trim(sSendReport)),private
declare bPrint = i2 with NoConstant(0),private
if(textlen(sFilename)>0)
set bPrint = CheckQueue(sFilename)
  if(bPrint)
    execute cpm_create_file_name "RPT","PS"
    set sFilename = cpm_cfn_info->file_name_path
  endif
endif
set _rptStat = uar_rptPrintToFile(_hReport,nullterm(sFileName))
if(bPrint)
  set spool value(sFilename) value(sSendReport) with deleted,DIO=value(_DIOTYPE)
endif
declare _errorFound = i2 with noConstant(0),protect
declare _errCnt = i2 with noConstant(0),protect
set _errorFound = uar_RptFirstError( _hReport , RptError )
while ( _errorFound = RPT_ErrorFound and _errCnt < 512 )
   set _errCnt = _errCnt+1
   set stat = AlterList(RptErrors->Errors,_errCnt)
set RptErrors->Errors[_errCnt].m_severity = RptError->m_severity
     set RptErrors->Errors[_errCnt].m_text =  RptError->m_text
     set RptErrors->Errors[_errCnt].m_source = RptError->m_source
   set _errorFound = uar_RptNextError( _hReport , RptError )
endwhile
set _rptStat = uar_rptDestroyReport(_hReport)
end ; FinalizeReport

subroutine OrgsetHeader(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(OrgsetHeaderABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine OrgsetHeader(nCalc)

subroutine OrgsetHeaderABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(1.060000), private
declare __BING_LOC = vc with NoConstant(build2(bing->appt_loc,char(0))),protect
declare __BING_REF_URN = vc with NoConstant(build2(bing->Ref_urn,char(0))),protect
if (nCalc = RPT_RENDER)
; DRAW IMAGE --- Logo
set _rptStat = uar_rptImageDraw( _hReport,_hImage1, OffsetX+0.000,OffsetY+ 0.000, 6.813, 1.063, 1)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LINE --- TopBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+1.063)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+1.063)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 5.063
set RptSD->m_width = 1.500
set RptSD->m_height = 0.073
set _oldFont = uar_rptSetFont(_hReport, _Times416777215)
; DRAW LABEL --- Bing_hosp_address
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Department: Women's & Children's Specialist Clinics",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.126
set RptSD->m_x = OffsetX + 5.063
set RptSD->m_width = 1.500
set RptSD->m_height = 0.073
; DRAW LABEL --- Bing_email
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Email: whs-dhpasteam@wh.org.au",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.063
set RptSD->m_x = OffsetX + 5.063
set RptSD->m_width = 1.500
set RptSD->m_height = 0.073
; DRAW TEXT --- Bing_loc
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __BING_LOC)
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.198
set RptSD->m_x = OffsetX + 5.063
set RptSD->m_width = 1.500
set RptSD->m_height = 0.073
; DRAW TEXT --- Bing_Ref_urn
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __BING_REF_URN)
; DRAW RECTANGLE --- FieldName1
set _rptStat = uar_rptRect ( _hReport, OffsetX+1.626, OffsetY+0.375, 5.813, 0.604, RPT_FILL, RPT_WHITE)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.376
set RptSD->m_x = OffsetX + 1.688
set RptSD->m_width = 2.688
set RptSD->m_height = 0.167
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica80)
; DRAW LABEL --- Bacchus
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Bacchus Marsh Hospital - Grant St, Bacchus Marsh",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.500
set RptSD->m_x = OffsetX + 1.688
set RptSD->m_width = 2.688
set RptSD->m_height = 0.167
; DRAW LABEL --- Melton
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Melton Hub - Barries Road, Melton West",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.625
set RptSD->m_x = OffsetX + 1.688
set RptSD->m_width = 2.688
set RptSD->m_height = 0.167
; DRAW LABEL --- Sunbury
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Sunbury Hospital - Macedon St, Sunbury",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.376
set RptSD->m_x = OffsetX + 4.500
set RptSD->m_width = 2.688
set RptSD->m_height = 0.167
; DRAW LABEL --- Footscray
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Footscray Hospital - Gordon St, Footscray",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.500
set RptSD->m_x = OffsetX + 4.500
set RptSD->m_width = 2.688
set RptSD->m_height = 0.167
; DRAW LABEL --- Sunshine
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Sunshine Hospital - Furlong Road, St Albans",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.625
set RptSD->m_x = OffsetX + 4.500
set RptSD->m_width = 2.938
set RptSD->m_height = 0.167
; DRAW LABEL --- Williamstown
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Williamstown Hospital - Railway Crescent, Williamstown",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.813
set RptSD->m_x = OffsetX + 1.688
set RptSD->m_width = 2.688
set RptSD->m_height = 0.167
; DRAW LABEL --- Switchboard
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Western Health Switchboard: (03) 8345 6666",char(0)))
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine OrgsetHeaderABS(nCalc,OffsetX,OffsetY)

subroutine OrganizationHeader(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(OrganizationHeaderABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine OrganizationHeader(nCalc)

subroutine OrganizationHeaderABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.400000), private
declare __SRVADDRESS = vc with NoConstant(build2(orders->hospital_addr,char(0))),protect
declare __SVCPROVIDER = vc with NoConstant(build2(orders->service_prov,char(0))),protect
declare __ORGNAME = vc with NoConstant(build2(orders->hospital_name,char(0))),protect
if (nCalc = RPT_RENDER)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.126
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.563
set RptSD->m_height = 0.198
set _oldFont = uar_rptSetFont(_hReport, _Helvetica8B0)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LABEL --- orgAddressLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Address:",char(0)))
; DRAW LINE --- TopBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.448)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.448)
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.126
set RptSD->m_x = OffsetX + 0.750
set RptSD->m_width = 3.063
set RptSD->m_height = 0.146
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica80)
; DRAW TEXT --- srvAddress
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __SRVADDRESS)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.251
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.750
set RptSD->m_height = 0.157
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- svcProviderLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Pathology:",char(0)))
set RptSD->m_flags = 32
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.251
set RptSD->m_x = OffsetX + 0.750
set RptSD->m_width = 3.126
set RptSD->m_height = 0.157
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- svcProvider
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __SVCPROVIDER)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.563
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- orgNameLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Hospital:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.750
set RptSD->m_width = 3.126
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- OrgName
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __ORGNAME)
set RptSD->m_flags = 68
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 6.375
set RptSD->m_width = 1.094
set RptSD->m_height = 0.261
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica12B0)

/****** YOUR CODE BEGINS HERE ******/
if (orders->reprint_ind = 1)
; DRAW LABEL --- __Reprint___
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("**Reprint**",char(0)))
endif
/*----- YOUR CODE ENDS HERE -----*/

set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDLEFTBORDER
set RptSD->m_paddingWidth = 0.100
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 3.875
set RptSD->m_width = 2.751
set RptSD->m_height = 0.313
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica16B16777215)
set oldBackColor = uar_RptSetBackColor(_hReport,RPT_BLACK)

/****** YOUR CODE BEGINS HERE ******/
if (orders->qual[d.seq].bloodbank_req = 1)
; DRAW LABEL --- FieldName4
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("BLOOD BANK REQUEST",char(0)))
endif
/*----- YOUR CODE ENDS HERE -----*/

set oldBackColor = uar_RptResetBackColor(_hReport)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine OrganizationHeaderABS(nCalc,OffsetX,OffsetY)

subroutine PatientHeader(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(PatientHeaderABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine PatientHeader(nCalc)

subroutine PatientHeaderABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(1.290000), private
declare __PTFIN = vc with NoConstant(build2(ORDERS->FNBR,char(0))),protect
declare __PTMRN = vc with NoConstant(build2(ORDERS->MRN,char(0))),protect
declare __PTNAME = vc with NoConstant(build2(ORDERS->NAME,char(0))),protect
declare __PTDOB = vc with NoConstant(build2(ORDERS->DOB,char(0))),protect
declare __PTAGE = vc with NoConstant(build2(ORDERS->AGE,char(0))),protect
declare __PTSEX = vc with NoConstant(build2(ORDERS->SEX,char(0))),protect
declare __PTLOC = vc with NoConstant(build2(ORDERS->LOCATION,char(0))),protect
declare __PTSSN = vc with NoConstant(build2(orders->ssn,char(0))),protect
declare __PTCONCESSNBR = vc with NoConstant(build2(orders->concess_nbr,char(0))),protect
declare __ORDERDR = vc with NoConstant(build2(orders->qual[1].order_dr,char(0))),protect
declare __ORDDOCNBR = vc with NoConstant(build2(orders->qual[1].order_docnbr,char(0))),protect
declare __FASTING = vc with NoConstant(build2(orders->fasting,char(0))),protect
declare __REQ_ST_DT = vc with NoConstant(build2(orders->req_st_dt,char(0))),protect
if ((orders->health_plan > " ") and ( orders->health_plan_nbr > " "))
declare __HEALTHNUMBER = vc with NoConstant(build2(concat(orders->health_plan," - ",orders->health_plan_nbr),char(0))),protect
endif
declare __PAT_ADDR = vc with NoConstant(build2(orders->pat_addr,char(0))),protect
declare __ESIGN = vc with NoConstant(build2(orders->qual[1].order_dr,char(0))),protect
declare __FINCLASS = vc with NoConstant(build2(orders->fin_class,char(0))),protect
if (nCalc = RPT_RENDER)
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.063
set RptSD->m_x = OffsetX + 0.625
set RptSD->m_width = 1.375
set RptSD->m_height = 0.188
set _oldFont = uar_rptSetFont(_hReport, _Helvetica90)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW TEXT --- ptFin
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PTFIN)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.063
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.625
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- VisitNoLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Visit No:",char(0)))
; DRAW LINE --- TopBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+1.271)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+1.271)
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.063
set RptSD->m_x = OffsetX + 2.938
set RptSD->m_width = 0.500
set RptSD->m_height = 0.188
; DRAW LABEL --- URNoLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("UR No:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.063
set RptSD->m_x = OffsetX + 3.438
set RptSD->m_width = 1.438
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ptMrn
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PTMRN)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.188
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.563
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- patientLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Patient:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.188
set RptSD->m_x = OffsetX + 0.625
set RptSD->m_width = 4.500
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ptName
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PTNAME)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.500
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- FieldName20
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("DOB:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 0.438
set RptSD->m_width = 1.198
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ptDob
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PTDOB)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 1.313
set RptSD->m_width = 0.376
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- AgeLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Age:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 1.626
set RptSD->m_width = 0.688
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ptAge
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PTAGE)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 2.251
set RptSD->m_width = 0.313
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- sexLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Sex:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 2.563
set RptSD->m_width = 0.376
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ptSex
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PTSEX)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 2.938
set RptSD->m_width = 0.625
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- locationLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Location:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 3.563
set RptSD->m_width = 1.625
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ptLoc
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PTLOC)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.625
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.938
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- medicarenoLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Medicare No:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.625
set RptSD->m_x = OffsetX + 0.875
set RptSD->m_width = 1.813
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ptSsn
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PTSSN)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.625
set RptSD->m_x = OffsetX + 3.875
set RptSD->m_width = 0.625
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- DVANoLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("DVA No:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.625
set RptSD->m_x = OffsetX + 4.438
set RptSD->m_width = 2.126
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ptConcessNbr
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PTCONCESSNBR)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.750
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 1.375
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- ReqDocLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Requesting Provider:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.750
set RptSD->m_x = OffsetX + 1.375
set RptSD->m_width = 2.501
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- orderDr
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __ORDERDR)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.750
set RptSD->m_x = OffsetX + 3.875
set RptSD->m_width = 0.813
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- HealthFundLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Health Fund:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.875
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.813
set RptSD->m_height = 0.188
; DRAW LABEL --- providerNoLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Provider No:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.875
set RptSD->m_x = OffsetX + 0.875
set RptSD->m_width = 2.001
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ordDocNbr
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __ORDDOCNBR)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.875
set RptSD->m_x = OffsetX + 3.875
set RptSD->m_width = 1.875
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- RequestDtTmLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Request Due to be Performed:",char(0)))
set RptSD->m_flags = 1028
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 1.125
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 1.250
set RptSD->m_height = 0.157
; DRAW LABEL --- ClinicalInfoLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Clinical Information:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 1.125
set RptSD->m_x = OffsetX + 3.875
set RptSD->m_width = 0.500
set RptSD->m_height = 0.157
; DRAW LABEL --- FastingLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Fasting:",char(0)))
set _DummyPen = uar_rptSetPen(_hReport,_pen13S0C0)
; DRAW BAR CODE --- AccessionBC
set _rptDummy = uar_rptBarCodeInit(RptBCE,RPT_CODE128,OffsetX+5.250,OffsetY+0.063)
set RptBCE->m_barCodeType = RPT_CODE128
set RptBCE->m_ecc = 1
set RptBCE->m_recSize = 90
set RptBCE->m_width = 2.06
set RptBCE->m_height = 0.44
set RptBCE->m_rotation = 0
set RptBCE->m_ratio = 250
set RptBCE->m_barWidth = 1
set RptBCE->m_bPrintInterp = 0
set _rptStat = uar_rptBarCodeEx(_hReport,RPTBCE,build2(build("*",ORDERS->MRN,"*"),char(0)))
set RptSD->m_flags = 1024
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 1.136
set RptSD->m_x = OffsetX + 4.375
set RptSD->m_width = 0.938
set RptSD->m_height = 0.157
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
set _DummyPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW TEXT --- fasting
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __FASTING)
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.875
set RptSD->m_x = OffsetX + 5.750
set RptSD->m_width = 1.125
set RptSD->m_height = 0.188
; DRAW TEXT --- req_st_dt
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __REQ_ST_DT)
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.750
set RptSD->m_x = OffsetX + 4.625
set RptSD->m_width = 2.563
set RptSD->m_height = 0.188

/****** YOUR CODE BEGINS HERE ******/
if ((orders->health_plan > " ") and ( orders->health_plan_nbr > " "))
; DRAW TEXT --- HealthNumber
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __HEALTHNUMBER)
endif
/*----- YOUR CODE ENDS HERE -----*/

set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.500
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.625
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- FieldName0
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Address:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.500
set RptSD->m_x = OffsetX + 0.625
set RptSD->m_width = 6.688
set RptSD->m_height = 0.167
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- pat_addr
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __PAT_ADDR)
set RptSD->m_flags = 1028
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 1.000
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 1.625
set RptSD->m_height = 0.157
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- EsignLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Electronically signed by:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 1.000
set RptSD->m_x = OffsetX + 1.563
set RptSD->m_width = 2.251
set RptSD->m_height = 0.167
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- ESign
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __ESIGN)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 1.000
set RptSD->m_x = OffsetX + 3.875
set RptSD->m_width = 1.000
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
; DRAW LABEL --- FinClassLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Account Class:",char(0)))
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 1.000
set RptSD->m_x = OffsetX + 4.813
set RptSD->m_width = 2.438
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW TEXT --- FinClass
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __FINCLASS)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine PatientHeaderABS(nCalc,OffsetX,OffsetY)

subroutine ClinHistSection(nCalc,maxHeight,bContinue)
declare a1=f8 with noconstant(0.0),private
set a1=(ClinHistSectionABS(nCalc,_XOffset,_YOffset,maxHeight,bContinue))
return (a1)
end ;subroutine ClinHistSection(nCalc,maxHeight,bContinue)

subroutine ClinHistSectionABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)
declare sectionHeight = f8 with noconstant(0.250000), private
declare growSum = i4 with noconstant(0), private
declare drawHeight_clinHist = f8 with noconstant(0.0), private
declare __CLINHIST = vc with NoConstant(build2(ORDERS->PAGE_BREAK [page_break_cnt].CLIN_HIST,char(0))),protect
if (bContinue=0)
	set _RemclinHist = 1
endif
set RptSD->m_flags = 5
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
if (bContinue)
	set RptSD->m_y = OffsetY
else
	set RptSD->m_y = OffsetY + 0.001
endif
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 7.375
set RptSD->m_height = OffsetY+maxHeight-RptSD->m_y
set _oldFont = uar_rptSetFont(_hReport, _Helvetica90)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
set _HoldRemclinHist = _RemclinHist
if (_RemclinHist > 0)
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, nullterm(substring(_RemclinHist,size(__CLINHIST)-_RemclinHist+1,__CLINHIST))
)
set drawHeight_clinHist = RptSD->m_height
if (RptSD->m_height > OffsetY + sectionHeight - RptSD->m_y)
	set sectionHeight = RptSD->m_y + _fDrawHeight - OffsetY
endif
if (RptSD->m_drawLength = 0)
	set _RemclinHist = 0
elseif (RptSD->m_drawLength < size(nullterm(substring(_RemclinHist,size(__CLINHIST)-_RemclinHist+1,__CLINHIST)))) ; subtract null
	set _RemclinHist = _RemclinHist+RptSD->m_drawLength
else
	set _RemclinHist = 0
endif
	; append remainder to growSum so we know whether or not to continue at the end
	set growSum = growSum + _RemclinHist
endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
if (bContinue)
	set RptSD->m_y = OffsetY
else
	set RptSD->m_y = OffsetY + 0.001
endif
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 7.375
set RptSD->m_height = drawHeight_clinHist
if (nCalc = RPT_RENDER AND _HoldRemclinHist > 0)
; DRAW TEXT --- clinHist
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, nullterm(substring(_HoldRemclinHist,size(__CLINHIST)-_HoldRemclinHist+1,
__CLINHIST)))
else
	set _RemclinHist = _HoldRemclinHist
endif
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.250)
endif
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.250)
endif
if (nCalc = RPT_RENDER)
	set _YOffset = OffsetY + sectionHeight
endif
	if (growSum > 0)
		set bContinue = 1 ; continue grow
	else
		set bContinue = 0 ; done growing
	endif
return(sectionHeight)
end ;subroutine ClinHistSectionABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)

subroutine CopyResultsSec(nCalc,maxHeight,bContinue)
declare a1=f8 with noconstant(0.0),private
set a1=(CopyResultsSecABS(nCalc,_XOffset,_YOffset,maxHeight,bContinue))
return (a1)
end ;subroutine CopyResultsSec(nCalc,maxHeight,bContinue)

subroutine CopyResultsSecABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)
declare sectionHeight = f8 with noconstant(0.190000), private
declare growSum = i4 with noconstant(0), private
declare drawHeight_ptAlerts = f8 with noconstant(0.0), private
declare __PTALERTS = vc with NoConstant(build2(orders->copy_to,char(0))),protect
if (bContinue=0)
	set _RemptAlerts = 1
endif
set RptSD->m_flags = 5
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
if (bContinue)
	set RptSD->m_y = OffsetY
else
	set RptSD->m_y = OffsetY + 0.001
endif
set RptSD->m_x = OffsetX + 1.125
set RptSD->m_width = 6.375
set RptSD->m_height = OffsetY+maxHeight-RptSD->m_y
set _oldFont = uar_rptSetFont(_hReport, _Helvetica90)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
set _HoldRemptAlerts = _RemptAlerts
if (_RemptAlerts > 0)
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, nullterm(substring(_RemptAlerts,size(__PTALERTS)-_RemptAlerts+1,__PTALERTS))
)
set drawHeight_ptAlerts = RptSD->m_height
if (RptSD->m_height > OffsetY + sectionHeight - RptSD->m_y)
	set sectionHeight = RptSD->m_y + _fDrawHeight - OffsetY
endif
if (RptSD->m_drawLength = 0)
	set _RemptAlerts = 0
elseif (RptSD->m_drawLength < size(nullterm(substring(_RemptAlerts,size(__PTALERTS)-_RemptAlerts+1,__PTALERTS)))) ; subtract null
	set _RemptAlerts = _RemptAlerts+RptSD->m_drawLength
else
	set _RemptAlerts = 0
endif
	; append remainder to growSum so we know whether or not to continue at the end
	set growSum = growSum + _RemptAlerts
endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 1.063
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LABEL --- CopyResultsToLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Copy Results to:",char(0)))
endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
if (bContinue)
	set RptSD->m_y = OffsetY
else
	set RptSD->m_y = OffsetY + 0.001
endif
set RptSD->m_x = OffsetX + 1.125
set RptSD->m_width = 6.375
set RptSD->m_height = drawHeight_ptAlerts
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
if (nCalc = RPT_RENDER AND _HoldRemptAlerts > 0)
; DRAW TEXT --- ptAlerts
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, nullterm(substring(_HoldRemptAlerts,size(__PTALERTS)-_HoldRemptAlerts+1,
__PTALERTS)))
else
	set _RemptAlerts = _HoldRemptAlerts
endif
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.250)
endif
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.250)
endif
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LINE --- TopBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
endif
if (nCalc = RPT_RENDER)
	set _YOffset = OffsetY + sectionHeight
endif
	if (growSum > 0)
		set bContinue = 1 ; continue grow
	else
		set bContinue = 0 ; done growing
	endif
return(sectionHeight)
end ;subroutine CopyResultsSecABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)

subroutine OrderHeaderSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(OrderHeaderSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine OrderHeaderSection(nCalc)

subroutine OrderHeaderSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.060000), private
if (nCalc = RPT_RENDER)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LINE --- TopBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
; DRAW LINE --- LeftBorder0
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.250)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.250)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine OrderHeaderSectionABS(nCalc,OffsetX,OffsetY)

subroutine AccessionRepeatHeader(nCalc,maxHeight,bContinue)
declare a1=f8 with noconstant(0.0),private
set a1=(AccessionRepeatHeaderABS(nCalc,_XOffset,_YOffset,maxHeight,bContinue))
return (a1)
end ;subroutine AccessionRepeatHeader(nCalc,maxHeight,bContinue)

subroutine AccessionRepeatHeaderABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)
declare sectionHeight = f8 with noconstant(0.570000), private
declare growSum = i4 with noconstant(0), private
declare drawHeight_AccessionFormatted = f8 with noconstant(0.0), private
declare __ACCESSIONFORMATTED = vc with NoConstant(build2(trim(ORDERS->QUAL [d.seq].CONTAINER_ID),char(0))),protect

/****** YOUR CODE BEGINS HERE ******/
if (NOT((orders->qual [d.seq].container_id != "00-00-000-0000A") and (accession_rpt_cnt > 0) and (curpage > 1)))
   return (0.0)
endif
/*----- YOUR CODE ENDS HERE -----*/

if (bContinue=0)
	set _RemAccessionFormatted = 1
endif
set RptSD->m_flags = 5
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
if (bContinue)
	set RptSD->m_y = OffsetY
else
	set RptSD->m_y = OffsetY + 0.417
endif
set RptSD->m_x = OffsetX + 0.188
set RptSD->m_width = 1.500
set RptSD->m_height = OffsetY+maxHeight-RptSD->m_y
set _oldFont = uar_rptSetFont(_hReport, _Helvetica90)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
set _HoldRemAccessionFormatted = _RemAccessionFormatted
if (_RemAccessionFormatted > 0)
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, nullterm(substring(_RemAccessionFormatted,size(__ACCESSIONFORMATTED)-
_RemAccessionFormatted+1,__ACCESSIONFORMATTED)))
set drawHeight_AccessionFormatted = RptSD->m_height
if (RptSD->m_height > OffsetY + sectionHeight - RptSD->m_y)
	set sectionHeight = RptSD->m_y + _fDrawHeight - OffsetY
endif
if (RptSD->m_drawLength = 0)
	set _RemAccessionFormatted = 0
elseif (RptSD->m_drawLength < size(nullterm(substring(_RemAccessionFormatted,size(__ACCESSIONFORMATTED)-_RemAccessionFormatted+1,
__ACCESSIONFORMATTED)))) ; subtract null
	set _RemAccessionFormatted = _RemAccessionFormatted+RptSD->m_drawLength
else
	set _RemAccessionFormatted = 0
endif
	; append remainder to growSum so we know whether or not to continue at the end
	set growSum = growSum + _RemAccessionFormatted
endif
set _DummyPen = uar_rptSetPen(_hReport,_pen13S0C0)
if (nCalc = RPT_RENDER AND bContinue = 0)

/****** YOUR CODE BEGINS HERE ******/
if (orders->qual [d.seq].container_id > " ")
; DRAW BAR CODE --- AccessionBC
set _rptDummy = uar_rptBarCodeInit(RptBCE,RPT_CODE128,OffsetX+0.188,OffsetY+0.167)
set RptBCE->m_barCodeType = RPT_CODE128
set RptBCE->m_ecc = 1
set RptBCE->m_recSize = 90
set RptBCE->m_width = 1.32
set RptBCE->m_height = 0.25
set RptBCE->m_rotation = 0
set RptBCE->m_ratio = 300
set RptBCE->m_barWidth = 1
set RptBCE->m_bPrintInterp = 0
set _rptStat = uar_rptBarCodeEx(_hReport,RPTBCE,build2(build("*",cnvtalphanum(orders->qual [d.seq].container_id),"*"),char(0)))
endif
/*----- YOUR CODE ENDS HERE -----*/

endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.188
set RptSD->m_width = 0.938
set RptSD->m_height = 0.167
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
set _DummyPen = uar_rptSetPen(_hReport,_pen14S0C0)
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LABEL --- AccessionNoLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Accession No:",char(0)))
endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
if (bContinue)
	set RptSD->m_y = OffsetY
else
	set RptSD->m_y = OffsetY + 0.417
endif
set RptSD->m_x = OffsetX + 0.188
set RptSD->m_width = 1.500
set RptSD->m_height = drawHeight_AccessionFormatted
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
if (nCalc = RPT_RENDER AND _HoldRemAccessionFormatted > 0)
; DRAW TEXT --- AccessionFormatted
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, nullterm(substring(_HoldRemAccessionFormatted,size(__ACCESSIONFORMATTED)-
_HoldRemAccessionFormatted+1,__ACCESSIONFORMATTED)))
else
	set _RemAccessionFormatted = _HoldRemAccessionFormatted
endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 1.188
set RptSD->m_width = 0.938
set RptSD->m_height = 0.167
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LABEL --- AccessionHeaderContinued
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(" ...(Continued)",char(0)))
endif
if (nCalc = RPT_RENDER)
	set _YOffset = OffsetY + sectionHeight
endif
	if (growSum > 0)
		set bContinue = 1 ; continue grow
	else
		set bContinue = 0 ; done growing
	endif
return(sectionHeight)
end ;subroutine AccessionRepeatHeaderABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)

subroutine AccessHead_sortSection(nCalc,maxHeight,bContinue)
declare a1=f8 with noconstant(0.0),private
set a1=(AccessHead_sortSectionABS(nCalc,_XOffset,_YOffset,maxHeight,bContinue))
return (a1)
end ;subroutine AccessHead_sortSection(nCalc,maxHeight,bContinue)

subroutine AccessHead_sortSectionABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)
declare sectionHeight = f8 with noconstant(0.570000), private
declare growSum = i4 with noconstant(0), private
declare drawHeight_AccessionFormatted = f8 with noconstant(0.0), private
declare __ACCESSIONFORMATTED = vc with NoConstant(build2(trim(ORDERS->QUAL [d.seq].CONTAINER_ID),char(0))),protect

/****** YOUR CODE BEGINS HERE ******/
if (NOT(orders->qual [d.seq].container_id != "00-00-000-0000A"))
   return (0.0)
endif
/*----- YOUR CODE ENDS HERE -----*/

if (bContinue=0)
	set _RemAccessionFormatted = 1
endif
set RptSD->m_flags = 5
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
if (bContinue)
	set RptSD->m_y = OffsetY
else
	set RptSD->m_y = OffsetY + 0.417
endif
set RptSD->m_x = OffsetX + 0.188
set RptSD->m_width = 1.500
set RptSD->m_height = OffsetY+maxHeight-RptSD->m_y
set _oldFont = uar_rptSetFont(_hReport, _Helvetica90)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
set _HoldRemAccessionFormatted = _RemAccessionFormatted
if (_RemAccessionFormatted > 0)
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, nullterm(substring(_RemAccessionFormatted,size(__ACCESSIONFORMATTED)-
_RemAccessionFormatted+1,__ACCESSIONFORMATTED)))
set drawHeight_AccessionFormatted = RptSD->m_height
if (RptSD->m_height > OffsetY + sectionHeight - RptSD->m_y)
	set sectionHeight = RptSD->m_y + _fDrawHeight - OffsetY
endif
if (RptSD->m_drawLength = 0)
	set _RemAccessionFormatted = 0
elseif (RptSD->m_drawLength < size(nullterm(substring(_RemAccessionFormatted,size(__ACCESSIONFORMATTED)-_RemAccessionFormatted+1,
__ACCESSIONFORMATTED)))) ; subtract null
	set _RemAccessionFormatted = _RemAccessionFormatted+RptSD->m_drawLength
else
	set _RemAccessionFormatted = 0
endif
	; append remainder to growSum so we know whether or not to continue at the end
	set growSum = growSum + _RemAccessionFormatted
endif
set _DummyPen = uar_rptSetPen(_hReport,_pen13S0C0)
if (nCalc = RPT_RENDER AND bContinue = 0)

/****** YOUR CODE BEGINS HERE ******/
if (orders->qual [d.seq].container_id > " ")
; DRAW BAR CODE --- AccessionBC
set _rptDummy = uar_rptBarCodeInit(RptBCE,RPT_CODE128,OffsetX+0.188,OffsetY+0.167)
set RptBCE->m_barCodeType = RPT_CODE128
set RptBCE->m_ecc = 1
set RptBCE->m_recSize = 90
set RptBCE->m_width = 1.32
set RptBCE->m_height = 0.25
set RptBCE->m_rotation = 0
set RptBCE->m_ratio = 300
set RptBCE->m_barWidth = 1
set RptBCE->m_bPrintInterp = 0
set _rptStat = uar_rptBarCodeEx(_hReport,RPTBCE,build2(build("*",cnvtalphanum(orders->qual [d.seq].container_id),"*"),char(0)))
endif
/*----- YOUR CODE ENDS HERE -----*/

endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.188
set RptSD->m_width = 0.938
set RptSD->m_height = 0.167
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica9B0)
set _DummyPen = uar_rptSetPen(_hReport,_pen14S0C0)
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LABEL --- AccessionNoLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Accession No:",char(0)))
endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
if (bContinue)
	set RptSD->m_y = OffsetY
else
	set RptSD->m_y = OffsetY + 0.417
endif
set RptSD->m_x = OffsetX + 0.188
set RptSD->m_width = 1.500
set RptSD->m_height = drawHeight_AccessionFormatted
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
if (nCalc = RPT_RENDER AND _HoldRemAccessionFormatted > 0)
; DRAW TEXT --- AccessionFormatted
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, nullterm(substring(_HoldRemAccessionFormatted,size(__ACCESSIONFORMATTED)-
_HoldRemAccessionFormatted+1,__ACCESSIONFORMATTED)))
else
	set _RemAccessionFormatted = _HoldRemAccessionFormatted
endif
if (nCalc = RPT_RENDER)
	set _YOffset = OffsetY + sectionHeight
endif
	if (growSum > 0)
		set bContinue = 1 ; continue grow
	else
		set bContinue = 0 ; done growing
	endif
return(sectionHeight)
end ;subroutine AccessHead_sortSectionABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)

subroutine OrderSectionTemp(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(OrderSectionTempABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine OrderSectionTemp(nCalc)

subroutine OrderSectionTempABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.400000), private

/****** YOUR CODE BEGINS HERE ******/
if (NOT(1=0
))
   return (0.0)
endif
/*----- YOUR CODE ENDS HERE -----*/

if (nCalc = RPT_RENDER)
set RptSD->m_flags = 20
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 2.251
set RptSD->m_width = 5.000
set RptSD->m_height = 0.251
set _oldFont = uar_rptSetFont(_hReport, _Helvetica14B0)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LABEL --- FieldName0
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("***WARNING: PAEDIATRIC/NEONATE PATIENT***",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.251
set RptSD->m_x = OffsetX + 2.001
set RptSD->m_width = 5.250
set RptSD->m_height = 0.126
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica6B0)
; DRAW LABEL --- FieldName1
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
"Please review the collection tube and blood volume required.  Refer to Pathology handbook for further information.",char(0)))
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine OrderSectionTempABS(nCalc,OffsetX,OffsetY)

subroutine OrderSection(nCalc,maxHeight,bContinue)
declare a1=f8 with noconstant(0.0),private
set a1=(OrderSectionABS(nCalc,_XOffset,_YOffset,maxHeight,bContinue))
return (a1)
end ;subroutine OrderSection(nCalc,maxHeight,bContinue)

subroutine OrderSectionABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)
declare sectionHeight = f8 with noconstant(0.560000), private
declare growSum = i4 with noconstant(0), private
declare drawHeight_ordMnemonic = f8 with noconstant(0.0), private
declare drawHeight_FieldName0 = f8 with noconstant(0.0), private
declare __ORDMNEMONIC = vc with NoConstant(build2(orders->qual [d.seq].mnemonic,char(0))),protect
declare __FIELDNAME0 = vc with NoConstant(build2(orders->qual [d.seq].display_line_rtf,char(0))),protect
declare __ORDERIDFORMATED4 = vc with NoConstant(build2(trim(cnvtstring(orders->qual[d.seq].order_id),3),char(0))),protect
if (bContinue=0)
	set _RemordMnemonic = 1
	set _RemFieldName0 = 1
endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set _oldFont = uar_rptSetFont(_hReport, _Helvetica90)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
if (nCalc = RPT_RENDER AND _RemordMnemonic > 0)
; DRAW RTF --- ordMnemonic
if (_hRTF_ordMnemonic = 0)
	set _hRTF_ordMnemonic = uar_rptCreateRtf (_hReport,__ORDMNEMONIC,1.938)
endif
if (_hRTF_ordMnemonic != 0)
	set _fDrawHeight = maxHeight
	set _rptStat = uar_rptRtfDraw (_hReport,_hRTF_ordMnemonic,OffsetX+0.063,OffsetY+ 0.063,_fDrawHeight)
endif
if (_fDrawheight > sectionHeight - 0.063)
	set sectionHeight = 0.063 + _fDrawHeight
endif
if (_rptStat != RPT_CONTINUE)
	set _rptStat = uar_rptDestroyRtf (_hReport,_hRTF_ordMnemonic)
	set _hRTF_ordMnemonic = 0
	set _RemordMnemonic = 0
endif
endif
; append remainder to growSum so we know whether or not to continue at the end
set growSum = growSum + _RemordMnemonic
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.563)
endif
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.563)
endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
if (nCalc = RPT_RENDER AND _RemFieldName0 > 0)
; DRAW RTF --- FieldName0
if (_hRTF_FieldName0 = 0)
	set _hRTF_FieldName0 = uar_rptCreateRtf (_hReport,__FIELDNAME0,3.001)
endif
if (_hRTF_FieldName0 != 0)
	set _fDrawHeight = maxHeight
	set _rptStat = uar_rptRtfDraw (_hReport,_hRTF_FieldName0,OffsetX+4.198,OffsetY+ 0.063,_fDrawHeight)
endif
if (_fDrawheight > sectionHeight - 0.063)
	set sectionHeight = 0.063 + _fDrawHeight
endif
if (_rptStat != RPT_CONTINUE)
	set _rptStat = uar_rptDestroyRtf (_hReport,_hRTF_FieldName0)
	set _hRTF_FieldName0 = 0
	set _RemFieldName0 = 0
endif
endif
; append remainder to growSum so we know whether or not to continue at the end
set growSum = growSum + _RemFieldName0
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.376
set RptSD->m_x = OffsetX + 2.063
set RptSD->m_width = 1.386
set RptSD->m_height = 0.188
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica80)
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW TEXT --- OrderIdFormated4
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __ORDERIDFORMATED4)
endif
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 2.073
set RptSD->m_width = 0.896
set RptSD->m_height = 0.167
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica8B0)
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW LABEL --- OrderNameLBL5
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Order Id:",char(0)))
endif
set _DummyPen = uar_rptSetPen(_hReport,_pen13S0C0)
if (nCalc = RPT_RENDER AND bContinue = 0)
; DRAW BAR CODE --- AccessionBC3
set _rptDummy = uar_rptBarCodeInit(RptBCE,RPT_CODE128,OffsetX+2.063,OffsetY+0.125)
set RptBCE->m_barCodeType = RPT_CODE128
set RptBCE->m_ecc = 1
set RptBCE->m_recSize = 90
set RptBCE->m_width = 0.88
set RptBCE->m_height = 0.28
set RptBCE->m_rotation = 0
set RptBCE->m_ratio = 300
set RptBCE->m_barWidth = 1
set RptBCE->m_bPrintInterp = 0
set RptBCE->m_bCheckDigit = 1
set _rptStat = uar_rptBarCodeEx(_hReport,RPTBCE,build2(build("*",cnvtint(orders->qual[d.seq].order_id),"*"),char(0)))
endif
if (nCalc = RPT_RENDER)
	set _YOffset = OffsetY + sectionHeight
endif
	if (growSum > 0)
		set bContinue = 1 ; continue grow
	else
		set bContinue = 0 ; done growing
	endif
return(sectionHeight)
end ;subroutine OrderSectionABS(nCalc,OffsetX,OffsetY,maxHeight,bContinue)

subroutine WarningSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(WarningSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine WarningSection(nCalc)

subroutine WarningSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.500000), private

/****** YOUR CODE BEGINS HERE ******/
if (NOT(cnvtupper(trim(orders->qual[d.seq].MNEMONIC_SORT)) = "BLOOD GROUP AND ANTIBODY SCREEN EXTENDED EXPIRY"))
   return (0.0)
endif
/*----- YOUR CODE ENDS HERE -----*/

if (nCalc = RPT_RENDER)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.188
set RptSD->m_width = 7.313
set RptSD->m_height = 0.500
set _oldFont = uar_rptSetFont(_hReport, _Helvetica8B255)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LABEL --- FieldName1
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
concat("Western Health Patient: Ensure UR Number is entered when registering. Blood bank tubes must have UR Number Reco",
"rded.",_CRLF,
"Please Send Blood Bank Sample and Copy of Request to site of surgery:",_CRLF,
"        Western & Williamstown Hospitals - to Footscray Lab.   Sunshine and Sunbury (Day) Hospitals - to Sunshin",
"e Lab")
,char(0)))
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine WarningSectionABS(nCalc,OffsetX,OffsetY)

subroutine Footacc_sortSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(Footacc_sortSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine Footacc_sortSection(nCalc)

subroutine Footacc_sortSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.060000), private

/****** YOUR CODE BEGINS HERE ******/
if (NOT(orders->qual [d.seq].container_id !=" "))
   return (0.0)
endif
/*----- YOUR CODE ENDS HERE -----*/

if (nCalc = RPT_RENDER)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LINE --- FieldName0
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.032,OffsetX+7.511, OffsetY+0.032)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine Footacc_sortSectionABS(nCalc,OffsetX,OffsetY)

subroutine NoBBContinueSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(NoBBContinueSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine NoBBContinueSection(nCalc)

subroutine NoBBContinueSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.170000), private
declare __CONTINUEDTESTS = vc with NoConstant(build2(concat("**Number of Test(s) requested on page is: ",
trim(cnvtstring(order_cnt)),"/",trim(cnvtstring(orders->cnt)),"**"),char(0))),protect

/****** YOUR CODE BEGINS HERE ******/
if (NOT(orders->qual[d.seq].bloodbank_req != 1))
   return (0.0)
endif
/*----- YOUR CODE ENDS HERE -----*/

if (nCalc = RPT_RENDER)
set RptSD->m_flags = 20
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.813
set RptSD->m_width = 2.001
set RptSD->m_height = 0.167
set _oldFont = uar_rptSetFont(_hReport, _Helvetica80)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)

/****** YOUR CODE BEGINS HERE ******/
if (TEST_CONT_IND = 1)
; DRAW LABEL --- ContinuedLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("**Test(s) continued next page**",char(0)))
endif
/*----- YOUR CODE ENDS HERE -----*/

set RptSD->m_flags = 64
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 2.813
set RptSD->m_width = 4.625
set RptSD->m_height = 0.167
; DRAW TEXT --- ContinuedTests
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __CONTINUEDTESTS)
; DRAW LINE --- FieldName0
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.167)
; DRAW LINE --- borderRight
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.167)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine NoBBContinueSectionABS(nCalc,OffsetX,OffsetY)

subroutine ContinueSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(ContinueSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine ContinueSection(nCalc)

subroutine ContinueSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.170000), private
declare __CONTINUEDTESTS = vc with NoConstant(build2(concat("**Number of Test(s) requested on page is: ",
trim(cnvtstring(order_cnt)),"/",trim(cnvtstring(orders->cnt)),"**"),char(0))),protect

/****** YOUR CODE BEGINS HERE ******/
if (NOT(orders->qual[d.seq].bloodbank_req = 1))
   return (0.0)
endif
/*----- YOUR CODE ENDS HERE -----*/

if (nCalc = RPT_RENDER)
set RptSD->m_flags = 20
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.813
set RptSD->m_width = 2.001
set RptSD->m_height = 0.167
set _oldFont = uar_rptSetFont(_hReport, _Helvetica80)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)

/****** YOUR CODE BEGINS HERE ******/
if (TEST_CONT_IND = 1)
; DRAW LABEL --- ContinuedLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("**Test(s) continued next page**",char(0)))
endif
/*----- YOUR CODE ENDS HERE -----*/

; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.167)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.167)
set RptSD->m_flags = 64
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 2.813
set RptSD->m_width = 4.625
set RptSD->m_height = 0.167
; DRAW TEXT --- ContinuedTests
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, __CONTINUEDTESTS)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine ContinueSectionABS(nCalc,OffsetX,OffsetY)

subroutine CollectorStatement(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(CollectorStatementABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine CollectorStatement(nCalc)

subroutine CollectorStatementABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.500000), private

/****** YOUR CODE BEGINS HERE ******/
if (NOT(orders->qual[d.seq].bloodbank_req = 1))
   return (0.0)
endif
/*----- YOUR CODE ENDS HERE -----*/

if (nCalc = RPT_RENDER)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDLEFTBORDER
set RptSD->m_paddingWidth = 0.100
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.000
set RptSD->m_width = 3.938
set RptSD->m_height = 0.500
set _oldFont = uar_rptSetFont(_hReport, _Helvetica9B16777215)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
set oldBackColor = uar_RptSetBackColor(_hReport,RPT_BLACK)
; DRAW LABEL --- FieldName0
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
concat("The specimen collector MUST identify the specimen with: ",_CRLF,
_CRLF,
"SPECIMEN DETAILS MUST MATCH THOSE ON THIS FORM")
,char(0)))
set oldBackColor = uar_RptResetBackColor(_hReport)
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 3.938
set RptSD->m_width = 3.563
set RptSD->m_height = 0.500
set oldBackColor = uar_RptSetBackColor(_hReport,RPT_BLACK)
; DRAW LABEL --- FieldName1
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
concat("1) Patient surname, first name, UR & DOB",_CRLF,
"2) Collector's initials",_CRLF,
"3) Collection date & time")
,char(0)))
set oldBackColor = uar_RptResetBackColor(_hReport)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine CollectorStatementABS(nCalc,OffsetX,OffsetY)

subroutine CollectionDetailsSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(CollectionDetailsSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine CollectionDetailsSection(nCalc)

subroutine CollectionDetailsSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.450000), private
if (nCalc = RPT_RENDER)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 1.250
set RptSD->m_height = 0.188
set _oldFont = uar_rptSetFont(_hReport, _Helvetica6B0)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LABEL --- CollectionDetails
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Collector's Declaration:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 1.375
set RptSD->m_width = 6.125
set RptSD->m_height = 0.313
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica60)
; DRAW LABEL --- CertifyLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
concat("I certify that the blood/specimen(s) accompanying this request was collected from the patient named above and I",
" established the identity of this patient by direct inquiry and/or inspection of wrist band, and immediately upo",
"n collecting the blood/specimen(s)  I labelled the blood/specimen(s)")
,char(0)))
; DRAW LINE --- TopBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 1.250
set RptSD->m_height = 0.146
; DRAW LABEL --- CollectorNameLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Collector's Name(Print):",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 2.563
set RptSD->m_width = 1.000
set RptSD->m_height = 0.146
; DRAW LABEL --- SignedLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Signature:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 5.063
set RptSD->m_width = 0.875
set RptSD->m_height = 0.146
; DRAW LABEL --- CollectionDateLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Collection Date:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 6.375
set RptSD->m_width = 0.875
set RptSD->m_height = 0.146
; DRAW LABEL --- CollectionTimeLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Collection Time:",char(0)))
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.750)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.750)
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.313
set RptSD->m_x = OffsetX + 4.375
set RptSD->m_width = 0.376
set RptSD->m_height = 0.146
; DRAW LABEL --- CollectionDateLBL1
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Initials:",char(0)))
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine CollectionDetailsSectionABS(nCalc,OffsetX,OffsetY)

subroutine LabUseOnlySection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(LabUseOnlySectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine LabUseOnlySection(nCalc)

subroutine LabUseOnlySectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.150000), private
if (nCalc = RPT_RENDER)
set RptSD->m_flags = 260
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 1.000
set RptSD->m_height = 0.146
set _oldFont = uar_rptSetFont(_hReport, _Helvetica6B0)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LABEL --- LabUseOnlyLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Lab Use Only:",char(0)))
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.146)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.146)
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 6.563
set RptSD->m_width = 0.938
set RptSD->m_height = 0.146
; DRAW LABEL --- SDLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("SD:",char(0)))
; DRAW LINE --- TopBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
; DRAW RECTANGLE --- FieldName1
set _rptStat = uar_rptRect ( _hReport, OffsetX+6.750, OffsetY+0.031, 0.073, 0.073, RPT_NOFILL, RPT_WHITE)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine LabUseOnlySectionABS(nCalc,OffsetX,OffsetY)

subroutine EDTASection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(EDTASectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine EDTASection(nCalc)

subroutine EDTASectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.290000), private
if (nCalc = RPT_RENDER)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.302)
; DRAW LINE --- LeftBorder0
set _rptStat = uar_rptLine( _hReport,OffsetX+0.407,OffsetY+ 0.000,OffsetX+0.407, OffsetY+0.302)
; DRAW LINE --- LeftBorder21
set _rptStat = uar_rptLine( _hReport,OffsetX+0.824,OffsetY+ 0.000,OffsetX+0.824, OffsetY+0.302)
; DRAW LINE --- LeftBorder22
set _rptStat = uar_rptLine( _hReport,OffsetX+1.230,OffsetY+ 0.000,OffsetX+1.230, OffsetY+0.302)
; DRAW LINE --- LeftBorder23
set _rptStat = uar_rptLine( _hReport,OffsetX+1.636,OffsetY+ 0.000,OffsetX+1.636, OffsetY+0.302)
; DRAW LINE --- LeftBorder24
set _rptStat = uar_rptLine( _hReport,OffsetX+2.053,OffsetY+ 0.000,OffsetX+2.053, OffsetY+0.302)
; DRAW LINE --- LeftBorder25
set _rptStat = uar_rptLine( _hReport,OffsetX+2.459,OffsetY+ 0.000,OffsetX+2.459, OffsetY+0.302)
; DRAW LINE --- LeftBorder26
set _rptStat = uar_rptLine( _hReport,OffsetX+2.876,OffsetY+ 0.000,OffsetX+2.876, OffsetY+0.302)
; DRAW LINE --- LeftBorder27
set _rptStat = uar_rptLine( _hReport,OffsetX+3.282,OffsetY+ 0.000,OffsetX+3.282, OffsetY+0.302)
; DRAW LINE --- LeftBorder28
set _rptStat = uar_rptLine( _hReport,OffsetX+3.688,OffsetY+ 0.000,OffsetX+3.688, OffsetY+0.302)
; DRAW LINE --- LeftBorder29
set _rptStat = uar_rptLine( _hReport,OffsetX+4.105,OffsetY+ 0.000,OffsetX+4.105, OffsetY+0.302)
; DRAW LINE --- LeftBorder30
set _rptStat = uar_rptLine( _hReport,OffsetX+4.511,OffsetY+ 0.000,OffsetX+4.511, OffsetY+0.302)
; DRAW LINE --- LeftBorder31
set _rptStat = uar_rptLine( _hReport,OffsetX+4.917,OffsetY+ 0.000,OffsetX+4.917, OffsetY+0.302)
; DRAW LINE --- LeftBorder32
set _rptStat = uar_rptLine( _hReport,OffsetX+5.345,OffsetY+ 0.000,OffsetX+5.345, OffsetY+0.302)
; DRAW LINE --- LeftBorder33
set _rptStat = uar_rptLine( _hReport,OffsetX+5.751,OffsetY+ 0.000,OffsetX+5.751, OffsetY+0.302)
; DRAW LINE --- LeftBorder34
set _rptStat = uar_rptLine( _hReport,OffsetX+6.251,OffsetY+ 0.000,OffsetX+6.251, OffsetY+0.302)
; DRAW LINE --- LeftBorder35
set _rptStat = uar_rptLine( _hReport,OffsetX+6.688,OffsetY+ 0.000,OffsetX+6.688, OffsetY+0.302)
; DRAW LINE --- LeftBorder36
set _rptStat = uar_rptLine( _hReport,OffsetX+7.063,OffsetY+ 0.000,OffsetX+7.063, OffsetY+0.302)
; DRAW LINE --- LeftBorder37
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.302)
; DRAW LINE --- TopBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
; DRAW LINE --- TopBorder39
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.146,OffsetX+7.501, OffsetY+0.146)
set RptSD->m_flags = 20
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.000
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
set _oldFont = uar_rptSetFont(_hReport, _Helvetica6B0)
; DRAW LABEL --- FieldName29
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("EDTA",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.417
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName0
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("SER",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.823
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName1
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("HEP",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 1.230
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName2
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("CITR",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 1.636
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName3
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("ESR",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 2.053
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName4
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("FLU",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 2.459
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName5
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("ACD",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 2.876
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName6
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("GAS",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 3.282
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName7
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("BCUL",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 3.688
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName8
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("TISS",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 4.105
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName9
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("URI",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 4.511
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName10
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("SWAB",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 4.917
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName11
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("CSF",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 5.334
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName12
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("FLUID",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 5.750
set RptSD->m_width = 0.500
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName13
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("SPUT",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 6.250
set RptSD->m_width = 0.417
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName14
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("FAEC",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 6.688
set RptSD->m_width = 0.376
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName15
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("BWA",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 7.063
set RptSD->m_width = 0.438
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName16
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("OTHER",char(0)))
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine EDTASectionABS(nCalc,OffsetX,OffsetY)

subroutine BillingStatusSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(BillingStatusSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine BillingStatusSection(nCalc)

subroutine BillingStatusSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.150000), private
if (nCalc = RPT_RENDER)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.938
set RptSD->m_height = 0.146
set _oldFont = uar_rptSetFont(_hReport, _Helvetica6B0)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LABEL --- FieldName29
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Billing Status:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.938
set RptSD->m_width = 1.636
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName30
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Public/Private/Overseas",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 2.188
set RptSD->m_width = 1.344
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName31
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Outpatient/Inpatient",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 3.376
set RptSD->m_width = 1.188
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName32
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("TAC/Workcover",char(0)))
; DRAW LINE --- topBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.146)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.146)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine BillingStatusSectionABS(nCalc,OffsetX,OffsetY)

subroutine AssignmentFormSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(AssignmentFormSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine AssignmentFormSection(nCalc)

subroutine AssignmentFormSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.970000), private
if (nCalc = RPT_RENDER)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 1.625
set RptSD->m_height = 0.146
set _oldFont = uar_rptSetFont(_hReport, _Helvetica6B0)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LABEL --- MedicareAssmntLbl
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Medicare Assignment Form:",char(0)))
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+1.000)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+1.000)
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.126
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 2.188
set RptSD->m_height = 0.500
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica60)
; DRAW LABEL --- FieldName35
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
concat("(Section20A of the Health Insurance Act 1973)",_CRLF,
"I assign my right to the approved pathology Practitioner who will render the requested Pathology service(s)")
,char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.625
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 2.188
set RptSD->m_height = 0.188
; DRAW LABEL --- FieldName36
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
"Patient Signature:____________________________________________________",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.813
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 2.188
set RptSD->m_height = 0.146
; DRAW LABEL --- DateLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
"Date:____________________________________________________________________",char(0)))
; DRAW LINE --- CenterLeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+2.376,OffsetY+ 0.000,OffsetX+2.376, OffsetY+1.000)
; DRAW LINE --- CenterLeftBorder2
set _rptStat = uar_rptLine( _hReport,OffsetX+5.438,OffsetY+ 0.000,OffsetX+5.438, OffsetY+1.000)
; DRAW LINE --- topBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 2.438
set RptSD->m_width = 1.625
set RptSD->m_height = 0.146
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica6B0)
; DRAW LABEL --- PatientStatusLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Patient Status:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.126
set RptSD->m_x = OffsetX + 2.438
set RptSD->m_width = 2.501
set RptSD->m_height = 0.146
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica60)
; DRAW LABEL --- FieldName39
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Private patient in a private hospital or approved day hospital",char
(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.251
set RptSD->m_x = OffsetX + 2.438
set RptSD->m_width = 2.063
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName40
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Private patient in a recognised hospital",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.376
set RptSD->m_x = OffsetX + 2.438
set RptSD->m_width = 1.875
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName41
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Public patient in a recognised hospital",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.500
set RptSD->m_x = OffsetX + 2.438
set RptSD->m_width = 2.063
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName42
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Outpatient of a recognised hospital ",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.126
set RptSD->m_x = OffsetX + 5.000
set RptSD->m_width = 0.438
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName4
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Y      N",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.251
set RptSD->m_x = OffsetX + 5.000
set RptSD->m_width = 0.438
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName5
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Y      N",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.376
set RptSD->m_x = OffsetX + 5.000
set RptSD->m_width = 0.438
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName6
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Y      N",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.500
set RptSD->m_x = OffsetX + 5.000
set RptSD->m_width = 0.438
set RptSD->m_height = 0.146
; DRAW LABEL --- FieldName7
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Y      N",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.625
set RptSD->m_x = OffsetX + 2.438
set RptSD->m_width = 2.876
set RptSD->m_height = 0.157
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica6U0)
; DRAW LABEL --- FieldName8
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Practitioner's use only",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.813
set RptSD->m_x = OffsetX + 2.438
set RptSD->m_width = 2.876
set RptSD->m_height = 0.146
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica60)
; DRAW LABEL --- DateLBL9
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
"Reason patient cannot sign: ______________________________________________",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 5.500
set RptSD->m_width = 1.625
set RptSD->m_height = 0.251
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica90)
; DRAW LABEL --- PatientStatusLBL10
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("For External Provider",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.126
set RptSD->m_x = OffsetX + 5.500
set RptSD->m_width = 1.750
set RptSD->m_height = 0.376
; DRAW LABEL --- PatientStatusLBL11
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Requesting Medical Officer Signature:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.782
set RptSD->m_x = OffsetX + 5.500
set RptSD->m_width = 0.500
set RptSD->m_height = 0.209
; DRAW LABEL --- PatientStatusLBL14
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Date:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.563
set RptSD->m_x = OffsetX + 5.813
set RptSD->m_width = 1.625
set RptSD->m_height = 0.157
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica60)
; DRAW LABEL --- FieldName0
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("____________________________________________",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.844
set RptSD->m_x = OffsetX + 5.813
set RptSD->m_width = 1.625
set RptSD->m_height = 0.157
; DRAW LABEL --- FieldName1
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("____________________________________________",char(0)))
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine AssignmentFormSectionABS(nCalc,OffsetX,OffsetY)

subroutine PrivacyNoteSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(PrivacyNoteSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine PrivacyNoteSection(nCalc)

subroutine PrivacyNoteSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.380000), private
if (nCalc = RPT_RENDER)
set RptSD->m_flags = 4
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 0.688
set RptSD->m_height = 0.146
set _oldFont = uar_rptSetFont(_hReport, _Helvetica6B0)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LABEL --- PrivacyNoteLBL
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2("Privacy Note:",char(0)))
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.073
set RptSD->m_x = OffsetX + 0.063
set RptSD->m_width = 7.313
set RptSD->m_height = 0.313
set _DummyFont = uar_rptSetFont(_hReport, _Helvetica60)
; DRAW LABEL --- FieldName35
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(
concat("The information provided will be used to assess any Medicare benefit payable for the services rendered and to f",
"acilitate the proper administration of the government health programs, and may be used to update enrolment recor",
"ds. Its collection is authorised by provisions of the Health Insurance Act 1973. The information may be disclose",
"d to the Dept of Health or to a person in the medical practice associated with this claim, or as authorised/ req",
"uired by law.")
,char(0)))
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+0.375)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.375)
; DRAW LINE --- topBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.000,OffsetX+7.501, OffsetY+0.000)
; DRAW LINE --- BottomBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.000,OffsetY+ 0.375,OffsetX+7.501, OffsetY+0.375)
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine PrivacyNoteSectionABS(nCalc,OffsetX,OffsetY)

subroutine FootPageSection(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(FootPageSectionABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine FootPageSection(nCalc)

subroutine FootPageSectionABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(0.200000), private
if (nCalc = RPT_RENDER)
set RptSD->m_flags = 0
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_lineSpacing = RPT_SINGLE
set RptSD->m_rotationAngle = 0
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 0.000
set RptSD->m_width = 2.251
set RptSD->m_height = 0.198
set _oldFont = uar_rptSetFont(_hReport, _Helvetica100)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW TEXT --- RPT_PAGEOFPAGE
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(RPT_PAGEOFPAGE,char(0)))
set RptSD->m_flags = 64
set RptSD->m_borders = RPT_SDNOBORDERS
set RptSD->m_padding = RPT_SDNOBORDERS
set RptSD->m_paddingWidth = 0.000
set RptSD->m_y = OffsetY + 0.001
set RptSD->m_x = OffsetX + 4.625
set RptSD->m_width = 2.751
set RptSD->m_height = 0.198
; DRAW TEXT --- printedDtTm
set _fDrawHeight = uar_rptStringDraw(_hReport, RptSD, build2(printedDtTm,char(0)))
	set _YOffset = OffsetY + sectionHeight
endif
return(sectionHeight)
end ;subroutine FootPageSectionABS(nCalc,OffsetX,OffsetY)

subroutine OrderBox(nCalc)
declare a1=f8 with noconstant(0.0),private
set a1=(OrderBoxABS(nCalc,_XOffset,_YOffset))
return (a1)
end ;subroutine OrderBox(nCalc)

subroutine OrderBoxABS(nCalc,OffsetX,OffsetY)
declare sectionHeight = f8 with noconstant(5.630000), private
if (nCalc = RPT_RENDER)
set _oldPen = uar_rptSetPen(_hReport,_pen14S0C0)
; DRAW LINE --- LeftBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+0.001,OffsetY+ 0.000,OffsetX+0.001, OffsetY+5.719)
; DRAW LINE --- RightBorder
set _rptStat = uar_rptLine( _hReport,OffsetX+7.501,OffsetY+ 0.000,OffsetX+7.501, OffsetY+5.719)
endif
return(sectionHeight)
end ;subroutine OrderBoxABS(nCalc,OffsetX,OffsetY)

subroutine InitializeReport(dummy)
set RptReport->m_recSize = 104
set RptReport->m_reportName = "WH_AU_REQGEN07_LYT"
set RptReport->m_pageWidth = 8.50
set RptReport->m_pageHeight = 11.50
set RptReport->m_orientation = Rpt_Portrait
set RptReport->m_marginLeft = 0.50
set RptReport->m_marginRight = 0.50
set RptReport->m_marginTop = 0.20
set RptReport->m_marginBottom = 0.00
set RptReport->m_horzPrintOffset = _XShift
set RptReport->m_vertPrintOffset = _YShift
set RptReport->m_dioFlag = 0
set RptReport->m_needsNotoNaskhArabic = 0
set _YOffset = RptReport->m_marginTop
set _XOffset = RptReport->m_marginLeft
set _hReport = uar_rptCreateReport(RptReport, _OutputType,Rpt_Inches)
set _rptErr = uar_rptSetErrorLevel(_hReport,Rpt_Error)
set _rptStat = uar_rptStartReport(_hReport)
set _rptPage = uar_rptStartPage(_hReport)
set _stat = _LoadImages(0)
call _CreateFonts(0)
call _CreatePens(0)
end ;_InitializeReport

subroutine _CreateFonts(dummy)
set RptFont->m_recSize = 62
set RptFont->m_fontName = RPT_TIMES
set RptFont->m_pointSize = 10
set RptFont->m_bold = RPT_OFF
set RptFont->m_italic = RPT_OFF
set RptFont->m_underline = RPT_OFF
set RptFont->m_strikethrough = RPT_OFF
set RptFont->m_rgbColor = RPT_BLACK
set _Times100 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 4
set RptFont->m_rgbColor = RPT_WHITE
set _Times416777215 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_fontName = RPT_HELVETICA
set RptFont->m_pointSize = 8
set RptFont->m_rgbColor = RPT_BLACK
set _Helvetica80 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_bold = RPT_ON
set _Helvetica8B0 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 9
set _Helvetica9B0 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_bold = RPT_OFF
set _Helvetica90 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 12
set RptFont->m_bold = RPT_ON
set _Helvetica12B0 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 16
set RptFont->m_rgbColor = RPT_WHITE
set _Helvetica16B16777215 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 14
set RptFont->m_rgbColor = RPT_BLACK
set _Helvetica14B0 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 6
set _Helvetica6B0 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 8
set RptFont->m_rgbColor = RPT_RED
set _Helvetica8B255 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 9
set RptFont->m_rgbColor = RPT_WHITE
set _Helvetica9B16777215 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 6
set RptFont->m_bold = RPT_OFF
set RptFont->m_rgbColor = RPT_BLACK
set _Helvetica60 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_underline = RPT_ON
set _Helvetica6U0 = uar_rptCreateFont(_hReport, RptFont)
set RptFont->m_pointSize = 10
set RptFont->m_underline = RPT_OFF
set _Helvetica100 = uar_rptCreateFont(_hReport, RptFont)
end;**************Create Fonts*************

subroutine _CreatePens(dummy)
set RptPen->m_recSize = 16
set RptPen->m_penWidth = 0.014
set RptPen->m_penStyle = 0
set RptPen->m_rgbColor =  RPT_BLACK
set _pen14S0C0 = uar_rptCreatePen(_hReport,RptPen)
set RptPen->m_penWidth = 0.014
set _pen13S0C0 = uar_rptCreatePen(_hReport,RptPen)
end;**************Create Pen*************

;**************Report Layout End*************



call InitializeReport(0)
set _fEndDetail=RptReport->m_pageHeight-RptReport->m_marginBottom

set _fHoldEndDetail = _fEndDetail
call Query1(0)
set _fEndDetail = _fHoldEndDetail

call FinalizeReport(_SendTo)

end go
