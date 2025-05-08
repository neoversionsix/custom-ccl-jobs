-- ==============================================================================================================================================
	-- Populate Tracking_GROUP
	-- ==============================================================================================================================================
	IF OBJECT_ID('tempdb..#tmp_RAW_TG') IS NOT NULL DROP TABLE #tmp_RAW_TG;
		SELECT	DISTINCT 
				CODE_VALUE		AS TRACKING_GROUP_CD
				, DISPLAY		AS TrackingGroup
				, DISPLAY_KEY	AS TrackingGroupKey
		INTO	#tmp_RAW_TG
		FROM	CERNER.dbo.CODE_VALUE AS cv WITH(NOLOCK) 
		WHERE	cv.CODE_SET = 16370  --Tracking Group
				AND ACTIVE_IND = 1
				AND CDF_MEANING = 'ER'
				AND DISPLAY_KEY LIKE 'ED%'
		; 
		-- SELECT * FROM #tmp_RAW_TG

	-- ==============================================================================================================================================
	-- Populate Tracking_CHECKIN table
	-- ==============================================================================================================================================
	IF OBJECT_ID('tempdb..#tmp_RAW_TI') IS NOT NULL DROP TABLE #tmp_RAW_TI;
		SELECT	ti.ENCNTR_ID
				, tc.TRACKING_GROUP_CD
				, tg.TrackingGroup
				, ti.CUR_TRACKING_LOCATOR_ID
				, ti.TRACKING_ID
				, tc_CHECKIN_DT_TM.MelbDateTime		AS CHECKIN_DT_TM
				, tc_CHECKOUT_DT_TM.MelbDateTime	AS CHECKOUT_DT_TM
		
		INTO	#tmp_RAW_TI

		FROM	CERNER.dbo.TRACKING_CHECKIN AS tc WITH(NOLOCK) 
				INNER JOIN #tmp_RAW_TG AS tg ON tc.TRACKING_GROUP_CD = tg.TRACKING_GROUP_CD
				INNER JOIN CERNER.dbo.TRACKING_ITEM AS ti WITH(NOLOCK) ON tc.TRACKING_ID = ti.TRACKING_ID AND ti.Active_ind = 1
				OUTER APPLY PreMaP.dbo.udf_UTCDateConverter(tc.CHECKIN_DT_TM) AS tc_CHECKIN_DT_TM --LOCAL FUNCTION TO CONVERT UTC TO LOCAL TIME
				OUTER APPLY PreMaP.dbo.udf_UTCDateConverter(tc.CHECKOUT_DT_TM) AS tc_CHECKOUT_DT_TM --LOCAL FUNCTION TO CONVERT UTC TO LOCAL TIME

		WHERE	tc.ACTIVE_IND = 1
				AND tc.PARENT_ENTITY_ID = 0  --Not related to PreArrival
				AND tc.CHECKIN_ID <> 1		 --exclude checked in by system
				AND tc_CHECKIN_DT_TM.MelbCalendarID BETWEEN @StartCalendarID AND @EndCalendarID
				AND (
						(tg.TrackingGroupKey = 'EDWILLIAMSTOWNTRACKINGGROUP' /*ED Williamstown Tracking Group*/ AND tc_CHECKIN_DT_TM.MelbCalendarID >= 20230709 ) 
						OR 
						(tg.TrackingGroupKey = 'EDFOOTSCRAYTRACKINGGROUP' /*ED Footscray Tracking Group*/ AND tc_CHECKIN_DT_TM.MelbCalendarID >= 20230711 )
						OR
						(tg.TrackingGroupKey = 'EDSUNSHINETRACKINGGROUP'  /*ED Sunshine Tracking Group*/AND tc_CHECKIN_DT_TM.MelbCalendarID >= 20230713 )
				)														
		;
		-- SELECT * FROM #tmp_RAW_TI

	-- ==============================================================================================================================================
	-- Populate base table
	-- ==============================================================================================================================================
	IF OBJECT_ID('tempdb..#tmp_RAW_Base') IS NOT NULL DROP TABLE #tmp_RAW_Base;

    SELECT	e.ENCNTR_ID
            , e.PERSON_ID
            , ea_urn.ALIAS AS URNO
            , p.NAME_LAST	AS PatientLastName
            , p.NAME_FIRST	AS PatientFirstName

            , p.BIRTH_DT_TM  AS BIRTH_DT_TM_UTC

            , ea_visit.ALIAS AS ENCNTRNBR
            
            , e.LOC_FACILITY_CD AS LOC_FACILITY_CD

            , e.REG_DT_TM				AS REG_DT_TM_UTC
            , e.ARRIVE_DT_TM			AS ARRIVE_DT_TM_UTC
            , e.DEPART_DT_TM			AS DEPART_DT_TM_UTC
            , e.DISCH_DT_TM				AS DISCH_DT_TM_UTC
            , e.INPATIENT_ADMIT_DT_TM	AS INPATIENT_ADMIT_DT_TM_UTC
            , ROW_NUMBER() OVER( PARTITION BY e.ENCNTR_ID ORDER BY e.ENCNTR_ID ) AS row_num
    INTO #tmp_RAW_Base
    FROM	CERNER.dbo.ENCOUNTER AS e WITH(NOLOCK)
            INNER JOIN #tmp_RAW_TI AS ti ON ti.ENCNTR_ID = e.ENCNTR_ID

            INNER JOIN CERNER.dbo.PERSON AS p WITH(NOLOCK) ON	p.PERSON_ID = e.PERSON_ID
                                                                        AND p.ACTIVE_IND = 1 
                                                                        AND p.END_EFFECTIVE_DT_TM >= GETUTCDATE()

            INNER JOIN CERNER.dbo.PERSON_ALIAS AS pa WITH (NOLOCK) ON pa.PERSON_ID = e.pERSON_ID
                                                                    AND pa.ACTIVE_IND = 1
                                                                    AND pa.PERSON_ALIAS_TYPE_CD = 10
                                                                    AND pa.ALIAS_POOL_CD = 9569589		/*WHS UR Number*/
                                                                    AND pa.END_EFFECTIVE_DT_TM >= GETUTCDATE()   

            LEFT JOIN CERNER.dbo.ENCNTR_ALIAS AS ea_urn WITH(NOLOCK) ON ea_urn.ENCNTR_ID = e.ENCNTR_ID
                                                                            AND ea_urn.ALIAS_POOL_CD = 9569589   /*WHS UR Number*/
                                                                            AND ea_urn.ENCNTR_ALIAS_TYPE_CD = 1079 /*MRN*/
                                                                            AND ea_urn.ACTIVE_IND = 1
                                                                            AND ea_urn.BEG_EFFECTIVE_DT_TM <= GETUTCDATE()
                                                                            AND ea_urn.END_EFFECTIVE_DT_TM >= GETUTCDATE() 

            LEFT JOIN CERNER.dbo.ENCNTR_ALIAS AS ea_visit WITH(NOLOCK) ON ea_visit.ENCNTR_ID = e.ENCNTR_ID
                                                                                AND ea_visit.ALIAS_POOL_CD = 9569592   /*WHS Episode Number*/
                                                                                AND ea_visit.ENCNTR_ALIAS_TYPE_CD = 1077
                                                                                AND ea_visit.ACTIVE_IND = 1
                                                                                AND ea_visit.BEG_EFFECTIVE_DT_TM <= GETUTCDATE()
                                                                                AND ea_visit.END_EFFECTIVE_DT_TM >= GETUTCDATE()

          
    WHERE	e.ACTIVE_IND = 1
	;

	DELETE FROM #tmp_RAW_Base WHERE row_num > 1; -- REMOVE ANY DUPLICATE ROWS
	DELETE a FROM #tmp_RAW_Base AS a INNER JOIN PreMaP.dbo.TestPatient AS b WITH(NOLOCK) ON b.PERSON_ID = a.PERSON_ID; -- REMOVE TEST PATIENTS BY COMPARING AGAINST LOCAL LIST OF KNOWN TEST PATIENTS

	SELECT * FROM #tmp_RAW_Base -- THIS IS THE BASE POPULATION FOR OUR ED REPORTING