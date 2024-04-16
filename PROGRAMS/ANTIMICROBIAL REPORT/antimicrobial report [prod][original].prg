;if table structure changes:
;drop table cust_tclass go

drop program vic_au_antimicrobial_rpt go
create program vic_au_antimicrobial_rpt


/* ****************************************************************************************************
 *                             MODIFICATION CONTROL LOG                                               *
 ******************************************************************************************************
 *Mod Date     		Developer     	INFRA   	Comment                                               *
 *--- -------- 		------------ 	-------   	------------------------------------------------------*
 *000 Aug 2016  	Grant W   		ER751112  	Initial release AHS BR119-15                          *
 *001 Oct 2016		Grant W			KE768804	Fix scenario where Primary has more than one TClass   *
 *												assigned to synonyms; and some are, and some are not  *
 *												in the Antimicrobial capture group					  *
 *002 Oct 2016		Grant W			KE768804	Add "Inhaled Anti-Infectives" to target list          *
 *003 Nov 2016		Grant W			ERtbav		Add ED encounters 				                      *
 * 												and convert to use Custom Antimicrobial Tables        *
 ******************************************************************************************************/

 /* 	check:
 				SR769827: 	Approval Number fields not populating
 							No buffer get errors in PRDD2

 				KE768804:	Pentamidine error
 							Add "Inhaled Anti-infectives"
 */

prompt
	"Output to File/Printer/MINE" = "MINE"               ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Select Location(s)" = VALUE(0.0)
	, "Clinical Unit" = VALUE(0.0)
	, "Therapeutic Class Tier 1" = VALUE(0.0, Any (*))
	, "Formulary Status:" = VALUE(       2445.00)
	, "Printed Report or CSV" = 0
	, "Audit Only:  Order Catalog Antimicrobials" = 0

with OUTDEV, FAC, Loc, CLINUNIT, TC1, FS, CSV, OC_Audit

;Param    1    2    3         4    5   6         7
;--------------------------------------------------------------------------------------------------
;Declare variables

declare ENC_INPATIENT 			= f8 with constant(uar_get_code_by("displaykey",71,"INPATIENT")),protect
declare ENC_EMERGENCY 			= f8 with constant(uar_get_code_by("displaykey",71,"EMERGENCY")),protect ;003
declare ENC_CANCELLED 			= f8 with constant(uar_get_code_by("displaykey",261,"CANCELLED")),protect
declare mrn_cd 					= f8 with constant(uar_get_code_by("displaykey",319,"URN")),protect ;1079
declare visit_id 				= f8 with constant(uar_get_code_by("displaykey",319,"FINNBR")),protect ;1077
declare discharge_cd 			= f8 with constant(uar_get_code_by("MEANING",261,"DISCHARGED"))
declare MEDS 					= f8 with constant(uar_get_code_by("displaykey",6000,"PHARMACY")),protect
declare ord_ordered_status_cd 	= f8 with constant(uar_get_code_by("MEANING",6004,"ORDERED"))
declare ord_pendcompl_status_cd = f8 with constant(uar_get_code_by("MEANING",6004,"PENDINGCOMPLETE"))

declare INDICATION_CD 			= f8 with protect, constant(uar_get_code_by("DISPLAYKEY",16449,"INDICATION"))
declare APPROVAL_CD 			= f8 with protect, constant(uar_get_code_by("DISPLAYKEY",16449,"APPROVALNUMBER"))

declare l_opr_var 		= c2 					;OPERATOR() switches
declare c_opr_var 		= c2 					;

declare lcheck	= c1 with noconstant("a") 		; used to aggregate Prompt selection messages
declare lcnt	= i4 with noconstant(1)			;
declare lstring = vc with noconstant			;

declare pos = i4 with noconstant(0), protect 	; used for LOCATEVAL function.
Declare idx = i4 with noconstant(0), protect 	;
declare num	= i4 with protect 				 	; index var for EXPAND()

