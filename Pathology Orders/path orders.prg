select	; placed orders	
	UR_number = ea_URN.alias	
	, patient_name = p.name_full_formatted  ;"xxxx"	
	, patient_id = o.person_id	
	, encntr_dates = concat(format(e_orig.arrive_dt_tm, "dd/mm/yy hh:mm"), " - ", format(e_orig.depart_dt_tm, "dd/mm/yy hh:mm"))	
	, visit_no = ea_visit.alias	
	, o.encntr_id	
	, facility_at_time_of_order = uar_get_code_display(e_orig.loc_facility_cd)	
	, unit_at_time_of_order = if(elh.loc_nurse_unit_cd > 0) uar_get_code_display(elh.loc_nurse_unit_cd)	
	else uar_get_code_display(e_orig.loc_nurse_unit_cd)	
	endif
    , E_LOCATION_DISP = UAR_GET_CODE_DISPLAY(e_orig.LOCATION_CD)
	, E_LOC_BED_DISP = UAR_GET_CODE_DISPLAY(e_orig.LOC_BED_CD)
	, E_LOC_BUILDING_DISP = UAR_GET_CODE_DISPLAY(e_orig.LOC_BUILDING_CD)
	, E_LOC_FACILITY_DISP = UAR_GET_CODE_DISPLAY(e_orig.LOC_FACILITY_CD)
	, E_LOC_ROOM_DISP = UAR_GET_CODE_DISPLAY(e_orig.LOC_ROOM_CD)
	, E_LODGER_DISP = UAR_GET_CODE_DISPLAY(e_orig.LODGER_CD)
	, E_MED_SERVICE_DISP = UAR_GET_CODE_DISPLAY(e_orig.MED_SERVICE_CD)
;	, current_facility = if(e_curr.encntr_id > 0) uar_get_code_display(e_curr.loc_facility_cd)	
;	else "no current facility"	
;	endif	
;	, current_unit = if(e_curr.encntr_id > 0) uar_get_code_display(e_curr.loc_nurse_unit_cd)	
;	else "no current unit"	
;	endif	
	, order_type = evaluate (o.orig_ord_as_flag,	
	0, "Normal Order",	
	1, "Prescription/Discharge Order",	
	2, "Recorded / Home Meds",	
	3, "Patient Owns Meds",	
	4, "Pharmacy Charge Only",	
	5, "Satellite (Super Bill) Meds"	
	)	
