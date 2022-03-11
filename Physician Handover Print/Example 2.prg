/****************************************************************************************************************
		 Copyright Notice:			Children's Hospital of the King's Daughters Health System (CHKDHS)
*****************************************************************************************************************
 
		 Author:       				DeAnn Capanna
		 Date Written:  			03/25/2020
		 Source file name: 			chkd_amb_mp_physhandoff_prnt.prg
		 Object name:   			chkd_amb_mp_physhandoff_prnt
 
 		 Translated from:			N/A
 
 		 Requested by:				Stephenie Shaw/Maurica Madison
 
		 Program purpose:			CHKD custom print layout for the physician handoff. MPage.
 
		 Special Notes:				N/A
 
;****************************************************************************************************************
 
                                           MODIFICATION CONTROL LOG
 
;****************************************************************************************************************
 
   Ver  Date            Engineer                Description
   ---  --------------- ----------------------- ----------------------------------------------------------------
   001  03/25/2020      DeAnn Capanna	    	Initial Release
   005  06/12/2020      DeAnn Capanna		    Reports Request ID #2455 - Additions per Stephenie's spreadsheet
   																	       attached to change request.
 
;***************************************************************************************************************/
drop program chkd_amb_mp_physhandoff_dc:DBA go
create program chkd_amb_mp_physhandoff_dc:DBA
/*===============================================================================================================
 
                                          		     PROMPTS
 
===============================================================================================================*/
prompt
	"Output to File/Printer/MINE" = "MINE" ,
  	"JSON Request:" = ""
with outdev ,jsondata
 
call echo(concat("START:    ", format(cnvtdatetime(curdate, curtime), "HH:MM:SS;;D")))
/*===============================================================================================================
 
                                          		DEFINED RECORDSETS
 
===============================================================================================================*/
free set data
;Declare Records
record data (
	1 cnt						= i4
  	1 list[*]
    	2 person_id				= f8
    	2 encntr_id				= f8
    	2 unit_id				= f8
    	2 unit_disp				= vc
    	2 room_id				= f8
    	2 room_disp				= vc
 
    	2 location				= vc
		2 nurse_unit			= vc
		2 pod					= vc
		2 room					= vc
		2 bed					= vc
 
    	2 patient_name			= vc
    	2 age					= vc
    	2 dob					= vc
    	2 gender				= vc
    	2 mrn					= vc
    	2 fin 					= vc
    	2 med_service			= vc
    	2 admitting_pcp			= vc
    	2 dosing_weight			= vc
    	2 illness_severity		= vc
    	2 primary_contact		= vc
    	2 diagnosis				= vc
    	2 code_status			= vc
    	2 admit_dt_tm			= dq8
    	2 admit_dt_tm_disp		= vc
    	2 patient_summary		= vc
    	2 sit_aware_cnt			= i4
    	2 sit_aware[*]
      		3 comment			= vc
    	2 actions_cnt			= i4
    	2 actions[*]
      		3 action			= vc
    	2 allergy_cnt			= i4
    	2 allergies[*]
      		3 allergy			= vc
    	2 diag_cnt				= i4
    	2 diags[*]
      		3 diag				= vc
 
      	;****
 
		2 doccnt				= i2
		2 documentation[*]
			3 doc				= vc
 
		2 ventilator_settings	= vc
 
		2 expiring_orders		= vc
		2 expordcnt				= i2
		2 exp_orders[*]
			3 order_mnemonic	= vc
			3 order_id			= f8
 
		2 chronic_problems		= vc
		2 prbcnt				= i2
		2 chron_prbs[*]
			3 chronic_problem	= vc
 
 		;v5 DeAnn
		2 all_meds				= vc
		2 med_cnt				= i2
		2 prn_total				= i2
		2 meds[*]
			3 catalog_cd 		= f8
       		3 encntr_id 		= f8
	       	3 catalog_type_cd 	= f8
	       	3 activity_type_cd 	= f8
	       	3 order_id 			= f8
	       	3 mnemonic 			= vc
	       	3 mnem_cnt 			= i2
	       	3 mnem_tag [*]
	         	4 mnem_line 	= vc
	       	3 frequency 		= vc
	       	3 dose 				= vc
	       	3 doseunit 			= vc
	       	3 route 			= vc
	       	3 display_line 		= vc
	       	3 dl_cnt 			= i2
	       	3 dl_tag [*]
	         	4 dl_line 		= vc
	       	3 dnum 				= vc
	       	3 iv_ind 			= i2
	       	3 prn_ind 			= i2
	       	3 titrate_ind 		= i2
	       	3 titrate_name 		= vc
	       	3 titrate_catalog_cd= f8
	       	3 print_line 		= vc
	       	3 order_status 		= vc
	       	3 dept_order_status = vc
	       	3 current_start_dt_tm = vc
	       	3 projected_stop_dt_tm = vc
	       	3 prn_reason 		= vc
	       	3 ord_as_mnemonic 	= vc
	       	3 stop_type_cd 		= f8
	       	3 synonym 			= vc
	       	3 drugform 			= vc
	       	3 vol_dose 			= vc
	       	3 vol_dose_unit 	= vc
	       	3 med_order_type_cd = f8
	       	3 rate 				= vc
	       	3 rate_unit 		= vc
	       	3 print_flag 		= c1
 		;v5 DeAnn
		2 mc_cnt				= i2
		2 prn_total				= i2
		2 med_cats[*]
			3 ord_cnt			= i2
			3 category			= vc
			3 med_disp[*]
				4 order_id		= vc
       			4 display_line 	= vc
 
       	2 prn_cnt				= i2
       	2 prn[*]
       		3 order_id			= f8
       		3 catalog_cd		= f8
       		3 prn_admin_cnt		= i2
       		3 prn_admins[*]
       			4 admin_dt_tmdq8= dq8
       		3 display_line		= vc
       	2 sched_cnt				= i2
       	2 sched[*]
       		3 order_id			= f8
       		3 display_line		= vc
       	2 unsched_cnt			= i2
       	2 unsched[*]
       		3 order_id			= f8
       		3 display_line		= vc
       	2 cont_cnt				= i2
       	2 cont[*]
       		3 order_id			= f8
       		3 display_line		= vc
 
       	2 prn2_cnt				= i2
       	2 prn2[*]
       		3 order_id			= f8
       		3 catalog_cd		= f8
       		3 prn_disp			= vc
       		3 prn_admin_cnt		= i2
       		3 prn_admins[*]
       			4 admin_dt_tmdq8= dq8
       		3 display_line		= vc
       	2 sched2_cnt			= i2
       	2 sched2[*]
       		3 order_id			= f8
       		3 display_line		= vc
       	2 unsched2_cnt			= i2
       	2 unsched2[*]
       		3 order_id			= f8
       		3 display_line		= vc
       	2 cont2_cnt				= i2
       	2 cont2[*]
       		3 order_id			= f8
       		3 display_line		= vc
 
		;Lab results
		2 lr_cnt = i2
     	2 lab_result[*]
       		3 event_cd = f8
       		3 task_assay_cd = f8
       		3 task_assay_disp = vc
       		3 catalog_cd = f8
       		3 catalog_disp = vc
       		3 encntr_id = f8
       		3 lr_line_cnt = i4
       		3 event_name = vc
       		3 event_cd = f8
       		3 event_set_cd = f8
    		3 ex_event_set_disp = vc
    		3 event_set_level = i4
   			3 parent_event_set_disp = vc
   			3 parent_event_set_cd = f8
   			3 lr_group_seq = i4
   			3 es3_parent_event_set_disp = vc
   			3 es4_parent_event_set_disp = vc
   			3 es3_event_set_collating_seq = i4
   			3 es4_event_set_collating_seq = i4
       		3 en_cnt = i2
       		3 en_tag[*]
         		4 en_line = vc
       		3 result_value = vc
       		3 rv_cnt = i2
       		3 rv_tag[*]
         		4 rv_line = vc
       		3 order_id = f8
       		3 verify_dt_tm = vc
       		3 event_end_dt_tm = vc
       		3 lab_result_dt_grp_id = i4
       		3 normalcy_disp = vc
       		3 ref_range = vc
       		3 rr_cnt = i2
       		3 rr_tag[*]
         		4 rr_line = vc
       		3 note = vc
       		3 print_line = vc
       		3 pl_cnt = i2
       		3 pl_tag[*]
         		4 pl_line = vc
       		3 print_line_fb = vc
       		3 print_flag = c1
       		3 task_assay_cd = f8
       		3 task_assay_key = vc
       		3 task_assay_display = vc
 
       		;Get last 3 results
       		3 result1 = vc
       		3 event_end_dt_tm1 = vc
       		3 event_end_dt_tm1_dq8 = dq8
       		3 normalcy_disp1 = vc
       		3 result2 = vc
       		3 event_end_dt_tm2 = vc
       		3 event_end_dt_tm2_dq8 = dq8
       		3 normalcy_disp2 = vc
       		3 result3 = vc
       		3 event_end_dt_tm3 = vc
       		3 event_end_dt_tm3_dq8 = dq8
       		3 normalcy_disp3 = vc
 
       		3 e_dt[*]
       			4 result_value = vc
       			4 event_end_dt_tm = vc
       			4 event_end_dt_tm_dq8 = dq8
       			4 order_id = f8
       			4 verify_dt_tm = vc
       			4 ref_range = vc
       			4 print_line_fb = vc
       			4 print_line = vc
       			4 normalcy_disp = vc
 
       		;sorted lab results by cn_parent_event_set_disp
       		2 lab_result2[*]
	       		3 event_cd = f8
	       		3 encntr_id = f8
	       		3 lr_line_cnt = i4
	       		3 event_name = vc
	       		3 event_cd = f8
	       		3 event_set_cd = f8
	    		3 ex_event_set_disp = vc
	    		3 event_set_level = i4
	   			3 es3_parent_event_set_disp = vc
   			3 es3_event_set_collating_seq = i4
   			3 es4_event_set_collating_seq = i4
	   			;Get last 3 results
	       		3 result1 = vc
	       		3 event_end_dt_tm1 = vc
	       		3 event_end_dt_tm1_dq8 = dq8
	       		3 normalcy_disp1 = vc
	       		3 result2 = vc
	       		3 event_end_dt_tm2 = vc
	       		3 event_end_dt_tm2_dq8 = dq8
	       		3 normalcy_disp2 = vc
	       		3 result3 = vc
	       		3 event_end_dt_tm3 = vc
	       		3 event_end_dt_tm3_dq8 = dq8
	       		3 normalcy_disp3 = vc
 		2 lrgrp_cnt			= i2
       	2 lrgrp[*]
       			3 lr_group		= vc
       			3 group_collating_seq = i4
       			3 event_cnt = i4
       			3 evnts[*]
	       			4 event_name = vc
	       			4 event_cd = f8
	       			4 task_assay_cd = f8
	       			4 task_assay_disp = vc
	       			4 catalog_cd = f8
	       			4 catalog_disp = vc
	       			4 event_seq = i4
	       			4 event_seq_disp = vc
		   			;Get last 3 results
		       		4 result1 = vc
		       		4 event_end_dt_tm1 = vc
		       		4 event_end_dt_tm1_dq8 = dq8
		       		4 normalcy_disp1 = vc
		       		4 result2 = vc
		       		4 event_end_dt_tm2 = vc
		       		4 event_end_dt_tm2_dq8 = dq8
		       		4 normalcy_disp2 = vc
		       		4 result3 = vc
		       		4 event_end_dt_tm3 = vc
		       		4 event_end_dt_tm3_dq8 = dq8
		       		4 normalcy_disp3 = vc
 
       	;Micro results
       	2 mb_cnt = i2
     	2 micro_result[*]
       		3 parent_event_id = f8
       		3 event_id = f8
       		3 event_cd = f8
       		3 event_name = vc
       		3 date_update = vc
       		3 date_collect = vc
       		3 clinsig_dt_tm = vc
       		3 event_start_dt_tm = vc
       		3 event_end_dt_tm = vc
       		3 verified_dt_tm = vc
       		3 event_title_text = vc
       		3 accession = vc
       		3 form_yes = i2
       		3 result_val = c44
	       	3 update_date = c5
	       	3 result_status = vc
	       	3 specimen_desc = vc
	       	3 sensi_ind = i2
	       	3 event_tag = vc
	       	3 blob_contents = vc
	       	3 compression_cd = f8
	       	3 positive_ind = i2
	       	3 micro_line_cnt = i2
	       	3 temp_disp = vc
	       	3 micro_line [*]
         		4 text = vc
 
        ;I&O results
       	2 io_cnt = i2
       	2 i_tot_vol = f8
       	2 o_tot_vol = f8
     	2 io_result[*]
       		3 i_result = f8
       		3 o_result = f8
 
) with protect
 
 
FREE RECORD ce_data
RECORD ce_data(
	1 ce_cnt 				= i2
   	1 qual[*]
     	2 parent_event_id 	= f8
     	2 event_id 			= f8
     	2 event 			= c40
     	2 clinsig_dt_tm 	= dq8
     	2 event_start_dt_tm = dq8
     	2 event_end_dt_tm 	= dq8
     	2 result_status 	= c20
     	2 accession 		= c20
     	2 event_title_text 	= c40
     	2 result_val 		= c44
     	2 contrib_sys 		= f8
)
 
FREE RECORD microblob
RECORD microblob(
   	1 qual 					= i4
   	1 list[*]
     	2 parent_event_id 	= f8
     	2 event_id 			= f8
     	2 blob_contents 	= vc
     	2 event_tag 		= vc
     	2 compression_cd 	= f8
     	2 micro_line_cnt 	= i4
     	2 micro_line[*]
       		3 text 			= c80
)
 
free set pt
RECORD pt(
   1 line_cnt = i2
   1 lns [* ]
     2 line = vc
)
 
free set lr_dt_tm
RECORD lr_dt_tm(
   1 event_dt_arr [* ]
     2 nbr_events = i2
)
 
free set html_log
record html_log (
	1 list[*]
  		2 start					= i4
    	2 stop					= i4
    	2 patient_text			= vc
)
/*===============================================================================================================
 
                                             PROGRAMMER CONSTANTS
 
===============================================================================================================*/
declare TESTENV_IND				= i1 with protect, constant(evaluate(currdbname, "PROD", 0, 1))
 
;result_status_cd
declare AUTH_8_CV	 			= f8 with protect, constant(uar_get_code_by("MEANING", 8, "AUTH"))
declare ALT_8_CV 				= f8 with protect, constant(uar_get_code_by("MEANING", 8, "ALTERED"))
declare MOD_8_CV 				= f8 with protect, constant(uar_get_code_by("MEANING", 8, "MODIFIED"))
declare INERROR_8_CV			= f8 with protect, constant(uar_get_code_by("MEANING", 8, "INERROR"))
 
;encntr_alias_type_cd
declare FIN_319_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 319, "FIN NBR"))
 
;person_alias_type_cd
declare MRN_4_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 4, "MRN"))
 
;normalcy_cd
declare HIGH_52_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 52, "HIGH"))
declare LOW_52_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 52, "LOW"))
declare CRITICAL_52_CV 			= f8 with protect, constant(uar_get_code_by("MEANING", 52, "CRITICAL"))
 
;event_class_cd
declare DOC_53_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 53, "DOC"))
declare MDOC_53_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 53, "MDOC"))
declare DATE_53_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 53, "DATE"))
declare NUM_53_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 53, "NUM"))
declare TXT_53_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 53, "TXT"))
 
;event_cd
declare CLINICALWEIGHT_72_CV	= f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 72, "CLINICALWEIGHT"))
 