;RTF codes for formatting text in LAYOUT
declare _rtfstart 	= vc with constant("{\rtf1\ansi{\fonttbl\f0\fswiss Helvetica;}\f0\pard\fs16 ")
declare _rtfend 	= vc with constant("\par }")
declare _rtfbold 	= vc with constant("{\b ")
declare _rtfboldend = vc with constant("\b0 }")

;----------------------------------------------------------------------------------


record OrdersRec
 (
	1 	Cnt 					= i4	;Total records
	1	Facility				= c50	;Prompt literals for Printed Report
	1	Wards					= vc	;
	1 	Clinical_Units			= vc	;
	1	TC_Choice				= vc	;
	1	FS_Choice				= c50 	;
	1	User_Name				= c100	;

	1 	lst[*]
		2	Facility			= vc
		2	Location			= vc
		2 	Room				= vc
		2	Bed					= vc
		2	ClinicalUnit	 	= vc
		2	encntr_id			= f8
		2	person_id			= f8
		2 	EncntrType			= c20
		2	PatientName			= vc
		2	DOB					= c10
		2 	Admit_dttm  		= c20
		2	MRN					= c15
		2 	ordered_as			= vc ;CSV+Layout
		2   MedsOrders          = vc ;CSV
		2	ord_details			= vc ;Layout
		2	Order_status		= c50
		2	OrderId 			= f8
 		2	pri_cat_cd			= f8

		2	synonym_id			= f8
		2 	synonym_mn_type		= c50
		2 	TC_tier1			= c100
		2 	TC_tier1_asc_id		= f8

		2 	formulary_status	= c50
 		2   Indication          = vc
		2   ApprovalNum			= vc
		2	FirstDose_dttm		= c20 ;CSV
		2	FirstDose_dttm_rtf	= c100;Layout
		2	StopDose_dttm		= c20
		2	order_dttm			= c20
 )

;----------------------------------------------------------------------------------
;Process prompts   *** NOTE: All "Any(*)" to be set to 0.0 or OPERATOR will error ***

;Audit Only?
if ($OC_Audit = 1) go to 888_OC_Audit endif

;Facility - there can only be one
Set OrdersRec->Facility = uar_get_code_description(parameter(parameter2($FAC),1))

;Location
set lstring = trim(uar_get_code_display(parameter(parameter2($Loc),1)))
if(substring(1,1,reflect(parameter(parameter2($Loc),0))) = "L")  	;multiple
	set l_opr_var = "IN"
	set lcheck = substring(1,1,reflect(parameter(parameter2($Loc),0)))
	set lcnt = 1
	While(lcheck > " ")
		set lcnt = lcnt + 1
		set lcheck = substring(1,1,reflect(parameter(parameter2($Loc),lcnt)))
		If(lcheck > " ")
			set lstring = concat(lstring,", ",trim(uar_get_code_display(parameter(parameter2($Loc),lcnt))))
		Endif
	EndWhile
	set OrdersRec->Wards = lstring
elseif(parameter(parameter2($Loc),1)= 0.0) 							;Any()
	set l_opr_var = "!="
	Set OrdersRec->Wards = "All Wards"
else 																;single
	set l_opr_var = "="
	set OrdersRec->Wards = lstring
endif

;Clinical Unit
set lstring = trim(uar_get_code_display(parameter(parameter2($CLINUNIT),1)))
if(substring(1,1,reflect(parameter(parameter2($CLINUNIT),0))) = "L")  	;multiple
	set c_opr_var = "IN"
	set lcheck = substring(1,1,reflect(parameter(parameter2($CLINUNIT),0)))
	set lcnt = 1
	While(lcheck > " ")
		set lcnt = lcnt + 1
		set lcheck = substring(1,1,reflect(parameter(parameter2($CLINUNIT),lcnt)))
		If(lcheck > " ")
			set lstring = concat(lstring,", ",trim(uar_get_code_display(parameter(parameter2($CLINUNIT),lcnt))))
		Endif
	EndWhile
	Set OrdersRec->Clinical_Units = lstring
elseif(parameter(parameter2($CLINUNIT),1)= 0.0) 					;Any()
	set c_opr_var = "!="
	Set OrdersRec->Clinical_Units = "All Clinical Units"
