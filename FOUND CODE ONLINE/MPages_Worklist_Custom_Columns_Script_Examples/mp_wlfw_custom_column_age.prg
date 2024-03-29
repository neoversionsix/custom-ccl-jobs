/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 08/02/2016 BP025585  1-11053620131 Initial release                                                                           *
***********************************************************************************************************************************/
drop program mp_wlfw_custom_column_age:dba go
create program mp_wlfw_custom_column_age:dba
/**
Determine the age of each person.
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
declare PUBLIC::DeterminePersonsAge(null) = null with protect

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
  call DeterminePersonsAge(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* DeterminePersonsAge                                                                                                              *
***********************************************************************************************************************************/
/**
Determine the age and DOB for each person.
@param null
@returns null
*/
subroutine PUBLIC::DeterminePersonsAge(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare NOW_DTTM = dq8 with protect, constant(CNVTDATETIME(curdate, curtime3))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
    from person p
      where EXPAND(exp_idx, 1, PERSON_CNT, p.person_id, reply->person[exp_idx].person_id)
        and p.birth_dt_tm > CNVTDATETIME("01-JAN-1800")
    order by p.person_id
    head report
      person_idx = 0
      age_in_years = 0
    head p.person_id
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, p.person_id, reply->person[loc_idx].person_id)
      
      age_in_years = YEAR(NOW_DTTM) - YEAR(p.birth_dt_tm)
      if (MONTH(NOW_DTTM) < MONTH(p.birth_dt_tm)
      or (MONTH(NOW_DTTM) = MONTH(p.birth_dt_tm) and DAY(NOW_DTTM) < DAY(p.birth_dt_tm)))
        age_in_years = age_in_years - 1
      endif
      
      ; Since the same person could have multiple visits in the Worklist, loop through the person list to look for duplicates.
      while (person_idx > 0)
        ; Add the age to the count and brith date to the contents list.
        call ALTERLIST(reply->person[person_idx].contents, 1)
        reply->person[person_idx].count = age_in_years
        reply->person[person_idx].contents[1].primary = FORMAT(p.birth_dt_tm, "@LONGDATE")
        
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, p.person_id, reply->person[loc_idx].person_id)
      endwhile
  with nocounter
end ; DeterminePersonsAge
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 