declare PENDING_79_CV 			= f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 79, "PENDING"))
 
;activity_type_cd
declare PHARMACY_106_CV			= f8 with protect, constant(uar_get_code_by("MEANING", 106, "PHARMACY"))
declare GLB_106_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 106, "GLB"))
declare BB_106_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 106, "BB"))
declare MICROBIOLOGY_106_CV		= f8 with protect, constant(uar_get_code_by("MEANING", 106, "MICROBIOLOGY"))
 
;iv_event_cd
declare BEGIN_180_CV			= f8 with protect, constant(uar_get_code_by("MEANING", 180, "BEGIN"))
declare RATECHG_180_CV			= f8 with protect, constant(uar_get_code_by("MEANING", 180, "RATECHG"))
 
declare CODESTATUS_200_CV 		= f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 200, "CODESTATUS"))
declare RESUSCITATIONSTA_200_CV = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 200, "RESUSCITATIONSTATUS"))
 
;encntr_prsnl_r_cd
declare ADMITDOC_33_CV			= f8 with protect, constant(uar_get_code_by("MEANING", 333, "ADMITDOC"))
 
DECLARE SOFTSTOP_4009_CV 		= f8 WITH protect, constant(uar_get_code_by("MEANING", 4009, "SOFT"))
 
;catalog_type_cd
declare PHARMACY_6000_CV		= f8 with protect, constant(uar_get_code_by("MEANING", 6000, "PHARMACY"))
declare LAB_6000_CV				= f8 with protect, constant(uar_get_code_by("MEANING", 6000, "GENERAL LAB"))
 
declare IPASSACTION_6027_CV 	= f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6027, "IPASSACTION"))
 
declare CANCELED_12025_CV 		= f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 12025, "CANCELED"))
 
;med_order_type_cd
declare IV_18309_CV				= f8 WITH protect, constant(uar_get_code_by("MEANING", 18309, "IV"))
 
declare ILLNESSSEVER_4003147_CV = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 4003147, "ILLNESSSEVERITY"))
declare COMMENT_4003147_CV 		= f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 4003147, "COMMENT"))
declare PATIENTSUMMA_4003147_CV = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 4003147, "PATIENTSUMMARY"))
declare ACTION_4003147_CV 		= f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 4003147, "ACTION"))
 
;compression_cd
declare OCFCOMP_120_CV 			= f8 with protect, constant(uar_get_code_by("MEANING", 120, "OCFCOMP"))
 
;order_status_cd
declare DELETED_6004_CV			= f8 with protect, constant(uar_get_code_by("MEANING", 6004, "DELETED")) 	;	Voided Without Results
declare VOIDEDWRSLT_6004_CV		= f8 with protect, constant(uar_get_code_by("MEANING", 6004, "VOIDEDWRSLT"));	Voided With Results
/*===============================================================================================================
 
                                             PROGRAMMER VARIABLES
 
===============================================================================================================*/
declare printuser_name			= vc with protect, noconstant("")
declare idx 					= i4 with protect, noconstant(0)
declare patienthtml 			= vc with protect, noconstant("")
declare finalhtml 				= vc with protect, noconstant("")
declare newsize 				= w8
 
DECLARE admin_rate_last 		= vc with protect, noconstant("")
DECLARE admin_rate_min 			= vc with protect, noconstant("")
DECLARE admin_rate_max 			= vc with protect, noconstant("")
DECLARE non_trailing_string 	= vc with protect, noconstant("")
DECLARE trailing_nbr 			= f8 with protect, noconstant(0)
/*==============================================================================================================
 
											  HTML VARIABLES
 
==============================================================================================================*/
;declare output					= vc with protect, noconstant("<html><body><tr><td><b>Start Date</b></td></tr>")
 
SET brow 						= "<td width=200 valign=top>"
SET erow 						= "</td>"
 
DECLARE output 					= vc
 
