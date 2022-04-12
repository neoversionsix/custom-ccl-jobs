/***********************************************************************************************************************************
Programmer Jason Whittle

Use: Pulls the diet MST score for a patient into a custom column                                                        
***********************************************************************************************************************************/
drop program wh_cust_mst:dba go
create program wh_cust_mst:dba

 
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
declare PUBLIC::DetermineEncntrsRecentOrders(null) = null with protect

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
  call DetermineEncntrsRecentOrders(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* DetermineEncntrsRecentOrders                                                                                                     *
************************************************************************************************************************************/

subroutine PUBLIC::DetermineEncntrsRecentOrders(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
      order_cnt = COUNT(C.order_id) OVER(PARTITION BY C.encntr_id)
    from
      CLINICAL_EVENT C
        where EXPAND(exp_idx, 1, PERSON_CNT, C.encntr_id, reply->person[exp_idx].encntr_id)
        and C.event_cd = 86163053 ; Filters for MST Score

    order by C.encntr_id, C.order_id
    head report
      person_idx = 0
      first_idx = 0
    head C.encntr_id
      order_idx = 0
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, C.encntr_id, reply->person[loc_idx].encntr_id)
      first_idx = person_idx
      reply->person[person_idx].count = CNVTINT(order_cnt) ; Get the order count from the OLAP expression.
      
      call ALTERLIST(reply->person[person_idx].contents, CNVTINT(order_cnt))
    head C.order_id
      order_idx = order_idx + 1
      ; DATA TO PULL [JW]
      ; [JW] PREVIOUS: TRIM(C.ordered_as_mnemonic)
      ; next line removes the datestamp from the order
      reply->person[person_idx].contents[order_idx].primary = trim(C.RESULT_VAL)
      ; Commenting out the date below as it's now already in C.order_detail_display_line [JW]
      ;reply->person[person_idx].contents[order_idx].secondary = FORMAT(C.orig_order_dt_tm, "@SHORTDATETIME")
    
    foot C.encntr_id
      person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, C.encntr_id, reply->person[loc_idx].encntr_id)
      ; Since the same visit could have multiple occurrences in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        reply->person[person_idx].count = CNVTINT(order_cnt)
        ; Copy the popup list from the first occurrence to each duplicate.
        stat = MOVERECLIST(reply->person[first_idx].contents, reply->person[person_idx].contents, 1, 0, CNVTINT(order_cnt), TRUE)
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, C.encntr_id, reply->person[loc_idx].encntr_id)
      endwhile
  with nocounter
end ; DetermineEncntrsRecentOrders
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
