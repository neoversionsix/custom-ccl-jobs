/**************************************************************
 Report Name : Antimicrobial Active AMS Orders

***************************************************************
 Mod Date       Programmer	Comment
 ----------- --------------  ----------------------------------

001 27 MAY 2024	 Matt Costa	[Initial Version]


*************************************************************** */

drop program wh_med_ams_active_ord:group1  go
create program wh_med_ams_active_ord:group1

prompt
	"Output to" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "AMS Type" = 0
	, "Facility" = 0

with OUTDEV, OEF, Facc

declare 	rec_cnt = f8
set 		rec_cnt 0
declare 	num = i4
declare		numb = i4

record outrec (
	1 cnt = i4
	1 alist[*]

	2 idx = f8
	2 order_id = f8
	2 orig_order_dt_tm = dq8
	2 order_mnemonic = c130
	2 order_status = c130
	2 dept_status = c130
	2 order_detail_display_line = c999
	2 template_order_flag = i4
	2 order_type = c130
	2 admin_order_id = f8
	2 ce_event = f8
	2 person_id = f8
	2 encntr_id = f8
	2 allergy = vc
	2 Approval_Number = vc
	2 curr_start = dq8
	2 proj_stop = dq8
	2 synonym_id = f8
	2 OEF = c160
	2 OEF_id = f8
	2 AMS_Indication = c160
	2 ODD = c999
	2 ODD_Cnt = f8

	2 CDL = c999
	2 DML = c999
	2 SDL = c999

	2 ID_Approval_Exp = c160

	)

;Get Orders
select into 'nl:'

	  o.order_id
	, o.orig_order_dt_tm
	, order_mnemonic = o.ordered_as_mnemonic
	, order_status=uar_get_code_display(o.order_status_cd)
	, dept_status=uar_get_code_display(o.dept_status_cd)
	, o.order_detail_display_line
	, order_type = evaluate (o.orig_ord_as_flag,
		0, "Normal Order",
		1, "Prescription/Discharge Order",
		2, "Recorded / Home Meds",
		3, "Patient Owns Meds",
		4, "Pharmacy Charge Only",
		5, "Satellite (Super Bill) Meds"
		)
	, curr_start = o.current_start_dt_tm
	, proj_stop = o.projected_stop_dt_tm
	, o.synonym_id

from orders o
	where o.oe_format_id in (
		   87593612
		,  114116148
		,  87593615
		,  87593616
		,  114116163
		,  87593617
		)

	and (
			($oef = 1 ;Highly Restricted
			and o.oe_format_id in (
			 87593612	;Pharmacy Strength Med (Highly Restricted AMS)
			,87593616	;Pharmacy Volume Med (Highly Restricted AMS)
			))
			or ($oef = 2 ;Mandatory Indication
			and o.oe_format_id in (
			 114116148	;Pharmacy Strength Med (Mandatory Indication AMS)
			,114116163	;Pharmacy Volume Med (Mandatory Indication AMS)
			))
			or ($oef = 3 ;Restricted
			and o.oe_format_id in (
			 87593615	;Pharmacy Strength Med (Restricted AMS)
			,87593617	;Pharmacy Volume Med (Restricted AMS)
			))
			or ($oef = 4 ;Highly Restricted & Restricted
			and o.oe_format_id in (
			 87593615	;Pharmacy Strength Med (Restricted AMS)
			,87593617	;Pharmacy Volume Med (Restricted AMS)
			,87593612	;Pharmacy Strength Med (Highly Restricted AMS)
			,87593616	;Pharmacy Volume Med (Highly Restricted AMS)
			))
			or ($oef = 123) ; Any
		)



	and o.template_order_id = 0
	and o.order_id > 0
	and o.orig_ord_as_flag = 0
	and o.order_status_cd = 2550 ;Ordered

	and o.encntr_id in (
;	select encntr_id from encntr_alias where alias = 'IPE5618935'

		select e.encntr_id
		from encounter e
		where e.encntr_status_cd != 856 ;Discharged
		and e.encntr_type_cd in ( 309310, 309308) ;Emergency/Inpatient
		and e.active_ind = 1
		and e.depart_dt_tm is null
		and e.disch_dt_tm is null
		and (e.loc_facility_cd = $facc or $facc = 123)
		)


order by o.order_id