else 																;single
	set c_opr_var = "="
	set OrdersRec->Clinical_Units = lstring
endif

;Therapeutic Classes
if(parameter(parameter2($TC1),1)= 0.0) 								;Any()
	Set OrdersRec->TC_Choice = "All Antimicrobial Therapeutic Classes"
else 																;single/multiple
	Set OrdersRec->TC_Choice = "Selected Therapeutic Classes Only"
endif

;Formulary Status
set lstring = trim(uar_get_code_display(parameter(parameter2($FS),1)))
if(substring(1,1,reflect(parameter(parameter2($FS),0))) = "L")  	;multiple
	set lcheck = substring(1,1,reflect(parameter(parameter2($FS),0)))
	set lcnt = 1
	While(lcheck > " ")
		set lcnt = lcnt + 1
		set lcheck = substring(1,1,reflect(parameter(parameter2($FS),lcnt)))
		If(lcheck > " ")
			set lstring = concat(lstring,", ",trim(uar_get_code_display(parameter(parameter2($FS),lcnt))))
		Endif
	EndWhile
	Set OrdersRec->FS_Choice = lstring
elseif(parameter(parameter2($FS),1)= 0.0) 							;Any()
	Set OrdersRec->FS_Choice = "All"
else 																;single
	set OrdersRec->FS_Choice = lstring
endif

;User Name
declare UserName = vc WITH protect
if (REQINFO->UPDT_ID = 0)
    set UserName = CURUSER
else
    select into "nl:"
        p.name_full_formatted
    from person p
    where P.PERSON_ID = REQINFO->UPDT_ID
    detail
        OrdersRec->User_Name = trim(substring(1,35,p.name_full_formatted), 3)
endif
;----------------------------------------------------------------------------------
;Load current encounters & orders of interest

select into "nl:"

FROM
	encntr_domain ed
	,encounter e
	,Person p
	,Encntr_Alias ea
	,orders o
	,cust_am_pri cp ;003
	,order_catalog_synonym ocs
	,(left join ocs_facility_formulary_r ocsf on ocsf.synonym_id  = ocs.synonym_id
											 and ocsf.facility_cd = $FAC)

plan ed ;only want open Encounters
    where ed.loc_facility_cd 	= $FAC
	and operator(ed.loc_nurse_unit_cd,l_opr_var,$Loc)
	and operator(ed.med_service_cd,c_opr_var,$ClinUnit)
	and ed.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
	and ed.active_ind 			= 1

join e
	where e.encntr_id = ed.encntr_id
	and e.encntr_type_cd 		in (ENC_INPATIENT, ENC_EMERGENCY);003
	and e.encntr_status_cd		!= ENC_CANCELLED
	and e.active_ind 			= 1

JOIN EA
	WHERE EA.encntr_id 			= e.encntr_id
	and EA.Encntr_alias_type_cd = MRN_CD
	and EA.ACTIVE_IND 			= 1
	AND CNVTDATETIME(CURDATE, CURTIME3)between Ea.BEG_EFFECTIVE_DT_TM and ea.END_EFFECTIVE_DT_TM

JOIN p
	WHERE p.person_id 			= e.person_id
	AND p.active_ind 			= 1

join o
	where o.encntr_id 			= e.encntr_id
	and o.order_status_cd 		IN (ord_ordered_status_cd, ord_pendcompl_status_cd)
	and o.template_order_id 	= 0  ;no child orders
	and o.orig_ord_as_flag 		= 0   ;normal order (not discharge prescription, patient own meds etc)
	and o.catalog_type_cd 		= MEDS ;Pharmacy

join cp
	where cp.catalog_cd = o.catalog_cd		;Filtered by Antimicrobial Primaries

join ocs
	where ocs.synonym_id = o.synonym_id		;only because I need the mnemonic_type_cd
	and ocs.active_ind = 1

join ocsf


ORDER BY o.order_id
;	e.encntr_id
;	, o.order_id

;----------------------------------------------------------------------------------