SET no_ord 						= "<html><body><span style='font-size:8.0pt;font-family:Helvetica'>" ;
/*===============================================================================================================
 
                                             SET PRINTUSER_NAME
 
===============================================================================================================*/
call echo(concat("SET PRINTUSER_NAME query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Set printuser_name
select into "nl:"
from
	prsnl p
plan p
	where p.person_id = reqinfo->updt_id
 
detail
	printuser_name = trim(p.name_full_formatted, 3)
 
with nocounter
 
call echo(concat("SET PRINTUSER_NAME query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                             GET JSON PATIENTS
 
===============================================================================================================*/
call echo(concat("GET JSON PATIENTS query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Add json patients to data record
set stat = cnvtjsontorec($jsondata)
 
select into "nl:"
	encounter = print_options->qual[d1.seq].encntr_id
from
	(dummyt d1 with seq = evaluate(size(print_options->qual, 5), 0, 1, size(print_options->qual, 5)))
plan d1
	where size(print_options->qual, 5) > 0
 
order by
	encounter
 
head report
 
	cnt = 0
 
head encounter
 
	cnt += 1
	if(mod(cnt, 20) = 1)
		stat = alterlist(data->list, cnt+19)
	endif
 
	data->list[cnt].encntr_id 	= print_options->qual[d1.seq].encntr_id
	data->list[cnt].person_id 	= print_options->qual[d1.seq].person_id
	data->list[cnt].age 		= trim(print_options->qual[d1.seq].pat_age, 3)
 
foot encounter
 
	null
 
foot report
 
	data->cnt = cnt
	stat = alterlist(data->list, cnt)
 
with nocounter
 
call echo(concat("GET JSON PATIENTS query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                            GET PATIENT INFORMATION
 
===============================================================================================================*/
call echo(concat("GET PATIENT INFORMATION query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Get patient information
select into "nl:"
from
	person p
plan p
	where expand(idx, 1, data->cnt, p.person_id, data->list[idx].person_id)
 
order by
	p.person_id
 
head p.person_id
 
	pos = locateval(idx, 1 ,data->cnt, p.person_id, data->list[idx].person_id)
 
	if(pos > 0)
		data->list[pos].patient_name 	= trim(p.name_full_formatted, 3)
		data->list[pos].gender 			= trim(uar_get_code_display(p.sex_cd), 3)
		data->list[pos].dob				= format(p.birth_dt_tm, "mm/dd/yyyy;;D")
	endif
 
foot p.person_id
 
	null
 
with expand = 2
 
call echo(concat("GET PATIENT INFORMATION query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                           GET ENCOUNTER DATA
 
===============================================================================================================*/
call echo(concat("GET ENCOUNTER DATA query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Get encounter data
select into "nl:"
	nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
	, room = uar_get_code_display(elh.loc_room_cd)
	, bed = uar_get_code_display(elh.loc_bed_cd)
from
	encounter e
	, encntr_loc_hist elh
	, encntr_alias fin
 
plan e
	where expand(idx, 1, data->cnt, e.encntr_id, data->list[idx].encntr_id)
	  and e.active_ind = 1
 
join elh
	where elh.encntr_id = e.encntr_id
	  and elh.end_effective_dt_tm = cnvtdate(12312100)
 
join fin
	where fin.encntr_id = outerjoin(e.encntr_id)
	  and fin.encntr_alias_type_cd = outerjoin(FIN_319_CV)
	  and fin.end_effective_dt_tm = outerjoin(cnvtdate(12312100))
 
order by
	nurse_unit
	, room
	, bed
	, e.encntr_id
 
head e.encntr_id
 
	pos = locatevalsort(idx, 1, data->cnt, e.encntr_id, data->list[idx].encntr_id)
 
	if(pos > 0)
		data->list[pos].unit_id 			= e.loc_nurse_unit_cd
		data->list[pos].unit_disp 			= trim(uar_get_code_display(e.loc_nurse_unit_cd),3)
		data->list[pos].room_id 			= e.loc_room_cd
		data->list[pos].room_disp 			= trim(uar_get_code_display(e.loc_room_cd),3)
		data->list[pos].admit_dt_tm 		= e.reg_dt_tm
		data->list[pos].admit_dt_tm_disp 	= format(e.reg_dt_tm,"mm/dd/yy hh:mm;;q")
		data->list[pos].person_id			= e.person_id
		data->list[pos].fin					= trim(fin.alias, 3)
		data->list[pos].med_service			= uar_get_code_display(e.med_service_cd)
 
		if(elh.loc_nurse_unit_cd != 0 and elh.loc_room_cd != 0 and elh.loc_bed_cd != 0)
			data->list[pos].location		= concat(trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3)
												 , "/"
												 , trim(uar_get_code_display(elh.loc_room_cd), 3)
												 , "/"
												 , trim(uar_get_code_display(elh.loc_bed_cd), 3))
		elseif(elh.loc_nurse_unit_cd != 0 and elh.loc_room_cd != 0)
			data->list[pos].location		= concat(trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3)
												 , "/"
												 , trim(uar_get_code_display(elh.loc_room_cd), 3))
		elseif(elh.loc_nurse_unit_cd != 0)
			data->list[pos].location		= trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3)
		else
			data->list[pos].location		= trim(uar_get_code_display(elh.loc_building_cd), 3)
		endif
 
		if(elh.loc_nurse_unit_cd != 0)
			if(trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3) = "*POD*")
				data->list[pos].nurse_unit	= substring(1, 2, trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3))
				data->list[pos].pod			= substring(8, 9, trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3))
			else
				data->list[pos].nurse_unit	= trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3)
			endif
		else
			data->list[pos].nurse_unit		= trim(uar_get_code_display(elh.loc_building_cd), 3)
		endif
 
		if(elh.loc_room_cd != 0)
			data->list[pos].room			= trim(uar_get_code_display(elh.loc_room_cd), 3)
		endif
 
		if(elh.loc_bed_cd != 0)
			data->list[pos].bed				= trim(uar_get_code_display(elh.loc_bed_cd), 3)
		endif
 
		if(elh.loc_nurse_unit_cd != 0 and elh.loc_room_cd != 0 and elh.loc_bed_cd != 0)
			data->list[pos].location			= concat(trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3)
												 , "/"
												 , trim(uar_get_code_display(elh.loc_room_cd), 3)
												 , "/"
												 , trim(uar_get_code_display(elh.loc_bed_cd), 3))
		elseif(elh.loc_nurse_unit_cd != 0 and elh.loc_room_cd != 0)
			data->list[pos].location			= concat(trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3)
												 , "/"
												 , trim(uar_get_code_display(elh.loc_room_cd), 3))
		elseif(elh.loc_nurse_unit_cd != 0)
			data->list[pos].location			= trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3)
		else
			data->list[pos].location			= trim(uar_get_code_display(elh.loc_building_cd), 3)
		endif
 
		if(elh.loc_nurse_unit_cd != 0)
			if(trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3) = "*POD*")
				data->list[pos].nurse_unit	= substring(1, 2, trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3))
				data->list[pos].pod			= substring(8, 9, trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3))
			else
				data->list[pos].nurse_unit	= trim(uar_get_code_display(elh.loc_nurse_unit_cd), 3)
			endif
		else
			data->list[pos].nurse_unit		= trim(uar_get_code_display(elh.loc_building_cd), 3)
		endif
 
		if(elh.loc_room_cd != 0)
			data->list[pos].room			= trim(uar_get_code_display(elh.loc_room_cd), 3)
		endif
 
		if(elh.loc_bed_cd != 0)
			data->list[pos].bed				= trim(uar_get_code_display(elh.loc_bed_cd), 3)
		endif
 
	endif
 
foot e.encntr_id
 
	null
 
with expand = 2
 
call echo(concat("GET ENCOUNTER DATA query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                             ADMITTING PCP
 
===============================================================================================================*/
call echo(concat("ADMITTING PCP query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
select into "nl:"
from
	encntr_prsnl_reltn epr
	, prsnl pr
 
plan epr
	where expand(idx, 1, data->cnt, epr.encntr_id, data->list[idx].encntr_id)
	  and epr.encntr_prsnl_r_cd = ADMITDOC_33_CV
 
join pr
	where pr.person_id = epr.prsnl_person_id
 
order by
	epr.encntr_id
 
head epr.encntr_id
 
	pos = locatevalsort(idx, 1, data->cnt, epr.encntr_id, data->list[idx].encntr_id)
 
	if(pos > 0)
		data->list[pos].admitting_pcp 		= trim(pr.name_full_formatted, 3)
	endif
 
foot epr.encntr_id
 
	null
 
with expand = 2
 
call echo(concat("ADMITTING PCP query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                             DOSING WEIGHT
 
===============================================================================================================*/
call echo(concat("DOSING WEIGHT query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
select into "NL:"
from
	clinical_event ce
plan ce
	where expand(idx, 1, data->cnt, ce.encntr_id, data->list[idx].encntr_id)
	  and ce.result_status_cd in (AUTH_8_CV, ALT_8_CV, MOD_8_CV)
	  and ce.event_cd = CLINICALWEIGHT_72_CV
	  and ce.valid_until_dt_tm = cnvtdate(12312100)
	  and ce.valid_from_dt_tm <= cnvtdatetime(curdate, curtime)
	  and cnvtupper(ce.event_title_text) != "DATE\TIME CORRECTION"
	  and ce.view_level = 1
 
order by
	ce.encntr_id
 
head ce.encntr_id
 
	pos = locatevalsort(idx, 1, data->cnt, ce.encntr_id, data->list[idx].encntr_id)
 
	if(pos > 0)
		data->list[pos].dosing_weight 	= concat(trim(ce.result_val, 3)
												, " "
												, uar_get_code_display(ce.result_units_cd)
												, " "
												, format(ce.event_end_dt_tm, "mm/dd/yyyy hh:mm;;q"))
	endif
 
foot ce.encntr_id
 
	null
 
with expand = 2
 
call echo(concat("DOSING WEIGHT query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                                GET MRN
 
===============================================================================================================*/
call echo(concat("GET MRN query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Get MRN
select into "nl:"
from
	person_alias mrn
plan mrn
	where expand(idx, 1, data->cnt, mrn.person_id, data->list[idx].person_id)
	  and mrn.active_ind = 1
	  and mrn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
	  and mrn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
	  and mrn.person_alias_type_cd = MRN_4_CV
 
order by
	mrn.person_id
 
head mrn.person_id
 
	pos = locatevalsort(idx, 1, data->cnt, mrn.person_id, data->list[idx].person_id)
 
	if(pos > 0)
		data->list[pos].mrn = trim(cnvtalias(mrn.alias, mrn.alias_pool_cd), 3)
	endif
 
foot mrn.person_id
 
	null
 
with expand = 2
 
call echo(concat("GET MRN query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                           GET ILLNESS SEVERITY
 
===============================================================================================================*/
call echo(concat("GET ILLNESS SEVERITY query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Get Illness Severity
select into "nl:"
from
	pct_ipass pi
	,code_value cv
 
plan pi
	where expand(idx, 1, data->cnt, pi.encntr_id, data->list[idx].encntr_id)
	  and pi.active_ind = 1
	  and pi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
	  and pi.ipass_data_type_cd = ILLNESSSEVER_4003147_CV
 
join cv
	where cv.code_value = pi.parent_entity_id
	  and cv.active_ind = 1
 
order by
	pi.encntr_id
 
head pi.encntr_id
 
	pos = locatevalsort(idx, 1, data->cnt, pi.encntr_id, data->list[idx].encntr_id)
 
	if(pos > 0)
		data->list[pos].illness_severity = trim(cv.display, 3)
	endif
 
foot pi.encntr_id
 
	null
 
with expand = 2
 
call echo(concat("GET ILLNESS SEVERITY query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                            GET CODE STATUS
 
===============================================================================================================*/
/*call echo(concat("GET CODE STATUS query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Get Code Status
select into "nl:"
from
	orders o
	,order_detail od
 
plan o
	where expand(idx, 1, data->cnt, o.encntr_id, data->list[idx].encntr_id)
	and o.catalog_cd = CODESTATUS_200_CV
 
join od
	where od.order_id = o.order_id
	  and od.oe_field_id = 1040321.00		;Code Status
 
order by
	o.encntr_id
	, o.order_id
	, od.oe_field_id
	, od.action_sequence desc
 
head o.encntr_id
	pos = locatevalsort(idx, 1, data->cnt, o.encntr_id, data->list[idx].encntr_id)
 
head o.order_id
	null
 
head od.oe_field_id
 
	if(pos > 0)
		data->list[pos].code_status = trim(od.oe_field_display_value, 3)
	endif
 
foot od.oe_field_id
	null
 
foot o.order_id
	null
 
foot o.encntr_id
	null
 
with expand = 2
 
call echo(concat("GET CODE STATUS query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                             GET RESUSCITATION STATUS
 
===============================================================================================================*/
call echo(concat("GET RESUSCITATION STATUS query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Get Resuscitation Status
select into "nl:"
 
from
	orders o
	, order_detail od
 
plan o
	where expand(idx, 1, data->cnt, o.encntr_id, data->list[idx].encntr_id)
	  and o.catalog_cd = RESUSCITATIONSTA_200_CV
	  and NOT o.order_status_cd in (DELETED_6004_CV, VOIDEDWRSLT_6004_CV)
	  and o.active_ind = 1
 
join od
	where od.order_id = o.order_id
	  and od.oe_field_meaning = "RESUSCITATIONSTATUS"
 
head o.encntr_id
 
	pos = locateval(idx, 1, data->cnt, o.encntr_id, data->list[idx].encntr_id)
 
	data->list[pos].code_status = trim(od.oe_field_display_value, 3)
 
with expand = 2
 
call echo(concat("GET RESUSCITATION STATUS query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                               GET PATIENT SUMMARY AND SITUATION AWARENESS & PLANNING
 
===============================================================================================================*/
call echo(concat("GET PATIENT SUMMARY AND SITUATION AWARENESS & PLANNING query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Get Patient Summary and Situation Awareness & Planning
select into "nl:"
	result = evaluate(sn.long_text_id, 0, trim(sn.sticky_note_text, 3), trim(lt.long_text, 3))
from
	pct_ipass pi
	, sticky_note sn
	, long_text lt
 
plan pi
	where expand(idx, 1, data->cnt, pi.encntr_id, data->list[idx].encntr_id)
	and pi.active_ind = 1
	and pi.end_effective_dt_tm >= cnvtdatetime(curdate, curtime)
	and pi.ipass_data_type_cd in (COMMENT_4003147_CV, PATIENTSUMMA_4003147_CV)
 
join sn
	where sn.sticky_note_id = pi.parent_entity_id
	  and sn.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime)
	  and sn.end_effective_dt_tm >= cnvtdatetime(curdate, curtime)
 
join lt
	where lt.long_text_id = outerjoin(sn.long_text_id)
	  and lt.active_ind = outerjoin(1)
 
order by
	pi.encntr_id
	, pi.ipass_data_type_cd
	, pi.begin_effective_dt_tm desc
 
head pi.encntr_id
 
	pos = locatevalsort(idx, 1, data->cnt, pi.encntr_id, data->list[idx].encntr_id)
	cnt = 0
 
head pi.ipass_data_type_cd
 
	if(pos > 0 and pi.ipass_data_type_cd = PATIENTSUMMA_4003147_CV)
		data->list[pos].patient_summary = result
	endif
 
detail
 
	if(pos > 0 and pi.ipass_data_type_cd = COMMENT_4003147_CV)
		cnt += 1
		stat = alterlist(data->list[pos]->sit_aware, cnt)
 
		data->list[pos]->sit_aware[cnt].comment = result
	endif
 
foot pi.ipass_data_type_cd
 
	if(pos > 0)
		data->list[pos].sit_aware_cnt = cnt
	endif
 
foot pi.encntr_id
	null
 
with expand = 2
 
call echo(concat("GET PATIENT SUMMARY AND SITUATION AWARENESS & PLANNING query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                                GET ACTIONS
 
===============================================================================================================*/
call echo(concat("GET ACTIONS query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Get Actions
select into "nl:"
from
	pct_ipass pi
	, task_activity ta
	, long_text lt
 
plan pi
	where expand(idx, 1,data->cnt, pi.encntr_id, data->list[idx].encntr_id)
	  and pi.active_ind = 1
	  and pi.end_effective_dt_tm >= cnvtdatetime(curdate, curtime)
	  and pi.ipass_data_type_cd = ACTION_4003147_CV
 
join ta
	where ta.task_id = pi.parent_entity_id
	and ta.task_activity_cd = IPASSACTION_6027_CV
	and ta.task_status_cd = PENDING_79_CV
 
join lt
	where lt.long_text_id = ta.msg_text_id
	  and lt.parent_entity_name = "TASK_ACTIVITY"
	  and lt.long_text != null
 
order by
	pi.encntr_id
	, pi.begin_effective_dt_tm desc
 
head pi.encntr_id
 
	pos = locatevalsort(idx, 1, data->cnt, pi.encntr_id, data->list[idx].encntr_id)
	cnt = 0
 
detail
 
	if(pos > 0)
		cnt += 1
		stat = alterlist(data->list[pos]->actions, cnt)
 
		data->list[pos]->actions[cnt].action = trim(lt.long_text, 3)
	endif
 
foot pi.encntr_id
 
	if(pos > 0)
		data->list[pos].actions_cnt = cnt
	endif
 
with expand = 2
 
call echo(concat("GET ACTIONS query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                              GET ALLERGIES
 
===============================================================================================================*/
call echo(concat("GET ALLERGIES query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
;Get Allergies
select into "nl:"
	result = evaluate(a.substance_nom_id, 0, trim(a.substance_ftdesc, 3), trim(n.source_string, 3))
from
	allergy a
	,nomenclature n
 
plan a
	where expand(idx, 1, data->cnt, a.person_id, data->list[idx].person_id)
	  and a.active_ind = 1
	  and a.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime)
	  and (a.end_effective_dt_tm >= cnvtdatetime(curdate, curtime)
		or a.end_effective_dt_tm = null)
	  and a.reaction_status_cd != CANCELED_12025_CV
 
join n
	where n.nomenclature_id = outerjoin(a.substance_nom_id)
	  and n.active_ind = outerjoin(1)
 
order by
	a.person_id
	, result
 
head a.person_id
 
	pos = locateval(idx, 1, data->cnt, a.person_id, data->list[idx].person_id)
	cnt = 0
 
detail
 
	if(pos > 0)
		cnt += 1
		stat = alterlist(data->list[pos]->allergies, cnt)
 
		data->list[pos]->allergies[cnt].allergy = result
	endif
 
foot a.person_id
 
	if(pos > 0)
		data->list[pos].allergy_cnt = cnt
	endif
 
with expand = 2
 
call echo(concat("GET ALLERGIES query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                               ACTIVE MEDICATIONS
 
===============================================================================================================*/
call echo(concat("ACTIVE MEDICATIONS query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
select distinct into "NL:"
 
	result = uar_get_code_display(o.catalog_cd) ;evaluate(a.substance_nom_id, 0, trim(a.substance_ftdesc, 3), trim(n.source_string, 3))
 
from
	orders o
 	, (left join order_detail od on (od.order_id = o.order_id
	  and od.oe_field_meaning IN ("FREQ"
    							  , "FREETXTDOSE"
    							  , "STRENGTHDOSE"
    							  , "STRENGTHDOSEUNIT"
    							  , "RXROUTE"
    							  , "PRNREASON"
    							  , "VOLUMEDOSE"
    							  , "VOLUMEDOSEUNIT"
    							  , "RATE"
    							  , "RATEUNIT")))
 
plan o
	where expand(idx, 1,data->cnt, o.person_id, data->list[idx].person_id
								 , o.encntr_id, data->list[idx].encntr_id)
	  and o.catalog_cd != 0.00
	  and o.catalog_type_cd = PHARMACY_6000_CV
	  and o.activity_type_cd = PHARMACY_106_CV
	  and o.orig_ord_as_flag = 0
	  and NOT o.order_status_cd in (DELETED_6004_CV, VOIDEDWRSLT_6004_CV)
;	  and o.template_order_flag IN (0, 1)
	  and o.active_ind = 1
 
join od
 
ORDER BY
 	o.person_id
    , o.order_id
    , cnvtupper(o.hna_order_mnemonic)
;	, od.action_sequence
 
HEAD REPORT
 
    wrong = fillstring (20, " ")
 	prn_cnt = 0
 
head o.person_id
 
	pos = locateval(idx, 1, data->cnt, o.person_id, data->list[idx].person_id)
	ocnt = 0
 
head o.order_id
 
	if(pos > 0)
 
		ocnt += 1
		stat = alterlist(data->list[pos]->meds, ocnt)
 
		data->list[pos]->meds[ocnt].order_id = o.order_id
		data->list[pos]->meds[ocnt].encntr_id = o.encntr_id
		data->list[pos]->meds[ocnt].catalog_cd = o.catalog_cd
		data->list[pos]->meds[ocnt].catalog_type_cd = o.catalog_type_cd
		data->list[pos]->meds[ocnt].activity_type_cd = o.activity_type_cd
		data->list[pos]->meds[ocnt].mnemonic = trim(o.hna_order_mnemonic, 3)
		data->list[pos]->meds[ocnt].iv_ind = o.iv_ind
 
    	IF(o.med_order_type_cd = IV_18309_CV)
    		data->list[pos]->meds[ocnt].iv_ind = 1
    	ENDIF
 
    	IF(data->list[pos]->meds[ocnt].iv_ind = 1)
	   		data->list[pos]->meds[ocnt].mnemonic = trim(o.ordered_as_mnemonic, 3)
	    ELSE
	     	IF(trim(o.order_mnemonic, 3) != trim(o.hna_order_mnemonic, 3))
	     		data->list[pos]->meds[ocnt].ord_as_mnemonic = concat("( ", trim(o.order_mnemonic, 3), ")")
	     	ENDIF
	    ENDIF
 
	    data->list[pos]->meds[ocnt].order_status = uar_get_code_display(o.order_status_cd)
	    data->list[pos]->meds[ocnt].dept_order_status = uar_get_code_display(o.dept_status_cd)
	    data->list[pos]->meds[ocnt].prn_ind = o.prn_ind
	    data->list[pos]->meds[ocnt].current_start_dt_tm = format(o.current_start_dt_tm , "mm/dd/yy hh:mm;;d")
	    data->list[pos]->meds[ocnt].projected_stop_dt_tm = format(o.projected_stop_dt_tm ,"mm/dd/yy hh:mm;;d")
	    data->list[pos]->meds[ocnt].stop_type_cd = o.stop_type_cd
	    data->list[pos]->meds[ocnt].med_order_type_cd = o.med_order_type_cd
	    data->list[pos]->meds[ocnt].print_flag = "N"
 
	    IF(o.cki = "MUL.ORD!*")
	    	data->list[pos]->meds[ocnt].dnum = substring(9, 25, o.cki)
	    ELSE
	    	data->list[pos]->meds[ocnt].dnum = " "
	    ENDIF
 
 		if(o.prn_ind = 1)
 			prn_cnt = prn_cnt + 1
 			data->list[pos]->meds[ocnt].prn_ind = 1
 		endif
 
	endif
 
DETAIL
 
    IF(od.oe_field_meaning = "FREQ")
    	data->list[pos]->meds[ocnt].frequency = trim(od.oe_field_display_value, 3)
    ELSEIF((od.oe_field_meaning = "FREETXTDOSE") OR (od.oe_field_meaning = "STRENGTHDOSE"))
    	data->list[pos]->meds[ocnt].dose = trim(od.oe_field_display_value, 3)
    ELSEIF(od.oe_field_meaning = "STRENGTHDOSEUNIT")
    	data->list[pos]->meds[ocnt].doseunit = trim(od.oe_field_display_value, 3)
    ELSEIF(od.oe_field_meaning = "RXROUTE")
    	data->list[pos]->meds[ocnt].route = trim(od.oe_field_display_value, 3)
    ELSEIF (od.oe_field_meaning = "PRNREASON")
    	data->list[pos]->meds[ocnt].prn_reason = trim(od.oe_field_display_value, 3)
    ELSEIF(od.oe_field_meaning = "RATE")
    	data->list[pos]->meds[ocnt].rate = trim(od.oe_field_display_value, 3)
    ELSEIF(od.oe_field_meaning = "RATEUNIT")
    	data->list[pos]->meds[ocnt].rate_unit = trim(od.oe_field_display_value, 3)
    ENDIF
 
foot o.order_id
 
	if(pos > 0)
		data->list[pos].med_cnt = ocnt
	endif
 
    IF((data->list[pos]->meds[ocnt].dose > " ") AND (data->list[pos]->meds[ocnt].doseunit > " "))
    	data->list[pos]->meds[ocnt].dose = concat(trim(data->list[pos]->meds[ocnt].dose, 3), trim(data->list[pos]->meds[ocnt].doseunit, 3))
    ENDIF
 
    IF((data->list[pos]->meds[ocnt].vol_dose > " ") AND (data->list[pos]->meds[ocnt].vol_dose_unit > " "))
    	data->list[pos]->meds[ocnt].vol_dose = concat(trim(data->list[pos]->meds[ocnt].vol_dose, 3)
      												, trim(data->list[pos]->meds[ocnt].vol_dose_unit, 3))
    ENDIF
 
    IF((data->list[pos]->meds[ocnt].rate > " ") AND (data->list[pos]->meds[ocnt].rate_unit > " "))
    	data->list[pos]->meds[ocnt].rate = concat(trim(data->list[pos]->meds[ocnt].rate, 3 )
    										    , trim(data->list[pos]->meds[ocnt].rate_unit, 3))
    ENDIF
 
    IF(data->list[pos]->meds[ocnt].prn_ind = 0)
    	IF(data->list[pos]->meds[ocnt].stop_type_cd != SOFTSTOP_4009_CV)
    		stop = ""
 
      		IF(data->list[pos]->meds[ocnt].projected_stop_dt_tm > " ")
      			stop = concat("[Stop: ", trim(data->list[pos]->meds[ocnt].projected_stop_dt_tm, 3), "]")
      		ENDIF
 
			data->list[pos]->meds[ocnt].display_line = concat(trim(data->list[pos]->meds[ocnt].mnemonic, 3)
														    , trim(data->list[pos]->meds[ocnt].ord_as_mnemonic, 3), " "
														    , trim(data->list[pos]->meds[ocnt].dose, 3), " "
														    , trim(data->list[pos]->meds[ocnt].rate, 3), " "
														    , trim(data->list[pos]->meds[ocnt].route, 3), " "
														    , trim(data->list[pos]->meds[ocnt].frequency, 3), " "
														    , build(wrong))
     	ELSE
     		data->list[pos]->meds[ocnt].display_line = concat(trim(data->list[pos]->meds[ocnt].mnemonic, 3)
     														, trim(data->list[pos]->meds[ocnt].ord_as_mnemonic, 3) , " "
     														, trim(data->list[pos]->meds[ocnt].dose, 3), " "
     														, trim(data->list[pos]->meds[ocnt].route, 3), " "
     														, trim(data->list[pos]->meds[ocnt].frequency, 3), " "
     														, build(wrong))
     	ENDIF
 
    ELSE
    	data->list[pos]->meds[ocnt].display_line = concat(trim(data->list[pos]->meds[ocnt].mnemonic, 3)
    													, trim(data->list[pos]->meds[ocnt].ord_as_mnemonic, 3), " "
    													, trim(data->list[pos]->meds[ocnt].dose, 3), " "
    													, trim(data->list[pos]->meds[ocnt].route, 3), " "
    													, trim(data->list[pos]->meds[ocnt].frequency, 3) , " PRN "
    													, trim(data->list[pos]->meds[ocnt].prn_reason, 3), " "
    													, build(wrong))
	endif
 
 	data->list[pos].prn_total					= prn_cnt
 
with expand = 2
 
;Get Scheduled Meds
SELECT distinct into "NL:"
	category = (if( od.oe_field_meaning = "FREQ" and cnvtupper(od.oe_field_display_value) in ("AS DIRECTED", "ONCE"))
	  				"SCEDULED"
	  		   endif)
	, order_id = data->list[d1.seq].meds[d2.seq].order_id
	, display_line = cnvtupper(data->list[d1.seq].meds[d2.seq].display_line)
from
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
	, orders o
	, order_detail od
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].meds, 5))
 
join d2
	where data->list[d1.seq].meds[d2.seq].prn_ind = 0
 
join o
	where o.order_id = data->list[d1.seq].meds[d2.seq].order_id
	  and o.catalog_cd != 0.00
	  and o.catalog_type_cd = PHARMACY_6000_CV
	  and o.activity_type_cd = PHARMACY_106_CV
	  and o.orig_ord_as_flag = 0
	  and NOT o.order_status_cd in (DELETED_6004_CV, VOIDEDWRSLT_6004_CV)
	  and o.active_ind = 1
 
join od
	where od.order_id = o.order_id
	  and od.oe_field_meaning = "FREQ"
	  and NOT cnvtupper(od.oe_field_display_value) in ("AS DIRECTED", "ONCE")
 
ORDER BY
	category
	, order_id
 	, display_line
 
head report
 
	scnt 	= 0
	stat = alterlist(data->list[d1.seq].sched, 5)
 
head category
	null
head order_id
 
	scnt += 1
 	stat = alterlist(data->list[d1.seq].sched, scnt)
 
 	data->list[d1.seq].sched[scnt].display_line 	= data->list[d1.seq].meds[d2.seq].display_line
	data->list[d1.seq].sched[scnt].order_id 		= data->list[d1.seq].meds[d2.seq].order_id
 
 	if(data->list[d1.seq].sched[scnt].order_id = 0.00)
 		scnt = scnt - 1
 		stat = alterlist(data->list[d1.seq].sched, scnt)
 	endif
 
FOOT REPORT
 
	stat = alterlist(data->list[d1.seq].sched, scnt)
 
WITH NOCOUNTER
 
;GET PRN Meds
SELECT distinct into "NL:"
	category = (if(data->list[d1.seq].meds[d2.seq].prn_ind = 1)
					"PRN" ;ORD_CATEGORY->PRN
				endif)
	, order_id = data->list[d1.seq].meds[d2.seq].order_id
	, display_line = cnvtupper(data->list[d1.seq].meds[d2.seq].display_line)
from
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
	, orders o
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].meds, 5))
 
join d2
	where data->list[d1.seq].meds[d2.seq].prn_ind = 1
 
join o
	where o.order_id = data->list[d1.seq].meds[d2.seq].order_id
	  and o.catalog_cd != 0.00
	  and o.catalog_type_cd = PHARMACY_6000_CV
	  and o.activity_type_cd = PHARMACY_106_CV
	  and o.orig_ord_as_flag = 0
	  and NOT o.order_status_cd in (DELETED_6004_CV, VOIDEDWRSLT_6004_CV)
	  and o.active_ind = 1
 
ORDER BY
	category
	, order_id
 	, display_line
 
head report
 
 	pcnt 	= 0
 
 	stat = alterlist(data->list[d1.seq].prn, 5)
 
head category
	null
head order_id
 
	pcnt += 1
 	stat = alterlist(data->list[d1.seq].prn, pcnt)
 
 	data->list[d1.seq].prn[pcnt].display_line 	= data->list[d1.seq].meds[d2.seq].display_line
	data->list[d1.seq].prn[pcnt].order_id 		= data->list[d1.seq].meds[d2.seq].order_id
	data->list[d1.seq].prn[pcnt].catalog_cd 	= data->list[d1.seq].meds[d2.seq].catalog_cd
 
 	if(data->list[d1.seq].prn[pcnt].order_id = 0.00)
 		pcnt = pcnt - 1
 		stat = alterlist(data->list[d1.seq].prn, pcnt)
 	endif
 
foot report
 
	stat = alterlist(data->list[d1.seq].prn, pcnt)
 
WITH NOCOUNTER
 
;Get Continuous Infusions Meds
SELECT distinct into "NL:"
	category = (if(od.oe_field_meaning = "RXROUTE" and cnvtupper(od.oe_field_display_value) = "IV CONTINUOUS")
	  				"CONTINUOUS"
	  		   endif)
	, order_id = data->list[d1.seq].meds[d2.seq].order_id
	, display_line = cnvtupper(data->list[d1.seq].meds[d2.seq].display_line)
from
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
	, orders o
	, order_detail od
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].meds, 5))
 
join d2
	where data->list[d1.seq].meds[d2.seq].prn_ind = 0
 
join o
	where o.order_id = data->list[d1.seq].meds[d2.seq].order_id
	  and o.catalog_cd != 0.00
	  and o.catalog_type_cd = PHARMACY_6000_CV
	  and o.activity_type_cd = PHARMACY_106_CV
	  and o.orig_ord_as_flag = 0
	  and NOT o.order_status_cd in (DELETED_6004_CV, VOIDEDWRSLT_6004_CV)
	  and o.active_ind = 1
 
join od
	where od.order_id = o.order_id
	  and od.oe_field_meaning = "RXROUTE"
      and cnvtupper(od.oe_field_display_value) in ("IV CONTINUOUS")
 
ORDER BY
	category
	, order_id
 	, display_line
 
head report
 
	ccnt 	= 0
	stat = alterlist(data->list[d1.seq].cont, 5)
 
head category
	null
head order_id
 
	ccnt += 1
 	stat = alterlist(data->list[d1.seq].cont, ccnt)
 
 	data->list[d1.seq].cont[ccnt].display_line 	= data->list[d1.seq].meds[d2.seq].display_line
	data->list[d1.seq].cont[ccnt].order_id 		= data->list[d1.seq].meds[d2.seq].order_id
 
 	if(data->list[d1.seq].cont[ccnt].order_id = 0.00)
 		ccnt = ccnt - 1
 		stat = alterlist(data->list[d1.seq].cont, ccnt)
 	endif
 
FOOT REPORT
 
	stat = alterlist(data->list[d1.seq].cont, ccnt)
 
WITH NOCOUNTER
 
;Get Unscheduled Meds
SELECT distinct into "NL:"
	category = (if( od.oe_field_meaning = "FREQ" and cnvtupper(od.oe_field_display_value) in ("AS DIRECTED", "ONCE"))
	  				"UNSCEDULED"
	  		   endif)
	, order_id = data->list[d1.seq].meds[d2.seq].order_id
	, display_line = cnvtupper(data->list[d1.seq].meds[d2.seq].display_line)
from
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
	, orders o
	, order_detail od
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].meds, 5))
 
join d2
 	where data->list[d1.seq].meds[d2.seq].prn_ind = 0
 
join o
	where o.order_id = data->list[d1.seq].meds[d2.seq].order_id
	  and o.catalog_cd != 0.00
	  and o.catalog_type_cd = PHARMACY_6000_CV
	  and o.activity_type_cd = PHARMACY_106_CV
	  and o.orig_ord_as_flag = 0
	  and NOT o.order_status_cd in (DELETED_6004_CV, VOIDEDWRSLT_6004_CV)
	  and o.active_ind = 1
 
join od
	where od.order_id = o.order_id
	  and od.oe_field_meaning = "FREQ"
	  and cnvtupper(od.oe_field_display_value) in ("AS DIRECTED", "ONCE")
 
ORDER BY
	category
	, order_id
 	, display_line
 
head report
 
	ucnt 	= 0
	stat = alterlist(data->list[d1.seq].unsched, 5)
 
head category
	null
head order_id
 
	ucnt += 1
 	stat = alterlist(data->list[d1.seq].unsched, ucnt)
 
 	data->list[d1.seq].unsched[ucnt].display_line 	= data->list[d1.seq].meds[d2.seq].display_line
	data->list[d1.seq].unsched[ucnt].order_id 		= data->list[d1.seq].meds[d2.seq].order_id
 
 	if(data->list[d1.seq].unsched[ucnt].order_id = 0.00)
 		ucnt = ucnt - 1
 		stat = alterlist(data->list[d1.seq].unsched, ucnt)
 	endif
 
FOOT REPORT
 
	stat = alterlist(data->list[d1.seq].unsched, ucnt)
 
WITH NOCOUNTER
;;;**********************************************
;Get Categories
/*SELECT distinct into "NL:"
	category = (if(data->list[d1.seq].meds[d2.seq].prn_ind = 1)
					"PRN" ;ORD_CATEGORY->PRN
				elseif (od.oe_field_meaning = "FREQ" and od.oe_field_display_value != "ONCE");;ORD_TYPE->INTERMITTENT or 1???
					 ;or fo.ord_type = 3)
					"SCHEDULED"
				elseif (od.oe_field_meaning = "RXROUTE" and od.oe_field_display_value in ("IV PUSH", "IV CONTINUOUS")); ORD_TYPE->CONTINUOUS)
					"CONTINUOUS" ;ORD_CATEGORY->CONTINUOUS
				else ;if (fs.frequency_type = 5);FREQ_TYPE->UNSCHEDULED)
					"UNSCHEDULED"
				endif)
		, order_id = data->list[d1.seq].meds[d2.seq].order_id
		, display_line = cnvtupper(data->list[d1.seq].meds[d2.seq].display_line)
 
from
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
	, orders o
 	, (left join order_detail od on (od.order_id = o.order_id))
; 	, frequency_schedule fs
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].meds, 5))
 
join d2
 
join o
	where o.order_id = data->list[d1.seq].meds[d2.seq].order_id
join od
;join fo
;	where fo.order_id = o.order_id
;	  and fo.order_id != 0.00
;
;join fs
;	where fs.frequency_cd = fo.frequency_cd
;      and (fs.freq_qualifier = 14 or fs.freq_qualifier = 0)
 
ORDER BY
	category
	, order_id
 	, display_line
 
head report
 
	cocnt 	= 0
	pcnt 	= 0
	scnt 	= 0
	ucnt 	= 0
 
	stat = alterlist(data->list[d1.seq].cont, 5)
	stat = alterlist(data->list[d1.seq].prn, 5)
	stat = alterlist(data->list[d1.seq].sched, 5)
	stat = alterlist(data->list[d1.seq].unsched, 5)
 
head category
	null
head order_id
 
	if(category = "CONTINUOUS" and order_id != 0.00)
 		cocnt += 1
 		stat = alterlist(data->list[d1.seq].cont, cocnt)
 
 		data->list[d1.seq].cont[cocnt].display_line 	= data->list[d1.seq].meds[d2.seq].display_line
		data->list[d1.seq].cont[cocnt].order_id 		= data->list[d1.seq].meds[d2.seq].order_id
 
		if(data->list[d1.seq].cont[cocnt].order_id = 0.00)
			cocnt = cocnt - 1
			stat = alterlist(data->list[d1.seq].cont, cocnt)
		endif
 
 	elseif(category = "PRN" and order_id != 0.00)
 		pcnt += 1
 		stat = alterlist(data->list[d1.seq].prn, pcnt)
 
 		data->list[d1.seq].prn[pcnt].display_line 	= data->list[d1.seq].meds[d2.seq].display_line
		data->list[d1.seq].prn[pcnt].order_id 		= data->list[d1.seq].meds[d2.seq].order_id
		data->list[d1.seq].prn[pcnt].catalog_cd 	= data->list[d1.seq].meds[d2.seq].catalog_cd
 
 		if(data->list[d1.seq].prn[pcnt].order_id = 0.00)
 			pcnt = pcnt - 1
 			stat = alterlist(data->list[d1.seq].prn, pcnt)
 		endif
 	elseif(category = "SCHEDULED" and order_id != 0.00)
 		scnt += 1
 		stat = alterlist(data->list[d1.seq].sched, scnt)
 
 		data->list[d1.seq].sched[scnt].display_line 	= data->list[d1.seq].meds[d2.seq].display_line
		data->list[d1.seq].sched[scnt].order_id 		= data->list[d1.seq].meds[d2.seq].order_id
 
 		if(data->list[d1.seq].sched[scnt].order_id = 0.00)
 			scnt = scnt - 1
 			stat = alterlist(data->list[d1.seq].sched, scnt)
 		endif
 	else ;if(category = "UNSCHEDULED" and o.order_id != 0.00)
 		ucnt += 1
 		stat = alterlist(data->list[d1.seq].unsched, ucnt)
 
 		data->list[d1.seq].unsched[ucnt].display_line 	= data->list[d1.seq].meds[d2.seq].display_line
		data->list[d1.seq].unsched[ucnt].order_id 		= data->list[d1.seq].meds[d2.seq].order_id
 
 		if(data->list[d1.seq].unsched[ucnt].order_id = 0.00)
 			ucnt = ucnt - 1
 			stat = alterlist(data->list[d1.seq].unsched, ucnt)
 		endif
 	endif
 
foot report
 
	stat = alterlist(data->list[d1.seq].cont, cocnt)
	stat = alterlist(data->list[d1.seq].prn, pcnt)
	stat = alterlist(data->list[d1.seq].sched, scnt)
	stat = alterlist(data->list[d1.seq].unsched, ucnt)
 
WITH NOCOUNTER*/
 
;remove blanks from each list
SELECT distinct INTO "NL"
	encntr_id = data->list[d1.seq].encntr_id
	, order_id = data->list[d1.seq].prn[d2.seq].order_id
	, DISPLAY_LINE = SUBSTRING(1, 80, DATA->list[d1.SEQ].prn[d2.SEQ].display_line)
 
FROM
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].prn, 5))
 
join d2
	where data->list[d1.seq].prn[d2.seq].DISPLAY_LINE != ""
 
order by
	encntr_id
	, DISPLAY_LINE
	, order_id
 
head encntr_id
 
	pcnt = 0
	stat = alterlist(data->list[d1.seq].prn2, 5)
 
head display_line
	null
head order_id
 
	if(order_id != 0.00)
		pcnt = pcnt + 1
		;check for available memory in the list
		IF(MOD(pcnt, 5) = 1 AND pcnt > 5)
			;if needed allocate memory for 5 more records
			STAT = ALTERLIST(data->list[d1.seq].prn2, pcnt + 4)
		ENDIF
 
		data->list[d1.seq].prn2[pcnt].order_id =  data->list[d1.seq].prn[d2.seq].order_id
		data->list[d1.seq].prn2[pcnt].display_line =  data->list[d1.seq].prn[d2.seq].display_line
		data->list[d1.seq].prn2[pcnt].catalog_cd =  data->list[d1.seq].prn[d2.seq].catalog_cd
	endif
 
foot encntr_id
 
	data->list[d1.seq].prn2_cnt = pcnt
	stat = alterlist(data->list[d1.seq].prn2, pcnt)
 
WITH check
 
SELECT distinct INTO "NL"
	encntr_id = data->list[d1.seq].encntr_id
	, order_id = data->list[d1.seq].cont[d2.seq].order_id
	, DISPLAY_LINE = SUBSTRING(1, 30, DATA->list[d1.SEQ].cont[d2.SEQ].display_line)
 
FROM
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].cont, 5))
 
join d2
	where data->list[d1.seq].cont[d2.seq].DISPLAY_LINE != ""
 
order by
	encntr_id
	, DISPLAY_LINE
	, order_id
 
head encntr_id
 
	ccnt = 0
	stat = alterlist(data->list[d1.seq].cont2, 5)
 
head display_line
	null
head order_id
 
	if(order_id != 0.00)
		ccnt = ccnt + 1
		;check for available memory in the list
		IF(MOD(ccnt, 5) = 1 AND ccnt > 5)
			;if needed allocate memory for 5 more records
			STAT = ALTERLIST(data->list[d1.seq].cont2, ccnt + 4)
		ENDIF
 
		data->list[d1.seq].cont2[ccnt].order_id =  data->list[d1.seq].cont[d2.seq].order_id
		data->list[d1.seq].cont2[ccnt].display_line =  data->list[d1.seq].cont[d2.seq].display_line
	endif
 
foot encntr_id
 
	data->list[d1.seq].cont2_cnt = ccnt
	stat = alterlist(data->list[d1.seq].cont2, ccnt)
 
WITH check
 
SELECT INTO "NL"
	encntr_id = data->list[d1.seq].encntr_id
	, order_id = data->list[d1.seq].sched[d2.seq].order_id
	, DISPLAY_LINE = SUBSTRING(1, 30, DATA->list[d1.SEQ].sched[d2.SEQ].display_line)
 
FROM
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].sched, 5))
 
join d2
	where data->list[d1.seq].sched[d2.seq].DISPLAY_LINE != ""
 
order by
	encntr_id
	, DISPLAY_LINE
	, order_id
 
head encntr_id
 
	scnt = 0
	stat = alterlist(data->list[d1.seq].sched2, 5)
 
head display_line
	null
head order_id
 
	if(order_id != 0.00)
		scnt = scnt + 1
		;check for available memory in the list
		IF(MOD(scnt, 5) = 1 AND scnt > 5)
			;if needed allocate memory for 5 more records
			STAT = ALTERLIST(data->list[d1.seq].sched2, scnt + 4)
		ENDIF
 
		data->list[d1.seq].sched2[scnt].order_id =  data->list[d1.seq].sched[d2.seq].order_id
		data->list[d1.seq].sched2[scnt].display_line =  data->list[d1.seq].sched[d2.seq].display_line
	endif
 
foot encntr_id
 
	data->list[d1.seq].sched2_cnt = scnt
	stat = alterlist(data->list[d1.seq].sched2, scnt)
 
WITH check
 
SELECT distinct INTO "NL"
	encntr_id = data->list[d1.seq].encntr_id
	, order_id = data->list[d1.seq].unsched[d2.seq].order_id
	, DISPLAY_LINE = SUBSTRING(1, 30, DATA->list[d1.SEQ].unsched[d2.SEQ].display_line)
 
FROM
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].unsched, 5))
 
join d2
	where data->list[d1.seq].unsched[d2.seq].DISPLAY_LINE != ""
 
order by
	encntr_id
	, DISPLAY_LINE
	, order_id
 
head encntr_id
 
	ucnt = 0
	stat = alterlist(data->list[d1.seq].unsched2, 5)
 
head display_line
	null
head order_id
 
	if(order_id != 0.00)
		ucnt = ucnt + 1
		;check for available memory in the list
		IF(MOD(ucnt, 5) = 1 AND ucnt > 5)
			;if needed allocate memory for 5 more records
			STAT = ALTERLIST(data->list[d1.seq].unsched2, ucnt + 4)
		ENDIF
 
		data->list[d1.seq].unsched2[ucnt].order_id =  data->list[d1.seq].unsched[d2.seq].order_id
		data->list[d1.seq].unsched2[ucnt].display_line =  data->list[d1.seq].unsched[d2.seq].display_line
	endif
 
foot encntr_id
 
	data->list[d1.seq].unsched2_cnt = ucnt
	stat = alterlist(data->list[d1.seq].unsched2, ucnt)
 
WITH check
 
;Get PRN admins
call echo("GET PRN ADMINS")
 
SELECT distinct INTO "NL"
	prn_cnt = count(distinct ce.event_id) OVER(PARTITION BY ce.order_id, ce.encntr_id)
	, encntr_id = ce.encntr_id
 
FROM
	(dummyt   d1  with seq = size(data->list, 5))
	, (dummyt   d2  with seq = 1)
	, orders o
	, clinical_event ce
	, ce_med_result cmr
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].prn2, 5))
 
join d2
 
join o
	where o.order_id = data->list[d1.seq].prn2[d2.seq].order_id
 
join ce
	WHERE ce.person_id = o.person_id
	  and ce.event_end_dt_tm < cnvtdatetime(curdate, curtime3)
	  and ce.valid_until_dt_tm = cnvtdate(12312100)
	  and ce.result_status_cd in (AUTH_8_CV, ALT_8_CV, MOD_8_CV)
	  and ce.encntr_id = o.encntr_id
	  and ce.catalog_cd = o.catalog_cd
	  and ce.catalog_cd != 0.00
	  and cnvtupper(ce.event_title_text) != "DATE\TIME CORRECTION"
	  and cnvtupper(ce.event_tag) != "IN ERROR*"
	  and ce.view_level = 1
 
join cmr
	where cmr.event_id = ce.event_id
 
order by
	encntr_id
	, ce.catalog_cd
	, ce.order_id
	, ce.event_id
 
head report
	pcnt = 0
head ce.order_id
	null
head ce.event_id
	data->list[d1.seq].prn2[d2.seq].prn_disp = build2(trim(uar_get_code_display(ce.catalog_cd), 3), " - [admins = ", cnvtint(prn_cnt), "]")
	call echo(build2("prn_cnt for ", uar_get_code_display(ce.catalog_cd), " ", ce.order_id, " = ", prn_cnt))
	;if(pcnt > 0)
	call echo(data->list[d1.seq].prn2[d2.seq].prn_disp)
 
with nocounter
 
call echo(concat("ACTIVE MEDICATIONS query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                               	  LAB RESULTS
 
===============================================================================================================*/
call echo(concat("LAB RESULTS query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
select into "NL:"
	ex.event_set_cd
    , ex_event_set_disp = uar_get_code_display(ex.event_set_cd)
    , ex.event_set_level
    , cn_parent_event_set_disp = uar_get_code_display(cn.parent_event_set_cd)
    , cn.event_set_collating_seq
 
from
	clinical_event ce
    , v500_event_set_explode ex
    , v500_event_set_canon cn
;
 
plan ce
	where expand(idx, 1, data->cnt, ce.person_id, data->list[idx].person_id
    							  , ce.encntr_id, data->list[idx].encntr_id)
      AND ce.view_level = 1
      ;AND ce.publish_flag = 1
      AND ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100,00:00:00")
      AND ce.verified_dt_tm <= cnvtdatetime(curdate, curtime)
      AND ce.result_status_cd != INERROR_8_CV
	  and ce.event_cd in (select event_cd
							from v500_event_set_explode
						   where event_set_cd in ((select event_set_cd
						                             from v500_event_set_code
						                            where cnvtupper(event_set_name) ="LABORATORY")))
 
join ex
	where ce.event_cd = ex.event_cd
	  and ex.event_set_level = 0
 
join cn
	where ex.event_set_cd = cn.event_set_cd
 
;join ptr
;	where ptr.task_assay_cd = ce.task_assay_cd
 
ORDER BY
	ce.person_id
	, ce.event_cd
    , cnvtdatetime(ce.event_end_dt_tm) DESC
 
HEAD ce.person_id
 
	pos = locateval(idx, 1 ,data->cnt, ce.person_id, data->list[idx].person_id)
 
    lcnt = 0
    dcnt = 0
 
	STAT = ALTERLIST(data->list[pos].lab_result, 20)
 
head ce.event_cd
 
	if(pos > 0)
 
	    IF(ex.event_cd > 0)
 
			lcnt = lcnt + 1
			;check for available memory in the list
			IF(MOD(lcnt, 20) = 1 AND lcnt > 20)
				;if needed allocate memory for 20 more records
				STAT = ALTERLIST(data->list[pos].lab_result, lcnt + 19)
			ENDIF
 
			data->list[pos].lab_result[lcnt].lab_result_dt_grp_id 	= dcnt
			data->list[pos].lab_result[lcnt].event_cd 				= ce.event_cd
			data->list[pos].lab_result[lcnt].task_assay_cd 			= ce.task_assay_cd
			data->list[pos].lab_result[lcnt].encntr_id 				= ce.encntr_id
			data->list[pos].lab_result[lcnt].task_assay_key 		= build(uar_get_displaykey(ce.task_assay_cd))
			data->list[pos].lab_result[lcnt].task_assay_display 	= build(uar_get_code_display(ce.task_assay_cd))
			data->list[pos].lab_result[lcnt].event_name 			= uar_get_code_display(ce.event_cd)
			data->list[pos].lab_result[lcnt].normalcy_disp 			= substring(1, 1, trim(uar_get_code_display(ce.normalcy_cd)))
 			data->list[pos].lab_result[lcnt].parent_event_set_disp  = uar_get_code_display(cn.parent_event_set_cd)
 			data->list[pos].lab_result[lcnt].parent_event_set_cd	= cn.parent_event_set_cd
 			data->list[pos].lab_result[lcnt].event_set_cd			= cn.event_set_cd
 			data->list[pos].lab_result[lcnt].task_assay_disp		= uar_get_code_display(ce.task_assay_cd)
 			data->list[pos].lab_result[lcnt].catalog_cd				= ce.catalog_cd
 			data->list[pos].lab_result[lcnt].catalog_disp			= uar_get_code_display(ce.catalog_cd)
 			data->list[pos].lab_result[lcnt].lr_group_seq			= cn.event_set_collating_seq
 
		endif
 
	endif
 
	dcnt = 0
 
HEAD ce.event_end_dt_tm
 
	dcnt += 1
	STAT = ALTERLIST(data->list[pos].lab_result[lcnt].e_dt, dcnt)
 
	IF(ce.event_class_cd IN (TXT_53_CV, NUM_53_CV, DATE_53_CV))
    	IF(ce.event_class_cd = DATE_53_CV)
      		fdatetime = "  -   -       :  :  "
      		ufdatetime = substring(3, 16, ce.event_tag)
 
      		stat = movestring(ufdatetime, 7, fdatetime, 1, 2)
      		stat = movestring(ufdatetime, 1, fdatetime, 8, 4)
      		stat = movestring(ufdatetime, 9, fdatetime, 13, 2)
      		stat = movestring(ufdatetime, 11, fdatetime, 16, 2)
      		stat = movestring(ufdatetime, 13, fdatetime, 19, 2)
 
      		ufmonth = substring(5, 2, ufdatetime)
 
       		IF(ufmonth = "01")
       			fmonth = "JAN"
			ELSEIF(ufmonth = "02")
			    fmonth = "FEB"
			ELSEIF(ufmonth = "03")
			    fmonth = "MAR"
			ELSEIF(ufmonth = "04")
			    fmonth = "APR"
			ELSEIF(ufmonth = "05")
			    fmonth = "MAY"
			ELSEIF(ufmonth = "06")
			    fmonth = "JUN"
			ELSEIF(ufmonth = "07")
			    fmonth = "JUL"
			ELSEIF(ufmonth = "08")
			    fmonth = "AUG"
			ELSEIF(ufmonth = "09")
			    fmonth = "SEP"
			ELSEIF(ufmonth = "10")
			    fmonth = "OCT"
			ELSEIF(ufmonth = "11")
			    fmonth = "NOV"
			ELSEIF(ufmonth = "12")
			    fmonth = "DEC"
			ENDIF
 
       		stat = movestring(fmonth, 1, fdatetime, 4, 3)
       		CALL echo(fdatetime)
 
       		data->list[pos].lab_result[lcnt].e_dt[dcnt].result_value = format(cnvtdatetime(fdatetime), "mm/dd/yyyy hh:mm:ss;;q")
 
      	ELSE
      		data->list[pos].lab_result[lcnt].e_dt[dcnt].result_value = trim(ce.event_tag, 3)
      	ENDIF
 
    ELSE
     	data->list[pos].lab_result[lcnt].e_dt[dcnt].result_value = "See PowerChart"
    ENDIF
 
    size_result = size(data->list[pos].lab_result[lcnt].e_dt[dcnt].result_value, 5)
 
    IF(size_result > 20)
     	data->list[pos].lab_result[lcnt].e_dt[dcnt].result_value = concat(substring(1, 20, data->list[pos].lab_result[lcnt].result_value), "...")
    ENDIF
 
    IF(data->list[pos].lab_result[lcnt].e_dt[dcnt].result_value != "Not Reported")
     	data->list[pos].lab_result[lcnt].e_dt[dcnt].print_line = concat(data->list[pos].lab_result[lcnt].event_name
     															   , ": "
     															   , data->list[pos].lab_result[lcnt].result_value
     															   , " "
     															   , data->list[pos].lab_result[lcnt].normalcy_disp)
 
		data->list[pos].lab_result[lcnt].e_dt[dcnt].print_line_fb = concat(data->list[pos].lab_result[lcnt].result_value
																  	  , " "
																  	  , data->list[pos].lab_result[lcnt].normalcy_disp)
    ENDIF
 
    data->list[pos].lab_result[lcnt].e_dt[dcnt].order_id 				= ce.order_id
    data->list[pos].lab_result[lcnt].e_dt[dcnt].verify_dt_tm 			= format(ce.verified_dt_tm, "mm/dd hh:mm;;d")
    data->list[pos].lab_result[lcnt].e_dt[dcnt].ref_range 				= concat("( ", trim (ce.normal_low, 3)
     											                           , " - "
     											                           , trim(ce.normal_high, 3), " )" )
	data->list[pos].lab_result[lcnt].e_dt[dcnt].event_end_dt_tm			= format(ce.event_end_dt_tm, "mm/dd/yy hh:mm;;D")
 
	if(ce.normalcy_cd = HIGH_52_CV)
		data->list[pos].lab_result[lcnt].e_dt[dcnt].normalcy_disp			= "(H)"
	elseif(ce.normalcy_cd = LOW_52_CV)
		data->list[pos].lab_result[lcnt].e_dt[dcnt].normalcy_disp			= "(L)"
	elseif(ce.normalcy_cd = CRITICAL_52_CV)
		data->list[pos].lab_result[lcnt].e_dt[dcnt].normalcy_disp			= "(C)"
	endif
 
FOOT ce.event_cd
 
	;Finalize list size
	stat = alterlist(data->list[pos].lab_result[lcnt].e_dt, dcnt)
 
	if(dcnt > 0)
	 	data->list[pos].lab_result[lcnt].event_end_dt_tm1			= data->list[pos].lab_result[lcnt].e_dt[1].event_end_dt_tm
	 	data->list[pos].lab_result[lcnt].result1					= data->list[pos].lab_result[lcnt].e_dt[1].result_value
	 	data->list[pos].lab_result[lcnt].normalcy_disp1				= data->list[pos].lab_result[lcnt].e_dt[1].normalcy_disp
	 	if(dcnt > 1)
		 	data->list[pos].lab_result[lcnt].event_end_dt_tm2		= data->list[pos].lab_result[lcnt].e_dt[2].event_end_dt_tm
		 	data->list[pos].lab_result[lcnt].result2				= data->list[pos].lab_result[lcnt].e_dt[2].result_value
		 	data->list[pos].lab_result[lcnt].normalcy_disp2			= data->list[pos].lab_result[lcnt].e_dt[2].normalcy_disp
		 	if(dcnt > 2)
		 		data->list[pos].lab_result[lcnt].event_end_dt_tm3	= data->list[pos].lab_result[lcnt].e_dt[3].event_end_dt_tm
		 		data->list[pos].lab_result[lcnt].result3			= data->list[pos].lab_result[lcnt].e_dt[3].result_value
		 		data->list[pos].lab_result[lcnt].normalcy_disp3		= data->list[pos].lab_result[lcnt].e_dt[3].normalcy_disp
		 	endif
	 	endif
	 endif
 
FOOT ce.person_id
 
 	;Finalize list size
 	stat = alterlist(data->list[pos].lab_result, lcnt)
 
WITH nocounter, memsort
 
;Group Labs into categories
select into "NL:"
	parent_event_set_disp = data->list[d1.seq].lab_result[d2.seq].parent_event_set_disp
 	, parent_event_set_cd = data->list[d1.seq].lab_result[d2.seq].parent_event_set_cd
	, event_cd = data->list[d1.seq].lab_result[d2.seq].event_cd
	, group_collating_seq = data->list[d1.seq].lab_result[d2.seq].lr_group_seq
from
	(dummyt d1 with seq = size(data->list, 5))
	, (dummyt d2 with seq = 1)
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].lab_result, 5))
 
join d2
 
order by
	d1.seq
;	, group_collating_seq
	, PARENT_EVENT_SET_CD
	;, es3_event_set_collating_seq
	;, es4_event_set_collating_seq
	, group_collating_seq
	, event_cd
 
head d1.seq
 
	gcnt = 0
	stat = alterlist(data->list[d1.seq].lrgrp, 10)
 
head PARENT_EVENT_SET_CD
 
	gcnt += 1
 	stat = alterlist(data->list[d1.seq].lrgrp, gcnt)
 
	data->list[d1.seq].lrgrp[gcnt].lr_group						= data->list[d1.seq].lab_result[d2.seq].parent_event_set_disp
	data->list[d1.seq].lrgrp[gcnt].group_collating_seq			= data->list[d1.seq].lab_result[d2.seq].lr_group_seq
 
	cnt = 0
	stat = alterlist(data->list[d1.seq].lrgrp[gcnt].evnts, 30)
 
head group_collating_seq
	null
head event_cd
 
	cnt += 1
 	stat = alterlist(data->list[d1.seq].lrgrp[gcnt].evnts, cnt)
 
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].event_name					= data->list[d1.seq].lab_result[d2.seq].event_name
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].event_cd						= data->list[d1.seq].lab_result[d2.seq].event_cd
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].catalog_cd					= data->list[d1.seq].lab_result[d2.seq].catalog_cd
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].catalog_disp					= data->list[d1.seq].lab_result[d2.seq].catalog_disp
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].task_assay_cd					= data->list[d1.seq].lab_result[d2.seq].task_assay_cd
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].task_assay_disp				= data->list[d1.seq].lab_result[d2.seq].task_assay_disp
 	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].event_seq				= data->list[d1.seq].lab_result[d2.seq].es4_event_set_collating_seq
 
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].event_end_dt_tm1				= data->list[d1.seq].lab_result[d2.seq].event_end_dt_tm1
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].result1						= data->list[d1.seq].lab_result[d2.seq].result1
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].normalcy_disp1				= data->list[d1.seq].lab_result[d2.seq].normalcy_disp1
 
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].event_end_dt_tm2			= data->list[d1.seq].lab_result[d2.seq].event_end_dt_tm2
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].result2					= data->list[d1.seq].lab_result[d2.seq].result2
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].normalcy_disp2			= data->list[d1.seq].lab_result[d2.seq].normalcy_disp2
 
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].event_end_dt_tm3		= data->list[d1.seq].lab_result[d2.seq].event_end_dt_tm3
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].result3					= data->list[d1.seq].lab_result[d2.seq].result3
	data->list[d1.seq].lrgrp[gcnt].evnts[cnt].normalcy_disp3			= data->list[d1.seq].lab_result[d2.seq].normalcy_disp3
 
