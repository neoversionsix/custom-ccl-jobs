/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 08/02/2016 BP025585  1-11053620131 Initial release
JW 9 FEB 2021 Working for Diet orders for now                                                                           *
***********************************************************************************************************************************/
drop program mp_wlfw_custom_column_orders:dba go
create program mp_wlfw_custom_column_orders:dba
/**
Determine the orders placed in the last 48 hours.
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
***********************************************************************************************************************************/
/**
Determine the count of orders placed in the last 48 hours. Add the orders' names and dates to the content list, but leave the actual
count to the Worklist to determine.
@param null
@returns null
*/
subroutine PUBLIC::DetermineEncntrsRecentOrders(null)
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)

  select
    into "nl:"
      order_cnt = COUNT(o.order_id) OVER(PARTITION BY o.encntr_id)
    from 
      orders o
      , clinical_event ce

    PLAN
        o
            ; FILTERS [jw]
            where EXPAND(exp_idx, 1, PERSON_CNT, o.encntr_id, reply->person[exp_idx].encntr_id)
            ;Timeline to filter on;  ("48, H") this was the old format [jw]
            ;and o.orig_order_dt_tm > CNVTLOOKBEHIND("48, D")
            and o.catalog_cd = 105460833 ; Filters for Diet orders [jw]

    JOIN
        ce
            WHERE
                o.person_id = ce.person_id
                and
                ce.event_cd = 86163053

    order by o.encntr_id, o.order_id


    head report
      person_idx = 0
      first_idx = 0
    head o.encntr_id
      order_idx = 0
      person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, o.encntr_id, reply->person[loc_idx].encntr_id)
      first_idx = person_idx
      
      reply->person[person_idx].count = CNVTINT(order_cnt) ; Get the order count from the OLAP expression.
      
      call ALTERLIST(reply->person[person_idx].contents, CNVTINT(order_cnt))

    head o.order_id
        ; commenting out counter below because it appears above
      ;order_idx = order_idx + 1
      ; DATA TO PULL [JW]
      ; [JW] PREVIOUS: TRIM(o.ordered_as_mnemonic)
      reply->person[person_idx].contents[order_idx].primary = TRIM(o.order_detail_display_line)
      ; Commenting out the date below as it's now already in o.order_detail_display_line [JW]
      reply->person[person_idx].contents[order_idx].secondary = CE.RESULT_VAL
    
    
    foot o.encntr_id
      person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, o.encntr_id, reply->person[loc_idx].encntr_id)
      
      ; Since the same visit could have multiple occurrences in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        reply->person[person_idx].count = CNVTINT(order_cnt)
        
        ; Copy the popup list from the first occurrence to each duplicate.
        stat = MOVERECLIST(reply->person[first_idx].contents, reply->person[person_idx].contents, 1, 0, CNVTINT(order_cnt), TRUE)
        
        person_idx = LOCATEVAL(loc_idx, person_idx + 1, PERSON_CNT, o.encntr_id, reply->person[loc_idx].encntr_id)
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