;	, med_order_type = uar_get_code_display(o.med_order_type_cd)	
	, original_order_date = format(o.orig_order_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, order_placed_by = p_o_a_order.name_full_formatted	
	, order_projected_stop_date = format(o.projected_stop_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, current_order_status = uar_get_code_display(o.order_status_cd)	
	, order_status_last_update = format(o.status_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, order_status_last_updater = if(o.order_id > 0 and o.status_prsnl_id = 0) "0"	
	else p_o_stat.name_full_formatted	
	endif	
	, order_last_update = format(o.updt_dt_tm, "dd/mm/yyyy hh:mm:ss")	
	, order_last_updater = if(o.order_id > 0 and o.updt_id = 0) "0"	
	else p_o.name_full_formatted	
	endif	
	, specimen_type = o_d8.oe_field_display_value 	
	, o.clinical_display_line	
	, o.order_id	
	, o.ordered_as_mnemonic	
	, synonym_mnemonic = ocs.mnemonic	
	, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd)	
	, synonym_id = o.synonym_id	
	, order_rank = dense_rank() over (partition by 0	
	order by	
	o.orig_order_dt_tm	
	, o.status_dt_tm	
	, o.order_id	
	)	
		
from		
	orders o	
	, (left join prsnl p_o on p_o.person_id = o.updt_id)	
	, (left join prsnl p_o_stat on p_o_stat.person_id = o.status_prsnl_id)	
	, (left join order_detail o_d8 on o_d8.order_id = o.order_id	
	and o_d8.oe_field_id = 12584	; 'Specimen Type' oef field
	)	
	, (left join encounter e_orig on e_orig.encntr_id = o.encntr_id)	
	, (left join encntr_alias ea_URN on ea_URN.encntr_id = o.encntr_id	
	and ea_URN.encntr_alias_type_cd = 1079	; 'URN' from code set 319
	and ea_URN.active_ind = 1	; active URNs only
	and ea_URN.end_effective_dt_tm > sysdate	; effective URNs only
	)	
	, (left join encntr_alias ea_visit on ea_visit.encntr_id = o.encntr_id	
	and ea_visit.encntr_alias_type_cd = 1077	; 'FIN NBR' from code set 319
	and ea_visit.active_ind = 1	; active FIN NBRs only
	and ea_visit.end_effective_dt_tm > sysdate	; effective FIN NBRs only
	)	
	, (left join encntr_loc_hist elh on elh.encntr_id = o.encntr_id	
	and elh.active_ind = 1	; to remove inactive rows that seem to appear for unknown reason(s)
	and elh.pm_hist_tracking_id > 0	; to remove duplicate row that seems to occur at discharge
	and elh.beg_effective_dt_tm < o.orig_order_dt_tm	; encounter location began before order was placed
	and elh.end_effective_dt_tm >  o.orig_order_dt_tm	; encounter location ended after order was placed
	)	
	, (left join order_action o_a_order on o_a_order.order_id = o.order_id	
	 and o_a_order.action_type_cd = 2534	; 'order' from codeset 6003
	)	
	, (left join prsnl p_o_a_order on p_o_a_order.person_id = o_a_order.action_personnel_id)	
	, (left join person p on p.person_id = o.person_id)	
	, (left join order_catalog_synonym ocs on ocs.synonym_id = o.synonym_id)	
;	, (left join encounter e_curr on e_curr.person_id = o.person_id	
;	and e_curr.encntr_type_cd in (309308, 309310)	; 'Inpatient' and 'Emergency' from codeset 71
;	and e_curr.active_ind = 1	
;	and e_curr.arrive_dt_tm < sysdate	; patient arrived in the past
;	and e_curr.depart_dt_tm = null	; but has not yet departed
;	)	
		
plan	o	
    where	o.catalog_cd in (
    7346499
    , 7346541
    , 7346550
    , 7347813
    , 7347825
    , 7346645
    , 14811990
    , 7350256
    , 7350261
    , 7350272
    , 9679126
    , 9679377
    , 9678453
    , 7347465
    , 9679007
    , 9679019
    , 7350504
    , 7350541
    , 7350651
    , 7350646
    , 7347779
    , 7347805
    , 7350694
    , 7347851
    , 7347870
    , 7347914
    , 9680199
    , 18909914
    , 18909884
    , 18909910
    , 7350724
    , 7348069
    , 9680222
    , 7350771
    , 7350766
    , 7350825
    , 9679046
    , 7348274
    , 55537512
    , 55537301
    , 7348306
    , 9678535
    , 7348421
    , 9678868
    , 7350945
    , 33765781
    , 33765771
    , 9678603
    , 7348561
    , 33765773
    , 33765789
    , 33765801
    , 33765776
    , 7351529
    , 7348697
    , 7351122
    , 7348747
    , 7351139
    , 7348809
    , 7348880
    , 7348999
    , 7349119
    , 9679018
    , 15036028
    , 15036027
    , 7349201
    , 7349231
    , 7351307
    , 7349348
    , 33765786
    , 33765768
    , 9679025
    , 7349436
    , 7349471
    , 7349563
    , 7350024
    , 7349586
    , 80754133
    , 7337781
    , 7337948
    , 7337430
    , 7337459
    , 7337465
    , 7337482
    , 7337500
    , 7337519
    , 7337524
    , 7337555
    , 7338178
    , 7338356
    , 7338534
    , 7339898
    , 9678845
    , 7339347
    , 7339365
    , 7339414
    , 7339419
    , 7339424
    , 7339429
    , 7339475
    , 7339479
    , 7339589
    , 7339742
    , 7339839
    , 7339864
    , 7339885
    , 144898220
    , 144926221
    , 7339930
    , 7339955
    , 7339959
    , 7339978
    , 7340061
    , 7340188
    , 7340232
    , 7337136
    , 9678926
    , 7337836
    , 9678757
    , 7337185
    , 7337573
    , 7337581
    , 7337586
    , 7337600
    , 7337612
    , 7337616
    , 7337426
    , 7337646
    , 7337650
    , 7337654
    , 7337663
    , 7337668
    , 7337673
    , 7337677
    , 9679369
    , 7337696
    , 7337720
    , 7337728
    , 144926190
    , 7337775
    , 7337796
    , 7337816
    , 7337845
    , 7337868
    , 7337885
    , 7337890
    , 7337894
    , 7337899
    , 7337903
    , 7337907
    , 7337915
    , 7337919
    , 9678488
    , 7337995
    , 7338003
    , 143613511
    , 144926052
    , 143613404
    , 9678948
    , 7341971
    , 7342572
    , 134426544
    , 9679408
    , 133773851
    , 7343052
    , 7343381
    , 9680034
    , 7341789
    , 7341818
    , 7341943
    , 7341946
    , 9679461
    , 7342033
    , 7342439
    , 7342533
    , 7342569
    , 7342566
    , 7342947
    , 7342954
    , 7343056
    , 7343313
    , 7343317
    , 7342238
    , 7344039
    , 139173709
    , 7341892
    , 7346560
    , 18141482
    , 9679320
    , 7336991
    , 7336983
    , 7346665
    , 7339543
    , 7339585
    , 7339816
    , 80799897
    , 7337222
    , 7341877
    , 7342116
    , 7339409
    , 7343492
    , 7350656
    , 7348717
    , 7342396
    , 7342405
    , 15036055
    , 15036039
    , 7346657
    , 7348131
    , 7342585
    , 9678921
    , 7342851
    , 7342847
    , 7342763
    , 7342751
    , 7337110
    , 9678546
    , 7348586
    , 9678989
    , 7339889
    , 7348622
    , 7351098
    , 7340065
    , 9679384
    , 7341144
    , 7343904
    )
    and	o.orig_order_dt_tm between
    CNVTDATETIME("01-JAN-2022 00:00:00.00")
    AND
    CNVTDATETIME("01-JUL-2022 00:00:00.00")
;and	o.order_status_cd in (	
;	2546	; Future
;	, 2547	; Incomplete
;	, 2548	; InProcess
;	, 2549	; On Hold, Med Student
;	, 2550	; Ordered
;	, 2551	; Pending Review
;	, 2552	; Suspended
;	, 2553	; Unscheduled
;	, 614538	; Transfer/Canceled
;	, 643466	; Pending Complete
;	)	
;and	o.orig_ord_as_flag = 0	; inpatient orders only
;and	o.orig_ord_as_flag = 1	; discharge prescriptions only
;and	o.orig_ord_as_flag = 2	; Recorded / Home Meds only
;and	o.active_ind = 1	; active orders only
;and	(	
;	o.projected_stop_dt_tm > sysdate	; current orders only (future stop date or no stop date)
;	or	
;	o.projected_stop_dt_tm = null	
;	)	
;and	o.catalog_cd in ()	
;and	o.synonym_id  in ()	
join	p_o	
join	p_o_stat	
join	o_d8	
join	e_orig	
join	ea_URN	
join	ea_visit	
join	elh	
join	o_a_order	
;where	o_a_order.updt_id = 1235678	; orders placed by …
;and	o_a_order.updt_dt_tm between cnvtdatetime("01-DEC-2016") and cnvtdatetime("01-DEC-2020")	; between dates
join	p_o_a_order	
join	p	
join	ocs	
;join	e_curr	
		
order by		
	o.orig_order_dt_tm	
	, o.status_dt_tm	
	, o.order_id	
	, ea_URN.alias	
		
with	time = 1200 
;   ,MAXREC = 10