HEAD REPORT

	cnt = 0

;DETAIL
Head o.order_id

		if (($FS = 0.0) 									;Any
			or (ocsf.inpatient_formulary_status_cd = $FS))  ;or what was in the Prompt

			cnt = cnt + 1

			If (Mod(cnt,100) = 1)
	 			Stat = Alterlist(OrdersRec->lst,Cnt + 99)
			EndIf

 			OrdersRec->lst[cnt].encntr_id = e.encntr_id
 			OrdersRec->lst[cnt].person_id = e.person_id
	    	OrdersRec->lst[cnt].PatientName = p.name_full_formatted
	    	OrdersRec->lst[cnt].DOB = format(p.birth_dt_tm, "DD/MM/YYYY")
			OrdersRec->lst[cnt].MRN = ea.alias
	    	OrdersRec->lst[cnt].Facility = uar_get_code_display(e.loc_facility_cd)
	    	OrdersRec->lst[cnt].Location = uar_get_code_display(e.loc_nurse_unit_cd)
	    	OrdersRec->lst[cnt].Room = uar_get_code_display(e.loc_room_cd)
	    	OrdersRec->lst[cnt].Bed = uar_get_code_display(e.loc_bed_cd)
			OrdersRec->lst[cnt].clinicalUnit = substring(1,200,uar_get_code_display(e.med_service_cd))
			OrdersRec->lst[cnt].admit_dttm = format(e.reg_dt_tm, "DD/MM/YYYY hh:mm")
			OrdersRec->lst[cnt].EncntrType = trim(UAR_GET_CODE_DISPLAY(e.encntr_type_cd))
			OrdersRec->lst[cnt].OrderId  = o.order_id
			OrdersRec->lst[cnt].Order_status = uar_get_code_display(o.order_status_cd)
			OrdersRec->lst[cnt].formulary_status = uar_get_code_display(ocsf.inpatient_formulary_status_cd)
			OrdersRec->lst[cnt].MedsOrders = trim(o.simplified_display_line)
			OrdersRec->lst[cnt].FirstDose_dttm = format(o.current_start_dt_tm,"dd/mm/yyyy hh:mm")
			OrdersRec->lst[cnt].StopDose_dttm = format(o.projected_stop_dt_tm,"dd/mm/yyyy hh:mm")
			OrdersRec->lst[cnt].order_dttm = format(o.orig_order_dt_tm,"dd/mm/yyyy hh:mm")
 			OrdersRec->lst[cnt].pri_cat_cd = o.catalog_cd

 			OrdersRec->lst[cnt].synonym_id = o.synonym_id
 			OrdersRec->lst[cnt].synonym_mn_type = uar_get_code_meaning(ocs.mnemonic_type_cd)
			OrdersRec->lst[cnt].ordered_as =
 				if(OrdersRec->lst[cnt].synonym_mn_type in ("BRANDNAME", "TRADETOP"));Trade/Brand/Name
 					concat(trim(o.hna_order_mnemonic), " (", trim(o.ordered_as_mnemonic), ")")
 				else trim(o.ordered_as_mnemonic)
 				endif

 			OrdersRec->lst[cnt].ord_details =
 				concat(OrdersRec->lst[cnt].ordered_as, char(10), char(13), "   ", trim(o.simplified_display_line))

 			OrdersRec->lst[cnt].FirstDose_dttm_rtf = ;set "IsRTF" = "Yes" in Layout Builder
 				if(datetimediff(CNVTDATETIME(CURDATE, CURTIME3),o.current_start_dt_tm,3) > 72)
 					concat( _rtfstart, _rtfbold, " ", format(o.current_start_dt_tm,"dd/mm/yyyy hh:mm"), _rtfboldend, _rtfend )
 				else concat( _rtfstart, " ", format(o.current_start_dt_tm,"dd/mm/yyyy hh:mm"), _rtfend)
 				endif

		endif

FOOT REPORT
 	OrdersRec->Cnt = cnt
	Stat = Alterlist(OrdersRec->lst,Cnt)

