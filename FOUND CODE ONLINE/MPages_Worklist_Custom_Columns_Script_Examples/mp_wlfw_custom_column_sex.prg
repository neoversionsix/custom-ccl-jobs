/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 08/02/2016 BP025585  1-11053620131 Initial release                                                                           *
***********************************************************************************************************************************/
drop program mp_wlfw_custom_column_sex:dba go
create program mp_wlfw_custom_column_sex:dba
/**
Determine the sex of each received person.
*/
 
/***********************************************************************************************************************************
* DECLARATIONS *********************************************************************************************************************
***********************************************************************************************************************************/

/***********************************************************************************************************************************
* Record Structures                                                                                                                *
***********************************************************************************************************************************/
/* The reply record must be declared by the consuming script, with the appropriate person details already available.

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
declare PUBLIC::DeterminePersonsSex(null) = null with protect

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
  call DeterminePersonsSex(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* DeterminePersonsSex                                                                                                              *
***********************************************************************************************************************************/
/**
Determine the sex of each person. Add the resulting string to the person's content list. No secondary data is included.
@param null
@returns null
*/
subroutine PUBLIC::DeterminePersonsSex(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
    from person p
      where EXPAND(exp_idx, 1, PERSON_CNT, p.person_id, reply->person[exp_idx].person_id)
        and p.sex_cd > 0.0
    order by p.person_id
    head report
      person_idx = 0
    head p.person_id
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, p.person_id, reply->person[loc_idx].person_id)

      ; Since the same person could have multiple visits in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        ; Add the result string to the contents list for the current person.
        call ALTERLIST(reply->person[person_idx].contents, 1)
        reply->person[person_idx].contents[1].primary = EVALUATE(p.sex_cd, 0.0, "", UAR_GET_CODE_DISPLAY(p.sex_cd))      
          
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, p.person_id, reply->person[loc_idx].person_id)
      endwhile
  with nocounter
end ; DeterminePersonsSex
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 