foot PARENT_EVENT_SET_CD
 
	data->list[d1.seq].lrgrp[gcnt].event_cnt = cnt
	stat = alterlist(data->list[d1.seq].lrgrp[gcnt].evnts, cnt)
 
foot report
 
 	data->list[d1.seq].LRGRP_CNT = gcnt
	stat = alterlist(data->list[d1.seq].lrgrp, gcnt)
 
with nocounter
 
SELECT into "NL:"
	LRGRP_LR_GROUP = SUBSTRING(1, 30, DATA->list[D1.SEQ].lrgrp[D2.SEQ].lr_group)
	, EVNTS_EVENT_NAME = SUBSTRING(1, 30, DATA->list[D1.SEQ].lrgrp[D2.SEQ].evnts[D3.SEQ].event_name)
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(DATA->list, 5))
	, (DUMMYT   D2  WITH SEQ = 1)
	, (DUMMYT   D3  WITH SEQ = 1)
	, v500_event_set_explode ec
    , v500_event_set_canon cn
	, code_value cv1
	, code_value cv2
	, v500_event_set_canon cn2
 
plan d1
	where maxrec(d2, size(data->list[d1.seq].lrgrp, 5))
 
join d2
	where maxrec(d3, size(data->list[d1.seq].lrgrp[d2.seq].evnts, 5))
 
