/***********************************************************************************************************************************
Programmer: Jason Whittle
Customer: Ally.Q
***********************************************************************************************************************************/
drop program wh_cust_mst:dba go
create program wh_cust_mst:dba
/**
Retrieve the last MST for a patient
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
declare PUBLIC::GetMST(null) = null with protect

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
  call GetMST(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* GetMST                                                                                                         *
***********************************************************************************************************************************/
/**
@param null
@returns null
*/
subroutine PUBLIC::GetMST(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare msts_str = vc with protect, noconstant("")
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
    mst_pt = TRIM(ce.result_val, 3)
    ,
    mst_dt_tm = TRIM(format(ce.performed_dt_tm,"dd/mm/yyyy"), 3)
    from 
        clinical_event ce
            where
                EXPAND(exp_idx, 1, PERSON_CNT, ce.person_id, reply->person[exp_idx].person_id)
                AND ce.updt_dt_tm > CNVTLOOKBEHIND("6, M")
                AND ce.event_cd = 86163053 ; Filters for MST Score
	              AND ce.valid_until_dt_tm > SYSDATE ; not invalid time
	              AND ce.publish_flag = 1 ; publish
                AND ce.view_level = 1; viewable
    
    ; join x
    ;   where x._id = OUTERJOIN(x._id)
    ;     and x.active_ind = OUTERJOIN(1)
    order by ce.person_id, ce.updt_dt_tm desc ; desc=most recent weight in #1 position
    head report
      person_idx = 0
    head ce.person_id
      msts_str = FILLSTRING(120, " ")
      weight_cnt = 0
    detail
      weight_cnt = weight_cnt + 1
      if (weight_cnt = 1) ; only concatenate msts_str for the last recorded weight
        msts_str = BUILD2(mst_pt)
    ;   else
    ;     msts_str = BUILD2("none")
      endif
      
    foot ce.person_id
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, ce.person_id, reply->person[loc_idx].person_id)

      ; Since the same person could have multiple visits in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        call ALTERLIST(reply->person[person_idx].contents, 1)
        reply->person[person_idx].contents[1].primary = msts_str
        
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, ce.person_id, reply->person[loc_idx].person_id)
      endwhile
  with nocounter
end ; GetMST
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 