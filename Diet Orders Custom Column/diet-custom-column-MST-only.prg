/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 08/02/2016 BP025585  1-11053620131 Initial release                                                                           *
***********************************************************************************************************************************/
drop program wh_cust_mst:dba go
create program wh_cust_mst:dba
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
declare PUBLIC::GetMst(null) = null with protect

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
  call GetMst(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* GetMst                                                                                                              *
***********************************************************************************************************************************/
/**
Determine the sex of each person. Add the resulting string to the person's content list. No secondary data is included.
@param null
@returns null
*/
subroutine PUBLIC::GetMst(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
    from clinical_event   c
      where EXPAND(exp_idx, 1, PERSON_CNT, c.person_id, reply->person[exp_idx].person_id)
        ;and c.sex_cd > 0
        AND c.event_cd = 86163053 ; Filters for MST Score
	      AND c.valid_until_dt_tm > SYSDATE ; not invalid time
	      AND c.publish_flag = 1 ; publish
        AND c.view_level = 1; viewable
    order by c.person_id, c.updt_dt_tm asc ;c.person_id
    head report
      person_idx = 0
    head c.person_id
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, c.person_id, reply->person[loc_idx].person_id)

      ; Since the same person could have multiple visits in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        ; Add the result string to the contents list for the current person.
        call ALTERLIST(reply->person[person_idx].contents, 1)
        reply->person[person_idx].contents[1].primary = c.result_val      
          
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, c.person_id, reply->person[loc_idx].person_id)
      endwhile
  with nocounter
end ; GetMst
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 