join d3
 
join ec
	where ec.event_cd = data->list[d1.seq].lrgrp[d2.seq].evnts[d3.seq].event_cd
 
join cn
	where cn.event_set_cd = ec.event_set_cd
 
join cv1
	where cv1.code_value = ec.event_cd
 
join cv2
	where cv2.code_value = cn.event_set_cd
	  and cv1.display = cv2.display
 
join cn2
	where cn2.event_set_cd = cn.parent_event_set_cd
 
detail
 
	sort = build(format(cn2.event_set_collating_seq,"##;P0")
 				,substring(1,7,uar_get_code_display(cn.parent_event_set_cd))
 				,"-"
 				,format(cn.event_set_collating_seq,"#####;P0"))
 
 	 data->list[d1.seq].lrgrp[d2.seq].evnts[d3.seq].event_seq_disp = sort
 
WITH NOCOUNTER
 
call echo(concat("LAB RESULTS query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                               	  MICRO RESULTS
 
===============================================================================================================*/
call echo(concat("MICRO RESULTS query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
SELECT INTO "nl:"
 
   result_val = trim(ce.result_val)
   , event_title_text = trim(ce.event_title_text)
   , event = uar_get_code_display(ce.event_cd)
   , p_event_id = ce.parent_event_id
   , event_id = ce.event_id
   , ce.clinsig_updt_dt_tm
   , ce.event_start_dt_tm
   , ce.event_end_dt_tm
   , result_status = uar_get_code_display(ce.result_status_cd)
   , accession = trim(ce.accession_nbr, 3)
   , spec_desc = decode(csc.seq, uar_get_code_display(csc.source_type_cd), " ")
   , method = decode(ces.seq, substring(1, 30, uar_get_code_display(ces.detail_susceptibility_cd)), " ")
 
FROM
	orders o
    , clinical_event ce
    , ce_specimen_coll csc
    , ce_microbiology cem
    , ce_susceptibility ces
 
PLAN o
    WHERE expand(idx, 1, data->cnt, o.person_id, data->list[idx].person_id
    							  , o.encntr_id, data->list[idx].encntr_id)
    AND o.catalog_type_cd = LAB_6000_CV
    AND o.activity_type_cd = MICROBIOLOGY_106_CV
    AND o.template_order_flag IN (0, 2)
 
JOIN ce
    WHERE ce.order_id = o.order_id
      AND ce.view_level = 1
      AND ce.publish_flag = 1
      AND ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
      AND ce.event_end_dt_tm <= cnvtdatetime(curdate, curtime)
      AND ce.result_status_cd != INERROR_8_CV
 
JOIN csc
    WHERE csc.event_id = outerjoin(ce.event_id)
 
JOIN cem
    WHERE cem.event_id = outerjoin(csc.event_id)
      AND cem.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
JOIN ces
    WHERE ces.event_id = outerjoin(cem.event_id)
      AND ces.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
      AND ces.micro_seq_nbr = outerjoin(cem.micro_seq_nbr)
 
ORDER BY
	o.person_id
    , cnvtdatetime(ce.event_end_dt_tm) DESC
    , ce.parent_event_id DESC
    , ce.event_id
    , event
 
HEAD REPORT
 
    ce_cnt = 0
    stat = alterlist(ce_data->qual, 10)
 
HEAD o.person_id
 
	pos = locateval(idx, 1 ,data->cnt, o.person_id, data->list[idx].person_id)
 
    mb_cnt = 0
    stat = alterlist (data->list[pos].micro_result, 10)
 
HEAD ce.parent_event_id
 
	if(pos > 0)
 
    	IF (ce.parent_event_id > 0)
 
    		mb_cnt = mb_cnt + 1
    		ce_cnt = ce_cnt + 1
 
     		IF(mod(mb_cnt, 10) = 1)
     			stat = alterlist (data->list[pos].micro_result, mb_cnt + 10)
     		ENDIF
 
     		IF(mod(ce_cnt, 10) = 1)
     			stat = alterlist(ce_data->qual, ce_cnt + 10)
     		ENDIF
 
     		IF(ce_cnt > size(ce_data->qual, 5))
     			 stat = alterlist(ce_data->qual, ce_cnt)
     		ENDIF
 
     		IF(mb_cnt > size(data->list[pos].micro_result, 5))
     	 		stat = alterlist(data->list[pos].micro_result, mb_cnt)
     		ENDIF
 
			ce_data->qual[ce_cnt].parent_event_id 					= ce.parent_event_id
			ce_data->qual[ce_cnt].event_id 							= ce.event_id
 
			data->list[pos].micro_result[mb_cnt].parent_event_id 	= ce.parent_event_id
     		data->list[pos].micro_result[mb_cnt].event_id 			= ce.event_id
     		data->list[pos].micro_result[mb_cnt].event_name 		= event
     		data->list[pos].micro_result[mb_cnt].clinsig_dt_tm 		= format(ce.clinsig_updt_dt_tm, "mm/dd/yy hh:mm;;d")
     		data->list[pos].micro_result[mb_cnt].event_end_dt_tm 	= format(ce.event_end_dt_tm, "mm/dd/yy hh:mm;;D")
     		data->list[pos].micro_result[mb_cnt].event_start_dt_tm 	= format(ce.event_start_dt_tm, "mm/dd/yy hh:mm;;d")
     		data->list[pos].micro_result[mb_cnt].result_status 		= uar_get_code_display(ce.result_status_cd)
     		data->list[pos].micro_result[mb_cnt].accession 			= trim(ce.accession_nbr, 3)
     		data->list[pos].micro_result[mb_cnt].event_title_text 	= trim(ce.event_title_text)
     		data->list[pos].micro_result[mb_cnt].update_date 		= format(ce.clinsig_updt_dt_tm ,"mm/dd;;d")
     		data->list[pos].micro_result[mb_cnt].date_collect 		= format(ce.event_end_dt_tm ,"mm/dd hh:mm;;d")
     		data->list[pos].micro_result[mb_cnt].verified_dt_tm 	= format(ce.verified_dt_tm ,"mm/dd hh:mm;;d")
     		data->list[pos].micro_result[mb_cnt].event_tag 			= trim(ce.event_tag, 3)
 
     		IF(size(trim(ce.result_val, 3)) > 40)
     			data->list[pos].micro_result[mb_cnt].result_val 	= concat(substring(1, 40, ce.result_val), " ...")
     		ELSE
     			data->list[pos].micro_result[mb_cnt].result_val 	= trim(ce.result_val, 3)
     		ENDIF
 
     		IF(spec_desc > " ")
     		 	data->list[pos].micro_result[mb_cnt].specimen_desc 	= spec_desc
     		ENDIF
 
     		IF(method > " ")
     			data->list[pos].micro_result[mb_cnt].sensi_ind 		= 1
     		ELSE
      			IF(data->list[pos].micro_result[mb_cnt].sensi_ind != 1)
      				data->list[pos].micro_result[mb_cnt].sensi_ind 	= 0
      			ENDIF
     		ENDIF
 
     		IF(substring(1, 1, data->list[pos].micro_result[mb_cnt].date_collect) = "0")
     			data->list[pos].micro_result[mb_cnt].date_collect 	= substring(2, (-(1) + size(trim(data->list[pos].micro_result[mb_cnt].date_collect, 3)))
     																		  , data->list[pos].micro_result[mb_cnt].date_collect)
     		ENDIF
 
     		IF(substring (1, 1, data->list[pos].micro_result[mb_cnt].update_date) = "0")
     			data->list[pos].micro_result[mb_cnt].update_date = substring(2, (-(1) + size(trim(data->list[pos].micro_result[mb_cnt].update_date, 3)))
     																	   , data->list[pos].micro_result[mb_cnt].update_date)
     		ENDIF
    	ENDIF
 
	endif
 
FOOT ce.parent_event_id
 
    IF(mb_cnt > size(data->list[pos].micro_result, 5))
    	stat = alterlist (data->list[pos].micro_result, mb_cnt)
    ENDIF
 
    IF(mb_cnt > 0)
    	data->list[pos].micro_result[mb_cnt].result_status = result_status
    ENDIF
 
FOOT  o.person_id
 
    data->list[pos].mb_cnt = mb_cnt
 
WITH nocounter, outerjoin = d, dontcare = csc
 
;Get micro blob
SELECT INTO "nl:"
 
  event_id = ce.event_id
FROM
	(dummyt d1 WITH seq = value(size(ce_data->qual, 5)))
	, clinical_event ce
   	, ce_blob cb
 
PLAN d1
 
JOIN ce
	WHERE ce.parent_event_id = ce_data->qual[d1.seq].parent_event_id
 
JOIN cb
   	WHERE cb.event_id = ce.event_id
   	  AND cb.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
 
ORDER BY
	ce.parent_event_id
   	, ce.event_id desc
 
HEAD REPORT
 
   	blob_cnt = 0
 	stat = alterlist(microblob->list, 100)
 
HEAD event_id
 
   	blob_cnt = blob_cnt + 1
 
   	IF(MOD(blob_cnt, 10) = 1 AND blob_cnt > 100)
   		stat = alterlist(microblob->list, blob_cnt + 1)
   	ENDIF
 
	microblob->list[blob_cnt].parent_event_id 	= ce.parent_event_id
	microblob->list[blob_cnt].event_id 			= ce.event_id
	microblob->list[blob_cnt].event_tag 		= ce.event_tag
	microblob->list[blob_cnt].compression_cd 	= cb.compression_cd
	microblob->list[blob_cnt].blob_contents 	= trim(substring(1, 32000, cb.blob_contents))
 
DETAIL
 
   	col 01
   	blob_cnt
 
   	CALL echo(build("microblob:- ", ce.parent_event_id, microblob->list[blob_cnt].blob_contents))
 
   	row + 1
 
FOOT REPORT
 
   	stat = alterlist (microblob->list, blob_cnt)
 
   	microblob->qual = blob_cnt
   	CALL echo(build("*** Blob Cnt   =>", blob_cnt))
 
WITH nocounter, memsort
 
;report writer variables
declare blobmissing = vc
declare blobout = vc
declare blob_return_len = w8
declare eol = i4
declare specialrequestpartofblob = vc
declare culturepartofblob = vc
declare otherpartofblob = vc
declare tempblob = vc
;declare use_blob_out = boolean
declare t = i2
declare delimitercurrent = i2
declare reportblob = vc
;declare gramstain_exists = boolean
declare gramstainblob = vc
declare temp_disp = vc
 
select into "NL:"
	list_encntr_id = data->list[d1.seq].encntr_id
 
from
	(dummyt   d1  with seq = size(data->list, 5))
 
plan d1
 
detail
 
	FOR(a = 1 TO data->list[d1.seq].mb_cnt)
 
		IF(size(trim(data->list[d1.seq].micro_result[a].specimen_desc)) = 0)
 
			temp_disp = concat(data->list[d1.seq].micro_result[a].date_collect, "-"
							   , trim(substring(1, 30, data->list[d1.seq].micro_result[a].event_name)), ": ")
 
        ELSE
        	IF( (trim (data->list[d1.seq].micro_result[a].event_name) = "URINE CULTURE")
        	 AND (trim(data->list[d1.seq].micro_result[a].specimen_desc) = "Urine") )
 
        		temp_disp = concat(data->list[d1.seq].micro_result[a].date_collect, "-"
        						  , trim(substring(1, 30, data->list[d1.seq].micro_result[a].event_name)), ": ")
 
        	ELSE
         		IF( (trim(data->list[d1.seq].micro_result[a].event_name) = "BLOOD CULTURE")
         		 AND (trim(data->list[d1.seq].micro_result[a].specimen_desc) = "Peripheral Blood") )
 
          			temp_disp = concat(data->list[d1.seq].micro_result[a].date_collect, "-"
          							  , trim(substring(1, 30, data->list[d1.seq].micro_result[a].event_name)), ": ")
 
         		ELSE
         			temp_disp = concat(data->list[d1.seq].micro_result[a].date_collect, "-"
         							   , trim(substring(1, 30, data->list[d1.seq].micro_result[a].event_name)), "("
         							   , trim(substring(1, 30, data->list[d1.seq].micro_result[a].specimen_desc)), ")" , ": ")
         		ENDIF
        	ENDIF
		ENDIF
 
       	blobmissing = "YES"
       	gramstainblob = fillstring(8000, " ")
       	reportblob = fillstring(8000, " ")
 
		FOR(i = 1 TO size(microblob->list, 5))
 
			IF(microblob->list[i].parent_event_id = data->list[d1.seq].micro_result[a].parent_event_id)
         		IF(microblob->list[i].compression_cd = OCFCOMP_120_CV)
         			blobout = fillstring (32000, " ")
         			blob_return_len = 0
         			blob_return_len2 = 0
          			CALL uar_ocf_uncompress(microblob->list[i].blob_contents, textlen (microblob->list[i].blob_contents), blobout
          									, size(blobout), blob_return_len)
         		ELSE
         			blobout = microblob->list[i].blob_contents
         			blob_return_len = size(trim(blobout)) + 1
         		ENDIF
 
         		blobmissing = "NO"
         		blobout = replace(blobout, char(10), "; ", 0)
         		blobout = replace(blobout, char(13), "", 0)
         		blobout = replace(blobout, char(0), "", 0)
         		blobout = replace(blobout, "ocf_blob", "", 0)
 
         		blob_return_len = size(trim(blobout))
 
         		eol = size(trim(blobout))
 
         		specialrequestpartofblob = fillstring(8000, " ")
         		culturepartofblob = fillstring(8000, " ")
         		otherpartofblob = fillstring(8000, " ")
         		tempblob = fillstring(8000, " ")
 
         		use_blob_out = true
         		t = 1
         		delimitercurrent = 1
 
         		IF(microblob->list[i].event_tag IN ("Preliminary Report", "Final", "Amend"))
         			reportblob = concat(microblob->list[i].event_tag, ": ", trim(blobout))
         		ELSEIF(microblob->list[i].event_tag = "Gram")
         			gramstain_exists = true
         			gramstainblob = concat(microblob->list[i].event_tag, ": ", trim(blobout))
         		ENDIF
        	ENDIF
        endfor
 
        IF(gramstain_exists = true)
        	temp_disp = concat(trim(temp_disp), " ", trim(reportblob), trim(gramstainblob))
        ELSE
       		temp_disp = concat(trim(temp_disp), " ", trim(reportblob))
        ENDIF
 
        IF(data->list[d1.seq].micro_result[a].sensi_ind = 1)
        	temp_disp = concat(trim(temp_disp), " *** Sensi's Available in PowerChart ***")
        ENDIF
 
        IF(blobmissing = "YES")
        	temp_disp = concat(trim(temp_disp), " Warning!: Report could not be displayed here. See Lab Tab (Micro and/or PATHOLOGY Sections).")
        ENDIF
 
        IF(substring(size(trim(temp_disp)), 1, temp_disp) = ";")
        	temp_disp = substring(1, (- (1 ) + size(trim(temp_disp))), trim(temp_disp))
        ENDIF
 
        temp_disp = concat(trim(temp_disp), " | Last Update Date/Time: (", data->list[d1.seq].micro_result[a].verified_dt_tm, ")")
 
        IF(findstring("Prelim", data->list[d1.seq].micro_result[a].result_status) > 0)
        	temp_disp = concat(trim(temp_disp), " [ Prelim ]")
        ELSE
        	temp_disp = concat(trim(temp_disp), " [ ", trim(data->list[d1.seq].micro_result[a].result_status), " ]")
        ENDIF
 
        data->list[d1.seq].micro_result[a].temp_disp = temp_disp
        call echo(temp_disp)
	endfor
 
WITH NOCOUNTER
 
call echo(concat("MICRO RESULTS query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*===============================================================================================================
 
                                             TOTAL I/O FLUID BALANCE
 
===============================================================================================================*/
call echo(concat("TOTAL I/O FLUID BALANCE query START:  ", format(curtime3, "HH:MM:SS:CC;;M")))
 
select into "NL:"
from
	ce_intake_output_result cir
	, clinical_event ce
 
plan cir
	where expand(idx, 1, data->cnt, cir.encntr_id, data->list[idx].encntr_id)
 
join ce
	where ce.event_id = cir.event_id
	  and ce.result_status_cd in (AUTH_8_CV, ALT_8_CV, MOD_8_CV)
	  and ce.valid_until_dt_tm = cnvtdate(12312100)
	  and ce.valid_from_dt_tm <= cnvtdatetime(curdate, curtime)
	  and cnvtupper(ce.event_title_text) != "DATE\TIME CORRECTION"
	  and ce.view_level = 1
 
order by
	cir.encntr_id
	, cir.event_id
 
head report
	cnt = 0
	pos = 0
head cir.encntr_id
 
	i_total = 0.00
	o_total = 0.00
 
	pos = locatevalsort(idx, 1, data->cnt, cir.encntr_id, data->list[idx].encntr_id)
 
head cir.event_id
 
	cnt += 1
	STAT = ALTERLIST(data->list[pos]->io_result, cnt)
 
	if(cir.io_type_flag = 1) ;Intake
		data->list[pos]->io_result[cnt].i_result	= cir.io_volume
		i_total = i_total + cir.io_volume
	elseif(cir.io_type_flag = 2) ;Output
		data->list[pos]->io_result[cnt].o_result	= cir.io_volume
		o_total = o_total + cir.io_volume
	else
		null
	endif
 
foot cir.encntr_id
 
	data->list[pos]->i_tot_vol	= i_total
	data->list[pos]->o_tot_vol	= o_total
 
	stat = alterlist(data->list[pos].io_result, cnt)
 
with nocounter
 
call echo(concat("TOTAL I/O FLUID BALANCE query END:  ", format(curtime3, "HH:MM:SS:CC;;M")))
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
                                               REPORT FORMATTING
 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
if(TESTENV_IND)
	call echorecord(data)
endif
/*===============================================================================================================
 
                                   					OUTPUT
 
===============================================================================================================*/
#output_distribution
/*===============================================================================================================
 
                                    				OUTPUT TO JSON
 
===============================================================================================================*/
SET patienthtml = "<html><body><span style='font-size:8.0pt;font-family:Helvetica'><table border=0 cellspacing=0 cellpadding=4>"
 
call alterlist(html_log->list,data->cnt)
for(x = 1 to data->cnt)
 
	set html_log->list[x].start = textlen(trim(patienthtml,3)) + 1
 
 	if(x = 1)
 		set line_cnt = 6
 	else
 		set line_cnt = 0
 	endif
 
 	set patienthtml = build2(patienthtml, "<div class='text ellipsis'><span class='text-concat'>")
 
 	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
 	;while(line_cnt <= 65) ;<<<<<START WHILE FOR PAGE BREAKS
 		set line_cnt = line_cnt + 1
 		if(line_cnt = 65)
 			;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 			set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 			set line_cnt = 0
 		endif
 
	;Start first table with patient demographics
 	set patienthtml = build2(patienthtml,"<div>",'<table style="width:100% colspan=8">',"<tr>"
 	    ,"<td class=patient-data-header>Location</td>"
		,"<td class=patient-data-header>Name</td>"
		,"<td class=patient-data-header>MRN</td>"
		,"<td class=patient-data-header>FIN</td>"
		,"<td class=patient-data-header>DOB</td>"
		,"<td class=patient-data-header>Age</td>"
		,"<td class=patient-data-header>Gender</td>"
		,"<td class=patient-data-header>Admit Date</td>"
		,"</tr>")
 
 	set line_cnt = line_cnt + 1
 	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
 
	set patienthtml = build2(patienthtml,"<tr>"
		;,"<td class=patient-data>"
		,"<td class=patient-info>",data->list[x].location,"</td>"
		,"<td class=patient-info>",data->list[x].patient_name,"</td>"
		,"<td class=patient-info>",data->list[x].mrn,"</td>"
		,"<td class=patient-info>",data->list[x].fin,"</td>"
		,"<td class=patient-info>",data->list[x].dob,"</td>"
		,"<td class=patient-info>",data->list[x].age,"</td>"
		,"<td class=patient-info>",data->list[x].gender,"</td>"
		,"<td class=patient-info>",data->list[x].admit_dt_tm_disp,"</td>"
		,"</tr>","</table>","</div>"
		,"<div>&nbsp</div>")
 	;End first table
 	set line_cnt = line_cnt + 2
 	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
 
 	;Start second table with patient information
	set patienthtml = build2(patienthtml ,"<div>",'<table style="width:100% colspan=6">',"<tr>"
		,"<td class=patient-data-header>","Illness Severity","</td>"
		,"<td class=patient-data-header>","Allergies","</td>"
		,"<td class=patient-data-header>","Medical Service","</td>"
		,"<td class=patient-data-header>","Admitting PCP","</td>"
		,"<td class=patient-data-header>","Dosing Weight","</td>"
		,"<td class=patient-data-header>","Code Status","</td>"
		,"</tr>")
 	set line_cnt = line_cnt + 1
 	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
 
		;Print Illness Severity
		set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
		set patienthtml = build2(patienthtml
			,"<div>",data->list[x]->illness_severity,"</div></td>")
		;End print Illness Severity
 
 		;Print all allergies
		set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
		set y = 0
		for(y = 1 to data->list[x].allergy_cnt)
			set line_cnt = line_cnt + 1
			if(line_cnt = 65)
 				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 				set line_cnt = 0
 			endif
			set patienthtml = build2(patienthtml
				,"<div>",data->list[x]->allergies[y].allergy,"</div>")
		endfor
		set patienthtml = build2(patienthtml, "</td>")
		;End print all allergies
 
		;Print Medical Service
		set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
		set patienthtml = build2(patienthtml
			,"<div>",data->list[x]->med_service,"</div></td>")
		;End print Medical Service
 
		;Print Admitting PCP
		set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
		set patienthtml = build2(patienthtml
			,"<div>",data->list[x]->admitting_pcp,"</div></td>")
		;End print Admitting PCP
 
		;Print Dosing Weight & Date
		set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
		set patienthtml = build2(patienthtml
			,"<div>",data->list[x]->dosing_weight,"</div></td>")
		;End print Dosing Weight & Date
 
		;Print Code Status
		set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
		set patienthtml = build2(patienthtml
			,"<div>",data->list[x]->code_status,"</div></td>")
		;End print Code Status
 
 		set patienthtml = build2(patienthtml
 			,"</tr>","</table>","</div>"
 			,"<div>&nbsp</div>")
 		;^End Second table
 		set line_cnt = line_cnt + 1
 		if(line_cnt = 65)
 			;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 			set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 			set line_cnt = 0
 		endif
 
	;***********************************
	set patienthtml = build2(patienthtml ,"<div>",'<table style="width:100%">',"<tr>"
		,"<td class=patient-data-header>","Patient Summary:","</td>"
		,"</tr>")
	set line_cnt = line_cnt + 1
	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
 
	if(data->list[x].patient_summary != "")
		set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
		set patienthtml = build2(patienthtml
			,"<div>",data->list[x]->patient_summary,"</div></td>")
 
		set txtlen = textlen(data->list[x]->patient_summary)
		if(txtlen <= 1200)
			set line_cnt = line_cnt + 1
			if(line_cnt = 65)
 				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 				set line_cnt = 0
 			endif
		elseif(txtlen <= 2400)
			set line_cnt = line_cnt + 2
			if(line_cnt = 65)
 				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 				set line_cnt = 0
 			endif
		elseif(txtlen <= 3600)
			set line_cnt = line_cnt + 3
			if(line_cnt = 65)
 				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 				set line_cnt = 0
 			endif
		else
			set line_cnt = line_cnt + 4
			if(line_cnt = 65)
 				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 				set line_cnt = 0
 			endif
		endif
 
	else
		set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
		set patienthtml = build2(patienthtml
					,"<div>N/A</div></td>")
 
		set line_cnt = line_cnt + 1
		if(line_cnt = 65)
 			;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 			set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 			set line_cnt = 0
 		endif
	endif
 	;^End Patient Summary
 
 	;Meds, Labs & Micro results header
	set patienthtml = build2(patienthtml ,"<div>",'<table style="width:100% colspan=2">',"<tr>"
		,"<td class=patient-data-header>","Medications:","</td>"
		,"<td class=patient-data-header>","Lab Results:","</td>"
		,"</tr>")
 
	set line_cnt = line_cnt + 1
	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
 
	;Print all medications
	set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
	if(data->list[x].med_cnt > 0)
	if(size(data->list[x].sched2, 5) > 0)
 
		set patienthtml = build2(patienthtml, "<div><b>---Scheduled---</b></div>")
		set line_cnt = line_cnt + 1
 		set y = 0
 
		for(y = 1 to size(data->list[x].sched2, 5))
			set line_cnt = line_cnt + 1
			if(line_cnt = 65)
				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
			else
				set patienthtml = build2(patienthtml
					,"<div>",data->list[x]->sched2[y].display_line,"</div>")
			endif
		endfor
 
	endif
 
	if(size(data->list[x].prn2, 5) > 0)
		set patienthtml = build2(patienthtml, "<div><b>---PRN---</b></div>")
		set line_cnt = line_cnt + 1
		set y = 0
 
		for(y = 1 to size(data->list[x].prn2, 5))
			set line_cnt = line_cnt + 1
			if(line_cnt = 65)
				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
			else
				set patienthtml = build2(patienthtml
					,"<div>",data->list[x]->prn2[y].display_line,"</div>")
			endif
		endfor
	endif
 
	if(size(data->list[x].cont2, 5) > 0)
		set patienthtml = build2(patienthtml, "<div><b>---Continuous Infusions---</b></div>")
		set line_cnt = line_cnt + 1
		set y = 0
 
		for(y = 1 to size(data->list[x].cont2, 5))
			set line_cnt = line_cnt + 1
			if(line_cnt = 45)
				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
			else
				set patienthtml = build2(patienthtml
					,"<div>",data->list[x]->cont2[y].display_line,"</div>")
			endif
		endfor
	endif
 
	if(size(data->list[x].unsched2, 5) > 0)
		set patienthtml = build2(patienthtml, "<div><b>---Unscheduled---</b></div>")
		set line_cnt = line_cnt + 1
		set y = 0
		for(y = 1 to size(data->list[x].unsched2, 5))
			set line_cnt = line_cnt + 1
 
			set patienthtml = build2(patienthtml
					,"<div>",data->list[x]->unsched2[y].display_line,"</div>")
		endfor
	endif
 
	else
		set patienthtml = build2(patienthtml, "<div>","There are no Medications to report.", "</div>")
		set line_cnt = line_cnt + 1
	endif
 
	set patienthtml = build2(patienthtml, "</td>")
	;End print all medications
 
	;Print all Lab Results in a 4 column table
	set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
	;Start 4 column table for Labs
 	set patienthtml = build2(patienthtml, "<div><table class=labs>")
 
 	if(size(data->list[x].lrgrp, 5)  > 0)
		set y = 0
 		for(y = 1 to size(data->list[x].lrgrp, 5))
 			set line_cnt = line_cnt + 1
			if(line_cnt = 65)
 
 				set patienthtml = build2(patienthtml, "</td></table></div></td><P style=page-break-after:always>")
 
 				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 				set line_cnt = 0
 			else
 				if(data->list[x]->lrgrp[y].lr_group != "")
					set patienthtml = build2(patienthtml, "<tr><td><b>", "---", data->list[x].lrgrp[y].lr_group, "---", "</b></td></tr>")
					for(z = 1 to size(data->list[x].lrgrp[y].evnts, 5)) ;events for each group
 
						set patienthtml = build2(patienthtml
										 , " <tr><td>",data->list[x].lrgrp[y].evnts[z].event_name, ":", "</td>")
						if(data->list[x].lrgrp[y].evnts[z].normalcy_disp1 = "(C)")
							set patienthtml = build2(patienthtml
											 , " <td><b>", data->list[x].lrgrp[y].evnts[z].result1, "&nbsp", data->list[x].lrgrp[y].evnts[z].normalcy_disp1
											 , "&nbsp", "&nbsp", "   [",data->list[x].lrgrp[y].evnts[z].event_end_dt_tm1, "]", "</b></td>")
						else
							set patienthtml = build2(patienthtml
											 , " <td>", data->list[x].lrgrp[y].evnts[z].result1, "&nbsp", data->list[x].lrgrp[y].evnts[z].normalcy_disp1
											 , "&nbsp", "&nbsp", "   [",data->list[x].lrgrp[y].evnts[z].event_end_dt_tm1, "]", "</td>")
						endif
						if(data->list[x].lrgrp[y].evnts[z].result2 != "")
							if(data->list[x].lrgrp[y].evnts[z].normalcy_disp2 = "(C)")
								set patienthtml = build2(patienthtml
											 , " <td><b>", data->list[x].lrgrp[y].evnts[z].result2, "&nbsp", data->list[x].lrgrp[y].evnts[z].normalcy_disp2
											 , "&nbsp", "&nbsp", "   [",data->list[x].lrgrp[y].evnts[z].event_end_dt_tm2, "]", "</b></td>")
							else
								set patienthtml = build2(patienthtml
											 , " <td>", data->list[x].lrgrp[y].evnts[z].result2, "&nbsp", data->list[x].lrgrp[y].evnts[z].normalcy_disp2
											 , "&nbsp", "&nbsp", "   [",data->list[x].lrgrp[y].evnts[z].event_end_dt_tm2, "]", "</td>")
							endif
						endif
						if(data->list[x].lrgrp[y].evnts[z].result3 != "")
							if(data->list[x].lrgrp[y].evnts[z].normalcy_disp3 = "(C)")
								set patienthtml = build2(patienthtml
											 , " <td><b>", data->list[x].lrgrp[y].evnts[z].result3, "&nbsp", data->list[x].lrgrp[y].evnts[z].normalcy_disp3
											 , "&nbsp", "&nbsp", "   [",data->list[x].lrgrp[y].evnts[z].event_end_dt_tm3, "]", "</b></td>")
							else
								set patienthtml = build2(patienthtml
											 , " <td>", data->list[x].lrgrp[y].evnts[z].result3, "&nbsp", data->list[x].lrgrp[y].evnts[z].normalcy_disp3
											 , "&nbsp", "&nbsp", "   [",data->list[x].lrgrp[y].evnts[z].event_end_dt_tm3, "]", "</td>")
							endif
 
						endif
 
					endfor ;all events for group
 
					endif
					set line_cnt = line_cnt + 1
					if(line_cnt = 65)
 						;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 						set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 						set line_cnt = 0
 					endif
 endif
		endfor
 
	else
		set patienthtml = build2(patienthtml, "<div>","There are no lab results to report.", "</div></tr></table>")
	endif
 
 	;End 4 column table
 	set patienthtml = build2(patienthtml, "</tr></table><table><tr>&nbsp</tr></table>")
 
	;;;;;micro results
	set patienthtml = build2(patienthtml,"<div><b><u>","Most Recent Micro Results Within 24 hours:", "</u></b></div>")
	if(data->list[x].mb_cnt > 0)
 		set y = 0
		for(y = 1 to data->list[x].mb_cnt)
 
			set patienthtml = build2(patienthtml
				, "<div>", data->list[x].micro_result[y].temp_disp,"</div>")
		endfor
	else
		set patienthtml = build2(patienthtml, "<div>", "There are no micro results to report.", "</div>")
	endif
	;End print all Lab and Micro Results
 
 	;END TABLE DETAILS
 	set patienthtml = build2(patienthtml,"</td><div>&nbsp</div></table></div>")
 	set line_cnt = line_cnt + 1
 	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
 
 	;**********************START NEXT TABLE HEADER
	set patienthtml = build2(patienthtml ,"<div>",'<table style="width:100% colspan=2">',"<tr>"
		,"<td class=patient-data-header>","Total Number of PRN Doses Given Within 24 Hours","</td>"
		,"<td class=patient-data-header>","Total I/O Fluid Balance","</td>"
		,"</tr>")
	set line_cnt = line_cnt + 1
	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
	;******************************************
 
	;Print all prn total
	set patienthtml = build2(patienthtml
			,"<td class=patient-data>")
 
	if(size(data->list[x].prn2, 5) > 0)
		set y = 0
		for(y = 1 to size(data->list[x].prn2, 5))
			set line_cnt = line_cnt + 1
			if(line_cnt = 65)
 				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 				set line_cnt = 0
 			endif
			if(textlen(data->list[x].prn2[y].prn_disp) > 0)
				set patienthtml = build2(patienthtml
					,"<div>", data->list[x].prn2[y].prn_disp, "</div>")
			endif
		endfor
	else
		set patienthtml = build2(patienthtml, "<div>","There were no PRN doses given within 24 hours.", "</div>")
		set line_cnt = line_cnt + 1
		if(line_cnt = 65)
 			;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 			set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 			set line_cnt = 0
 		endif
	endif
 
	set patienthtml = build2(patienthtml, "</td>")
	;End print prn total
 
	;Print I&O Totals
	set patienthtml = build2(patienthtml
		,"<td class=patient-data>")
 
	set patienthtml = build2(patienthtml
		,"<div>","Total Intake: ", " ", data->list[x].i_tot_vol, " mL","</div>")
 
	set patienthtml = build2(patienthtml
		,"<div>","Total Output: ", " ", data->list[x].o_tot_vol, " mL","</div>")
	;End print I&O Totals
 
	;END TABLE DETAILS
	set patienthtml = build2(patienthtml,"</td></table></div>")
	set line_cnt = line_cnt + 2
	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
 
	;**********************START LAST TABLE HEADER
	set patienthtml = build2(patienthtml ,"<div>",'<table style="width:100% colspan=2">',"<tr>"
		,"<td class=patient-data-header>","Actions","</td>"
		,"<td class=patient-data-header>","Situational Awareness","</td>"
		,"</tr>")
	;******************************************
 	set line_cnt = line_cnt + 1
 	if(line_cnt = 65)
 		;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 		set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 		set line_cnt = 0
 	endif
 
	;Start Print actions
	set patienthtml = build2(patienthtml
		,"<td class=patient-data>")
 
	if(data->list[x].actions_cnt > 0)
		set y = 0
		for(y = 1 to data->list[x].actions_cnt)
			set line_cnt = line_cnt + 1
			if(line_cnt = 65)
 				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 				set line_cnt = 0
 			endif
			set patienthtml = build2(patienthtml
				,"<div>",data->list[x]->actions[y].action,"</div>")
		endfor
	else
		set patienthtml = build2(patienthtml, "<div>There are no Actions to report.</div>")
		set line_cnt = line_cnt + 1
		if(line_cnt = 65)
 			;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 			set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 			set line_cnt = 0
 		endif
	endif
 
	set patienthtml = build2(patienthtml, "</td>")
 	;End Print Actions
 
 	;Start Print situational awareness
 	set patienthtml = build2(patienthtml
		,"<td class=patient-data>")
 
	if(data->list[x].sit_aware_cnt > 0)
		set y = 0
		for(y = 1 to data->list[x].sit_aware_cnt)
			set line_cnt = line_cnt + 1
			if(line_cnt = 65)
 				;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 				set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 				set line_cnt = 0
 			endif
			set patienthtml = build2(patienthtml
					,"<div>",data->list[x]->sit_aware[y].comment,"</div>")
		endfor
	else
		set patienthtml = build2(patienthtml, "<div>There is no Situational Awareness to report.</div>")
		set line_cnt = line_cnt + 1
		if(line_cnt = 65)
 			;set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 			set patienthtml = build2(patienthtml, "<div><b>---PAGE BREAK---</b></div>")
 			set line_cnt = 0
 		endif
	endif
	;End Print situational awareness
 
	;END TABLE DETAILS
	set patienthtml = build2(patienthtml,"</td></table></div>")
 
	set patienthtml = build2(patienthtml, '<div><b><table style="width:100%"><tr>')
	set patienthtml = build2(patienthtml,"<p>","","</p>","<div class=comment-box>","</div>","<hr>","</hr>")
	set patienthtml = build2(patienthtml,"</tr></table></b></div>")
 
 	if(x < data->cnt) ;Page break after every patient without displaying a blank page at the end.
 		set patienthtml = build2(patienthtml, "<P style=page-break-after:always>")
 	endif
 
	set html_log->list[x].stop = textlen(trim(patienthtml,3)); + 1
 
	set patienthtml = build2(patienthtml, "<div>&nbsp</div>")
 
 	;TEXT ECLIPSIS*****************
  	set patienthtml = build2(patienthtml, "</span></div>")
  	;**********************************
endfor
 
set patienthtml = build2(patienthtml,"</span>")
 
;Add HTML and CSS shell around patienthtml
set finalhtml = build2(
	"<!doctype html><html><head>"
	,"<meta charset=utf-8><meta name=description><meta http-equiv=X-UA-Compatible content=IE=Edge>"
	,"<title>WARNING:  Information is Confidential</title>"
 
	,"<style type=text/css>"
 
 	,"@page {size: A4 landscape;}"
 
	,"body {font-family: arial;	font-size: 12px; counter-reset: my-sec-counter;}"
 
	,"td {vertical-align: top;}"
	,".print-header {display: flex;}"
	,".print-header div{display: flex; flex: 1 1;}"
	,".print-title {justify-content: center; font-style: bold; font-size: 24px;}"
	,".printed-date {justify-content: flex-end;}"
	,".printed-info (justify-content: flex-end; font-style: bold)"
 
	,".column {border-bottom: 3px solid #b2b9c0; font-weight: bold; width: 10%}"
	,".patient-info {font-weight: bold; width: 10%}"
 
	;;;;testing even row table shading start
	, "table.labs tr:nth-child(even) {background-color: #dddddd;}"
 
	;******************************
	,"table, figure {page-break-inside: always;}"
	,"tr::before {counter-increment: my-sec-counter;}"
 
	,".module {max-lines: [none | 15];}"
	,".module {line-clamp: [none | 15];}"
 
 	,".max-lines {display: block;text-overflow: ellipsis;word-wrap: break-word;overflow: hidden;max-height: 3.6em;line-height: 15.8em;}"
	,".text.ellipsis::after {content: '...';position: absolute;right: -12px; bottom: 4px;}"
	;********************************************max-height: 3.6em
 
	,".patient-data-header {width: 13%; text-decoration: underline; font-weight: bold}"
	,".patient-data {width: 19%}"
 
	,".summary-box {height: 50px}"
	,"</style> </head>"
 
	,"<div id = print-container> <div class=print-header>"
	,"<div class=print-title> <span> CHKD Provider Sign Out Tool </span> </div>"
 	,"</div></div>"
	,"<p class=print-title></p>"
 
	,"<div class=print-note align=right>"
;	,"<span> Date/Time printed: </span> <span>", format(cnvtdatetime(curdate,curtime),"mm/dd/yyyy;;d"),"</span>"
	,"<span> Printed By:  </span> <span>",printuser_name,"</span>"
	,"</div>"
 
;	,"<p class=print-warning></p>"
;	,"<div id = print-warning> <div class=printed-warning>"
;	,"<span> WARNING:  Information is Confidential  </span>"
;	,"</div>"
 
	,"<div id = print-container> <div class=print-note align=left> <div class=printed-info>"
	,"<span> NOTE: This report is a subset of clinical data.  Refer to patient chart for comprehensive and up to date information.  </span>"
 
	,"</div>"
	,"<div>&nbsp</div>"
	,"<p class=print-user></p>"
	,"</div>"
	,"</div>"
 
	,patienthtml
 
/* 	;*******************************************FOOTER********************************************************
 	;,"<style type=text/css>"
 	,"<footer>"
  	,"<div class=printuser-name align=left><span> Printed By:  </span> <span>",printuser_name, "</span></div>"
 	;,"@media screen {div.printuser-name {display: none;}}"
	;,"@media print {div.printuser-name {position: fixed;bottom: 0;}}"
	,"</footer>";</style>"
	;*********************************************************************************************************/
 
	,"</body></html>")
 
;Send HTML string back to PowerChart for printing
if(validate(_memory_reply_string) = 1)
	set _memory_reply_string = finalhtml
else
	free record putrequest
   	record putrequest (
      1 source_dir = vc
      1 source_filename = vc
      1 nbrlines = i4
      1 line [*]
        2 linedata = vc
      1 overflowpage [*]
        2 ofr_qual [*]
          3 ofr_line = vc
      1 isblob = c1
      1 document_size = i4
      1 document = gvc
	)
   	set putrequest->source_dir =  $OUTDEV
    set putrequest->isblob = "1"
   	set putrequest->document = finalhtml
   	set putrequest->document_size = size (putrequest->document)
   	execute eks_put_source with replace("REQUEST" ,putrequest), replace("REPLY" ,putreply)
endif
 
#exit_script
/*===============================================================================================================
 
                                          FREE RECORD STRUCTURES
 
===============================================================================================================*/
free set data
 
call echo(concat("END:      ", format(curtime3, "HH:MM:SS:CC;;M")))
 
end
go
 
 