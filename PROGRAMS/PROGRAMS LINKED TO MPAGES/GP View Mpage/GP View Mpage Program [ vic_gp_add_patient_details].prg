/*****************************************************************************

        Source file name:       vic_gp_add_patient_details.prg
        object name:            vic_gp_add_patient_details

        Program purpose:		To display some patient details in a Genview call by tab GP View in Powerchart


        Executing from:         Powerchart

        Special Notes:

******************************************************************************/


;~DB~*******************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG                     *
;    *******************************************************************************
;    *                                                                             *
;    *Mod Date          Engineer             Comment                                    *
;    *--- -------- -------------------- ------------------------------------------ *
;     *									                      *
;	*000 29-Jul-2103 Leigh WY			ER382396 - Initial Development
;     *										Minor tweak during UAT - put address line 2 on own line
;~DE~*******************************************************************************

drop program vic_gp_add_patient_details:dba go
create program vic_gp_add_patient_details:dba


; Include standard rtf includes
%i cclsource:ma_rtf_tags.inc
%i cclsource:vic_ds_common_fonts.inc

 record encntr (
  1 pt_person_id = f8
  1 pt_name = vc
  1 pt_dob = vc
  1 pt_addr_1 = vc
  1 pt_addr_2 = vc
  1 pt_addr_3 = vc
  1 pt_URN = vc
  )


declare EA_MRN_CD = f8 with Constant(uar_get_code_by("MEANING",319,"MRN")),protect
declare addr_cd = f8 with protect, constant(uar_get_code_by("MEANING",212,"HOME"))


;002 patient demographics

select into "nl:"

	pat_addr2_ind = nullind(a.street_addr2)

from
	encounter e
	,person p
		,(left join address a on a.parent_entity_id = p.person_id
	  				and a.active_ind = 1
	  				and a.address_type_cd = ADDR_CD
	  				and cnvtdatetime(curdate,curtime3) between a.beg_effective_dt_tm and a.end_effective_dt_tm )
 	,encntr_alias ea


plan e where e.encntr_id = request->visit[1].encntr_id

join p where  p.person_id = e.person_id
           and p.active_ind = 1
           and cnvtdatetime(curdate,curtime3) between p.beg_effective_dt_tm and p.end_effective_dt_tm

join ea where ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = EA_MRN_CD
		and ea.active_ind = 1
		and cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm

join a


head report

	encntr->pt_person_id = p.person_id
	encntr->pt_name = p.name_full_formatted
	encntr->pt_dob = format(p.birth_dt_tm, "dd/mm/yyyy;;d")
	encntr->pt_URN = trim(cnvtalias(ea.alias,ea.alias_pool_cd))

	state = uar_get_code_display(a.state_cd)

 	encntr->pt_addr_1 = a.street_addr

 	If(a.street_addr2 != " ")
 		encntr->pt_addr_2 = a.street_addr2
 		encntr->pt_addr_3 = concat(trim(a.city),", ",trim(state)," ",trim(a.zipcode) )
 	  else
 		encntr->pt_addr_2 = concat(trim(a.city),", ",trim(state)," ",trim(a.zipcode) )
 	endif



with nocounter

call echorecord(encntr)
;call echoxml(encntr,"ccluserdir:pt_view_test.xml")
;-----------------------------------------------------------------------------------------------------
; Create RTF Output.

call ApplyFont(active_fonts->header_patient_name)

 	call NextLine(1)
 	call PrintText(encntr->pt_name,1,0,0)
 	call NextLine(1)

 call ApplyFont(active_fonts->normal)


 	call PrintText(encntr->pt_dob,0,0,0)
 	call NextLine(1)
 	call PrintText(encntr->pt_addr_1,0,0,0)
 	call NextLine(1)
	call PrintText(encntr->pt_addr_2,0,0,0)
 	call NextLine(1)
 	call PrintText(encntr->pt_addr_3,0,0,0)
 	call NextLine(1)
 	call PrintLabeledDataFixed("URN: ",encntr->pt_URN,30)


call FinishText(0)
call echo(rtf_out->text)

set reply->text = rtf_out->text

end
go
