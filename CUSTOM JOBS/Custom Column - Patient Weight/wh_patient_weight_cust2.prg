drop program wh_patient_weight_cust:dba go
create program wh_patient_weight_cust:dba
/**
NOTES
*/

/***********************************************************************************************************************************
* DECLARATIONS *********************************************************************************************************************
***********************************************************************************************************************************/

/***********************************************************************************************************************************
* Record Structures                                                                                                                *
***********************************************************************************************************************************/
/* The reply record must be declared by the consuming script, with the appropriate person details available.

reply (
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
declare PUBLIC::GetWeight(null) = null with protect

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
  call GetWeight(null)
  set reply->status_data.status = "S"
end ; Main

/***********************************************************************************************************************************
* GetWeight                                                                                                     *
***********************************************************************************************************************************/
/**
Determine the count of orders placed in the last 48 hours. Add the orders' names and dates to the content list, but leave the actual
count to the Worklist to determine.
@param null
@returns null
*/
subroutine PUBLIC::GetWeight(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
      order_cnt = COUNT(ce.clinical_event_id) OVER(PARTITION BY ce.encntr_id)
    from
      clinical_event ce
        ; FILTERS [jw]
        where EXPAND(exp_idx, 1, PERSON_CNT, ce.encntr_id, reply->person[exp_idx].encntr_id)
        ;Timeline to filter on;  ("48, H") this was the old format [jw]
        ;AND ce.PERFORMED_DT_TM > CNVTLOOKBEHIND("6, M")
        AND c.event_cd = 7334438 ; Filters Weight Measured
	    AND c.valid_until_dt_tm > SYSDATE ; not invalid time
	    AND c.publish_flag = 1 ; publish
        AND c.view_level = 1; viewable

    order by ce.encntr_id, ce.clinical_event_id
    head report
      person_idx = 0
      first_idx = 0
    head ce.encntr_id
      order_idx = 0
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, ce.encntr_id, reply->person[loc_idx].encntr_id)
      first_idx = person_idx

      reply->person[person_idx].count = CNVTINT(order_cnt) ; Get the order count from the OLAP expression.

      call ALTERLIST(reply->person[person_idx].contents, CNVTINT(order_cnt))
    head ce.clinical_event_id
      order_idx = order_idx + 1
      ; DATA TO PULL [JW]
      ; [JW] PREVIOUS: TRIM(ce.ordered_as_mnemonic)
      ; ce.order_detail_display_line - This is the diet orders with the datetime stamp
      reply->person[person_idx].contents[order_idx].primary = TRIM(ce.result_val)
      ; Commenting out the date below as it's now already in ce.order_detail_display_line [JW]
      reply->person[person_idx].contents[order_idx].secondary = FORMAT(ce.PERFORMED_DT_TM, "@SHORTDATETIME")

    foot ce.encntr_id
      person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, ce.encntr_id, reply->person[loc_idx].encntr_id)

      ; Since the same visit could have multiple occurrences in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        reply->person[person_idx].count = CNVTINT(order_cnt)

        ; Copy the popup list from the first occurrence to each duplicate.
        stat = MOVERECLIST(reply->person[first_idx].contents, reply->person[person_idx].contents, 1, 0, CNVTINT(order_cnt), TRUE)

        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, ce.encntr_id, reply->person[loc_idx].encntr_id)
      endwhile
  with nocounter
end ; GetWeight

/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT

if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif

end
go
