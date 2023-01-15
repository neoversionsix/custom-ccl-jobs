/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 08/02/2016 BP025585  1-11053620131 Initial release                                                                           *
***********************************************************************************************************************************/
drop program mp_wlfw_custom_column_next_kin:dba go
create program mp_wlfw_custom_column_next_kin:dba
/**
Determine the documented NOK of the received persons.
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
declare PUBLIC::DetermineEncountersNextOfKin(null) = null with protect

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
  call DetermineEncountersNextOfKin(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* DetermineEncountersNextOfKin                                                                                                     *
***********************************************************************************************************************************/
/**
Determine the next of kin documented for each visit.
@param null
@returns null
*/
subroutine PUBLIC::DetermineEncountersNextOfKin(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare PERSON_RELTN_NOK_TYPE_CD = f8 with protect, constant(UAR_GET_CODE_BY("MEANING", 351, "NOK"))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
      kin_cnt = COUNT(p.person_id) OVER(PARTITION BY epr.encntr_id) ; OLAP to get NOK count per visit.
    from encntr_person_reltn epr, person p
    plan epr
      where EXPAND(exp_idx, 1, PERSON_CNT, epr.encntr_id, reply->person[exp_idx].encntr_id)
        and epr.person_reltn_type_cd = PERSON_RELTN_NOK_TYPE_CD
        and epr.related_person_id > 0.0
        and epr.beg_effective_dt_tm < CNVTDATETIME(curdate, curtime3)
        and epr.end_effective_dt_tm >= CNVTDATETIME(curdate, curtime3)
        and epr.active_ind = 1
    join p
      where p.person_id = epr.related_person_id
    order by epr.encntr_id
    head report
      person_idx = 0
      first_idx = 0
    head epr.encntr_id
      ; Find the current person in the reply's person list.
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, epr.encntr_id, reply->person[loc_idx].encntr_id)
      first_idx = person_idx
      
      ; Set up the contents list to hold each retrieved NOK.
      call ALTERLIST(reply->person[person_idx].contents, CNVTINT(kin_cnt))

      kin_idx = 0
    detail
      kin_idx = kin_idx + 1

      ; Add the next of kin name to the contents list for the current person.
      reply->person[person_idx].contents[kin_idx].primary = p.name_full_formatted
    foot epr.encntr_id
      person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, epr.encntr_id, reply->person[loc_idx].encntr_id)
      
      ; Since the same visit could have multiple occurrences in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        ; Copy the popup list from the first occurrence to each duplicate.
        stat = MOVERECLIST(reply->person[first_idx].contents, reply->person[person_idx].contents, 1, 0, CNVTINT(kin_cnt), TRUE)
        
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, epr.encntr_id, reply->person[loc_idx].encntr_id)
      endwhile
  with nocounter
end ; DetermineEncountersNextOfKin
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 