detail
	rec_cnt = rec_cnt +1
	if(mod(rec_cnt,10)=1)
	stat = alterlist(outrec->alist,rec_cnt+9)
	endif
	outrec->cnt = rec_cnt
	outrec->alist[rec_cnt].idx = 						rec_cnt
	outrec->alist[rec_cnt].order_id = 					o.order_id
	outrec->alist[rec_cnt].orig_order_dt_tm = 			o.orig_order_dt_tm
	outrec->alist[rec_cnt].order_mnemonic = 			o.ordered_as_mnemonic
	outrec->alist[rec_cnt].order_status = 				order_status
	outrec->alist[rec_cnt].dept_status = 				dept_status
	outrec->alist[rec_cnt].order_detail_display_line = 	substring(1,999,o.order_detail_display_line)
	outrec->alist[rec_cnt].template_order_flag = 		o.template_order_flag
	outrec->alist[rec_cnt].order_type = 				order_type
	outrec->alist[rec_cnt].person_id = 					o.person_id
	outrec->alist[rec_cnt].encntr_id = 					o.encntr_id
	outrec->alist[rec_cnt].curr_start = 				curr_start
	outrec->alist[rec_cnt].proj_stop = 					proj_stop
	outrec->alist[rec_cnt].oef_id = 					o.oe_format_id
	outrec->alist[rec_cnt].synonym_id = 				o.synonym_id

	outrec->alist[rec_cnt].CDL = 						o.clinical_display_line
	outrec->alist[rec_cnt].DML = 						o.dept_misc_line
	outrec->alist[rec_cnt].SDL = 						o.simplified_display_line


with time = 130, uar_code(d), format(date,";;q")


;Update allergies and concat multiples
declare ssa_len = f8
	set ssa_len = 0
declare ssa_val = vc

select into 'nl:'

 	idx = locateval(num,1,outrec->cnt,
		 a.person_id	,outrec->alist[num].person_id
		)
	, a.person_id

from allergy a
	,(left join nomenclature n on n.nomenclature_id = a.substance_nom_id)

plan a
	where expand(num,1,outrec->cnt,
			 a.person_id	,outrec->alist[num].person_id
			)
	and a.reaction_status_cd != 3300 ;Cancelled
	and a.active_ind =1

join n
order by a.person_id, trim(a.substance_ftdesc), trim(n.source_string)

head a.person_id

	if(idx>0) numb = idx else numb = null endif
	ssa_val = ''

detail
	ssa_val=concat(
		trim(ssa_val)
			,if(ssa_val = '') '' else ', ' endif
		,trim(n.source_string)
			,if(a.substance_ftdesc is null) '' else ', ' endif
		,trim(a.substance_ftdesc)
	)

foot a.person_id
	outrec->alist[numb].allergy = trim(ssa_val,3)

with time = 120, separator=" ", format,  expand = 1



;Add Approval Number, AMS_Indication, ODD
declare odd_val = vc
set 	odd_val = ''
declare odd_cnt = f8
set 	odd_cnt = 0

select into 'nl:'
 	idx = locateval(num,1,outrec->cnt,
		 od.order_id	,outrec->alist[num].order_id
		)
		, od.oe_field_id
		, od_agg =  listagg(od.oe_field_display_value,', ') over
			(partition by od.order_id,od.oe_field_id order by od.action_sequence desc)

		,last_seq_flag = row_number() over (partition by od.order_id, od.oe_field_id order by od.action_sequence desc )

from order_detail od
plan od
	where expand(num,1,outrec->cnt,
		 od.order_id	,outrec->alist[num].order_id
		)
	and od.oe_field_id in (
		 26784179 	; Approval Number
		,138010668 	; AMS_Indication
		,116270335	;ID Approval Expiry (7:30 AM)
		)


head report
	numb = 0

head 	od.order_id ;clear ODD variable per order id pass
		odd_val	= ''
		numb = idx

head od.oe_field_id
	odd_cnt = 0

detail
	if(idx>0) numb = idx ;Only update records with valid index
		if(od.oe_field_id = 26784179) ; Approval Number
		outrec->alist[numb].Approval_Number = od_agg
		elseif (od.oe_field_id = 138010668) ; AMS_Indication
		outrec->alist[numb].AMS_Indication = od_agg
		elseif (od.oe_field_id = 116270335 and last_seq_flag = 1) ;ID Approval Expiry (7:30 AM)
		outrec->alist[numb].ID_Approval_Exp = od.oe_field_display_value
		endif
	endif


foot 	od.order_id
	outrec->alist[numb].odd 	= odd_val
	outrec->alist[numb].odd_cnt = odd_cnt

with time = 120, separator=" ", format, expand = 1



;Index OEF
record oef (
	1 cnt = i4
	1 alist[*]
	2 oef_id = f8
	2 oef_name = c250
	)
	declare 	oef_rec_cnt = f8
	set 		oef_rec_cnt = 0
	declare		oef_index	= f8
	set 		oef_index 	= 0

select into 'nl:'
		  oef_id	= oef.oe_format_id
		, oef_name	= oef.oe_format_name
	from order_entry_format oef
	where oef.action_type_cd = 2534
	and oef.oe_format_id in (
			   87593612
			,  114116148
			,  87593615
			,  87593616
			,  114116163
			,  87593617
			)