WITH nocounter, orahintcbo("TEST_QUERY1")


;-------------------------------------------------------------------------------------------------
; add/filter by Therapeutic Class Here
; and only print if OrdersRec->lst[].TC_tier1_asc_id >0 or// OrdersRec->lst[].TC_tier1 populated

Set PrintCount = 0

select into "nl:"
from
	(dummyt d with seq=value(OrdersRec->Cnt))
	,cust_AM_Syn cs

plan d where OrdersRec->lst[d.seq].pri_cat_cd != 0

join cs
	where cs.catalog_cd = OrdersRec->lst[d.seq].pri_cat_cd
	;and (cs.tc_tier1_id = $TC1) or ($TC1 = 0.0)	;doesn't work here if select more than one TC
													;neither does OPERATOR work on this custom table

order by cs.syn_tc_cnt desc

detail

	if ((cs.tc_tier1_id = $TC1)or ($TC1 = 0.0))					;filter by Therapeutic Class prompt seletions
		OrdersRec->lst[d.seq].TC_tier1 = cs.tc_tier1			;nominal!
		OrdersRec->lst[d.seq].TC_tier1_asc_id = cs.tc_tier1_id 	;nominal!
		PrintCount = PrintCount + 1
	endif

with nocounter

;-------------------------------------------------------------------------------------------------
; add indication
; call echo("Loading latest Indication .......")

Select into "nl:"

from
	 orders o
	,order_detail od

plan  o
	where  expand(num,1,ordersrec->cnt,o.order_id,ordersrec->lst[num].OrderId)

join od
	where od.order_id = o.order_id
	and od.oe_field_id = INDICATION_CD
	and od.action_sequence = (select max(odx.action_sequence)
									from order_detail odx
									where odx.order_id = o.order_id
									and odx.oe_field_id  = INDICATION_CD )
order by o.order_id

head o.order_id
	pos = locateval(idx,1,OrdersRec->Cnt,o.order_id,OrdersRec->lst[idx].OrderId)
	OrdersRec->lst[pos].Indication  = trim(od.oe_field_display_value)

with nocounter

;------------------------------------------------------------------------------------------------
; add approval no

Select into "nl:"

from
	 orders o
	,order_detail od

plan o
	where expand(num,1,ordersrec->cnt,o.order_id,ordersrec->lst[num].OrderId)

join od
	where od.order_id = o.order_id
	and od.oe_field_id = APPROVAL_CD
	and od.action_sequence = (select max(odx.action_sequence)
	   							from order_detail odx
								where odx.order_id = o.order_id
								and odx.oe_field_id  = APPROVAL_CD )
order by o.order_id

head o.order_id

	pos = locateval(idx,1,OrdersRec->Cnt,o.order_id,OrdersRec->lst[idx].OrderId)
	OrdersRec->lst[pos].ApprovalNum   = trim(od.oe_field_display_value)

with nocounter

;call echorecord(ordersrec)

;-------------------------------------------------------------------------------------------------
;Output

if (PrintCount > 0)

	if ($CSV = 1)
		go to 666_CSV 		;CSV output
 	else					;Printed Report
		execute vic_au_antimicrobial_lyt $outdev
	endif

Else
	;No Printable Data
	set hbar = fillstring(60,"=")
	select into value($outdev)
  	from (dummyt d with seq = 1)
  	detail
  		row+1, col 10, CURPROG, col 54, SYSDATE "dd/mm/yyyy hh:mm;;d"
  		row+2, col 10, hbar
  		row+1, col 10, "No data qualified for this report."
  		row+1, col 10, "Please check your Prompt choices and try again."
  		row+1, col 10, hbar
  		row+2, col 10, "Prompt choices:"
  		row+2, col 10, "Facility:"
  		row+1, col 20, OrdersRec->Facility
  		row+2, col 10, "Wards:"
  		row+1, col 20, OrdersRec->Wards
  		row+2, col 10, "Clinical Units:"
  		row+1, col 20, OrdersRec->Clinical_Units
  		row+2, col 10, "Therapeutic Classes:"
  		row+1, col 20, OrdersRec->TC_Choice
  		row+2, col 10, "Formulary Status:"
  		row+1, col 20, OrdersRec->FS_Choice
  		row+2, col 10, hbar
  		row+2, col 10, "Printed by: ", OrdersRec->User_Name
	with nocounter
