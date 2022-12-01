/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 08/02/2016 BP025585  1-11053620131 Initial release                                                                           *
***********************************************************************************************************************************/
drop program mp_wlfw_custom_column_problems:dba go
create program mp_wlfw_custom_column_problems:dba
/**
Retrieve a list of active problems documented for the person.
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
declare PUBLIC::DeterminePersonsProblems(null) = null with protect

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
  call DeterminePersonsProblems(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* DeterminePersonsProblems                                                                                                         *
***********************************************************************************************************************************/
/**
Determine the currently active problems for each person. A comma-separated list of the problem names will be built out for each 
person, and the resulting string is added to the person's content list. No secondary data is included.
@param null
@returns null
*/
subroutine PUBLIC::DeterminePersonsProblems(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare LIFE_CYCLE_STATUS_ACTIVE_CD = f8 with protect,constant(UAR_GET_CODE_BY("MEANING", 12030, "ACTIVE"))
  declare problem_str = vc with protect, noconstant("")
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
      name = 
        if (SIZE(TRIM(p.problem_ftdesc, 3)) > 0)
          TRIM(p.problem_ftdesc, 3)
        elseif (SIZE(TRIM(p.annotated_display,3)) > 0)
          TRIM(p.annotated_display, 3)
        else
          TRIM(n.source_string, 3)
        endif
    from 
      problem p,
      nomenclature n
    plan p
      where EXPAND(exp_idx, 1, PERSON_CNT, p.person_id, reply->person[exp_idx].person_id)
        and p.problem_id > 0.0
        and p.life_cycle_status_cd = LIFE_CYCLE_STATUS_ACTIVE_CD
        and p.active_ind = 1
    join n
      where n.nomenclature_id = OUTERJOIN(p.nomenclature_id)
        and n.active_ind = OUTERJOIN(1)
    order by p.person_id
    head report
      person_idx = 0
    head p.person_id
      problem_str = FILLSTRING(120, " ")
      problem_cnt = 0
    detail
      problem_cnt = problem_cnt + 1
      
      if (problem_cnt > 1)
        problem_str = BUILD2(problem_str, ", ", name)
      else
        problem_str = name
      endif
      
    foot p.person_id
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, p.person_id, reply->person[loc_idx].person_id)

      ; Since the same person could have multiple visits in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        call ALTERLIST(reply->person[person_idx].contents, 1)
        reply->person[person_idx].contents[1].primary = problem_str
        
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, p.person_id, reply->person[loc_idx].person_id)
      endwhile
  with nocounter
end ; DeterminePersonsProblems
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 
