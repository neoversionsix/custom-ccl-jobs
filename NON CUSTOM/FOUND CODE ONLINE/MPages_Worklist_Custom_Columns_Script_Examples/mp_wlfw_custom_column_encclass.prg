/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 08/02/2016 BP025585  1-11053620131 Initial release                                                                           *
***********************************************************************************************************************************/
drop program mp_wlfw_custom_column_encclass:dba go
create program mp_wlfw_custom_column_encclass:dba
/**
Determine the encounter class of each visit, and return a corresponding icon.
*/
 
/***********************************************************************************************************************************
* DECLARATIONS *********************************************************************************************************************
***********************************************************************************************************************************/

/***********************************************************************************************************************************
* Record Structures                                                                                                                *
***********************************************************************************************************************************/
/* The reply record must be declared by the consuming script, with the appropriate person details available.

record reply (
  1 person[*]
    2 person_id = f8
    2 encntr_id = f8
    2 ppr_cd = f8
    2 count = i4
    2 icon = vc
    2 contents[*]
      3 primary = vc
      3 secondary = vc
%i cclsource:status_block.inc
) with protect
 
*/
 
/***********************************************************************************************************************************
* Subroutines                                                                                                                      *
***********************************************************************************************************************************/
declare PUBLIC::Main(null) = null with private
declare PUBLIC::DetermineEncountersClass(null) = null with protect

/***********************************************************************************************************************************
* Main PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
call Main(null)
 
/***********************************************************************************************************************************
* SUBROUTINES **********************************************************************************************************************
***********************************************************************************************************************************/
 
/***********************************************************************************************************************************
* Main                                                                                                                             *
***********************************************************************************************************************************/
/**
Main subroutine.
@param null
@returns null
*/
subroutine PUBLIC::Main(null)
  call DetermineEncountersClass(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* DetermineEncountersClass                                                                                                         *
***********************************************************************************************************************************/
/**
Determine the encounter class of each encounter, and supply a relevant icon for the class. Return the class's display value in the 
popup.
@param null
@returns null
*/
subroutine PUBLIC::DetermineEncountersClass(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)
  declare ENCNTR_CLASS_EMERGENCY_CD = f8 with protect, constant(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!1005613"))
  declare ENCNTR_CLASS_INPATIENT_CD = f8 with protect, constant(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!1005614"))
  declare ENCNTR_CLASS_OUTPATIENT_CD = f8 with protect, constant(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!1005615"))
  declare ENCNTR_CLASS_PREADMIT_CD = f8 with protect, constant(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!1005616"))
  declare EMERGENCY_ICON_PATH = vc with protect, constant("images/i4_20_green.png")
  declare INPATIENT_ICON_PATH = vc with protect, constant("images/4013_16.png")
  declare OUTPATIENT_ICON_PATH = vc with protect, constant("images/Plus16_blue.gif")
  declare PREADMIT_ICON_PATH = vc with protect, constant("images/6627_16.png")

  select
    into "nl:"
    from encounter e
      where EXPAND(exp_idx, 1, PERSON_CNT, e.encntr_id, reply->person[exp_idx].encntr_id)
        and e.encntr_class_cd > 0.0
    order by e.encntr_id
    head report
      person_idx = 0
      first_idx = 0
    head e.encntr_id
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, e.encntr_id, reply->person[loc_idx].encntr_id)
      first_idx = person_idx
      
      ; Determine the appropriate icon.
      case (e.encntr_class_cd)
        of (ENCNTR_CLASS_EMERGENCY_CD):
          reply->person[person_idx].icon = EMERGENCY_ICON_PATH
        of (ENCNTR_CLASS_INPATIENT_CD):
          reply->person[person_idx].icon = INPATIENT_ICON_PATH
        of (ENCNTR_CLASS_OUTPATIENT_CD):
          reply->person[person_idx].icon = OUTPATIENT_ICON_PATH
        of (ENCNTR_CLASS_PREADMIT_CD):
          reply->person[person_idx].icon = PREADMIT_ICON_PATH
      endcase
      
      ; Add the class display value to the popup.
      call ALTERLIST(reply->person[person_idx].contents, 1)
      reply->person[person_idx].contents[1].primary = TRIM(UAR_GET_CODE_DISPLAY(e.encntr_class_cd))
      
      ; Since the same visit could have multiple occurrences in the Worklist, loop through the visit list to look for duplicates.
      person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, e.encntr_id, reply->person[loc_idx].encntr_id)
      
      while (person_idx > 0)
        ; Copy the icon from the first occurrence to each duplicate.
        reply->person[person_idx].icon = reply->person[first_idx].icon
        
        ; Copy the popup list from the first occurrence to each duplicate.
        stat = MOVERECLIST(reply->person[first_idx].contents, reply->person[person_idx].contents, 1, 0, 1, TRUE)
      
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, e.encntr_id, reply->person[loc_idx].encntr_id)
      endwhile
  with nocounter
end ; DetermineEncountersClass
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 