Endif

go to 999_End
;-------------------------------------------------------------------------------------------------
;CSV Output
#666_CSV

	select into $outdev

			;printable items:
			P_User_Name = OrdersRec->User_Name
			,P_Facility = OrdersRec->Facility
			,P_Wards = OrdersRec->Wards
			,P_Clinical_Units = OrdersRec->Clinical_Units
			,P_TClasses = OrdersRec->TC_Choice
			,P_FS_Status = OrdersRec->FS_Choice
 			,Facility = substring(1,200,OrdersRec->lst[d.seq].Facility)
 			,ClinicalUnit = substring(1,200,OrdersRec->lst[d.seq].ClinicalUnit)
			,Location = substring(1,200,OrdersRec->lst[d.seq].Location )
			,Room = trim(OrdersRec->lst[d.seq].Room )
			,Bed = trim(OrdersRec->lst[d.seq].Bed )
			,MRN = OrdersRec->lst[d.seq].MRN
			,Patient_Name = substring(1,300,OrdersRec->lst[d.seq].PatientName)
			,DOB = OrdersRec->lst[d.seq].DOB
			,Formulary_Status = OrdersRec->lst[d.seq].formulary_status
			,Drug = substring(1,200,OrdersRec->lst[d.seq].ordered_as)
			,Order_Detail = substring(1,300,OrdersRec->lst[d.seq].MedsOrders)
			,Indication = substring(1,100,OrdersRec->lst[d.seq].Indication)
			,Approval = substring(1,100,OrdersRec->lst[d.seq].ApprovalNum)
			,first_dose_dt_tm = OrdersRec->lst[d.seq].FirstDose_dttm
			,Stop_dose_dt_tm = OrdersRec->lst[d.seq].StopDose_dttm

			;For debugging:
			;,P_User_Name = OrdersRec->User_Name
 			,Admit_dt_tm = OrdersRec->lst[d.seq].Admit_dttm
			,orderid = OrdersRec->lst[d.seq].OrderId
			,Order_status = OrdersRec->lst[d.seq].Order_status
			,order_dt_tm = OrdersRec->lst[d.seq].order_dttm
			,EncntrType = OrdersRec->lst[d.seq].EncntrType
			,Actual_Synonym_id = OrdersRec->lst[d.seq].synonym_id
			,Actual_Synonym_Type = OrdersRec->lst[d.seq].synonym_mn_type
			,Nominal_TC_Tier1 = OrdersRec->lst[d.seq].TC_tier1				;nominal !
			;,Nominal_TC_Tier1_id = OrdersRec->lst[d.seq].TC_tier1_asc_id	;nominal !
			;,first_dose_dttm_rtf = OrdersRec->lst[d.seq].FirstDose_dttm_rtf


	from (dummyt d with seq = value(OrdersRec->Cnt))
	Where OrdersRec->lst[d.seq].TC_tier1_asc_id > 0 ;Selected Therapeutic Classes only
	;where OrdersRec->lst[d.seq].pri_cat_cd > 0 ;test only

	Order by
			Location
			,Patient_Name
			,first_dose_dt_tm

	with format, separator = " ", nocounter

	go to 999_End

;-------------------------------------------------------------------------------------------------
;Order_Catalog Antimicrobial Primaries Audit
#888_OC_Audit

SELECT distinct into $outdev

	Order_Catalog_Primary 		= cs.mnemonic
	, Synonym_TClass_Tier1 		= cs.tc_tier1 ;may be more than one - only show one.

FROM cust_am_syn cs
;where cs.syn_tc_cnt = 1
ORDER BY cs.mnemonic, cs.tc_tier1
with format, check

;-------------------------------------------------------------------------------------------------
#999_End

free record OrdersRec
end
go