detail
	oef_rec_cnt = oef_rec_cnt +1
	if(mod(oef_rec_cnt,10)=1)
	stat = alterlist(oef->alist,oef_rec_cnt+9)
	endif
	oef->alist[oef_rec_cnt].oef_id = oef_id
	oef->alist[oef_rec_cnt].oef_name = oef_name
	oef->cnt = oef_rec_cnt

with time = 30, uar_code(d)

;Index therapeutic class
record class (
	1 cnt = i4
	1 alist[*]
	2 ocs_id = f8
	2 class = c250
	)
	declare 	class_rec_cnt = f8
	set 		class_rec_cnt = 0
	declare		class_index	= f8
	set 		class_index = 0


select into 'nl:'

	cat.long_description
	, ocs.mnemonic
	, ocs.synonym_id

from order_catalog_synonym ocs, alt_sel_list list, alt_sel_cat cat

where 	expand(num,1,outrec->cnt,
		 ocs.synonym_id	,outrec->alist[num].synonym_id
		)
	and list.synonym_id = ocs.synonym_id and list.list_type = 2
	and cat.alt_sel_category_id = list.alt_sel_category_id
	and cat.owner_id = 0 and cat.ahfs_ind = 1

detail
	class_rec_cnt = class_rec_cnt +1
	class->cnt = class_rec_cnt
	if(mod(class_rec_cnt,10)=1)
	stat = alterlist(class->alist,class_rec_cnt+9)
	endif

	class->alist[class_rec_cnt].ocs_id 	= ocs.synonym_id
	class->alist[class_rec_cnt].class 	= cat.long_description

with time = 30, uar_code(d), format, separator = " "


;Send final output
select into $outdev ;

	 facility = uar_get_code_display(e.loc_facility_cd)
	,nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
	,med_service =uar_get_code_display( e.med_service_cd )
	,URN = ea_URN.alias

;	,odd = substring(1,999,outrec->alist[d.seq].odd)
;	,odd_cnt = outrec->alist[d.seq].odd_cnt

	,name = p.name_full_formatted
	,allergy = trim(
	substring(1,999,
	outrec->alist[
		locateval(num,1,outrec->cnt,
		 outrec->alist[d.seq].person_id	,outrec->alist[num].person_id
		)].allergy
		))

	,Order_placed_dt_tm = outrec->alist[d.seq].orig_order_dt_tm "@LONGDATETIME"
	,Ordered_as = outrec->alist[d.seq].order_mnemonic

	,Order_details = outrec->alist[d.seq].SDL
	,AMS_Indication = substring(1,999,outrec->alist[d.seq].AMS_Indication)
	,ID_Approval_Exp = outrec->alist[d.seq].ID_Approval_Exp
	,Approval_Number = substring(1,999,outrec->alist[d.seq].Approval_Number)

	,start_dose = outrec->alist[d.seq].curr_start "@LONGDATETIME"
	,stop_dose = outrec->alist[d.seq].proj_stop "@LONGDATETIME"
	,therapeutic_class =  class->alist[
		locateval(num,1,class->cnt,
		   outrec->alist[d.seq].synonym_id, class->alist[num].ocs_id
		)].class
;	,order_synonym = outrec->alist[d.seq].synonym_id

	,Encounter = ea_visit.alias
	,order_id = outrec->alist[d.seq].order_id
	;,order_status = outrec->alist[d.seq].order_status
	,OEF = oef->alist[
		locateval(num,1,oef->cnt,
		   outrec->alist[d.seq].oef_id, oef->alist[num].oef_id
		)].oef_name

;	, CDL = outrec->alist[d.seq].CDL
;	, SDL = outrec->alist[d.seq].SDL
;	, order_detail_display = substring(1,999,outrec->alist[d.seq].order_detail_display_line)

 from (dummyt d with seq = value(outrec->cnt))
 ,encntr_alias ea_URN
 ,encntr_alias ea_visit
 ,encounter e
 ,person p

 plan d
 join ea_urn where ea_URN.encntr_id = outrec->alist[d.seq].encntr_id
	and ea_URN.encntr_alias_type_cd = 1079	; 'URN' from code set 319
	and ea_URN.active_ind = 1	; active URNs only
	and ea_URN.end_effective_dt_tm > sysdate	; effective URNs only

 join ea_visit where ea_visit.encntr_id = outrec->alist[d.seq].encntr_id
		and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
		and ea_visit.active_ind = 1	; active FIN NBRs only
		and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only

 join e where e.encntr_id = outrec->alist[d.seq].encntr_id
; 	and (e.loc_facility_cd = $facc or $facc = 123)
 join p where p.person_id = outrec->alist[d.seq].person_id and p.active_ind = 1
; 	and cnvtupper(p.name_full_formatted) = 'TESTWHS*WILLIAM_MEDORDER*'

 order by outrec->alist[d.seq].person_id,Order_placed_dt_tm, order_id

with time = 300,  uar_code(d), format, separator = " "


;*/
end
go
