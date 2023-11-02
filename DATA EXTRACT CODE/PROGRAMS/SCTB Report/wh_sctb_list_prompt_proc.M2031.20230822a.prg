drop program wh_sctb_list_prompt_proc:group1 go
create program wh_sctb_list_prompt_proc:group1


/*************************************************************************************************
 * Specialist Clinic Tracking Board Prompt Processor
 * Paramters
 *   TYPE = "EPISODE_PROGRAM", "ECSMS", "SPECIALTY", "APPT_TYPE"
 *   MODE = "PROMPT", "REPORT". 
 *
 *
 * Thanks to Bob Ross and Philip Weilnau of uCern for the insights!
 ************************************************************************************************/
prompt 
	"Type" = "0"
	, "Mode" = 0
	, "Prompt List" = 0
	, "EP List" = 0
	, "ECSMS List" = 0
	, "Speciality List" = 0
	, "Facility Code" = 0 

with TYPE, MODE, PROMPT_LIST, EPISODE_PROGRAM_CD_LIST, ECSMS_FIELD_VALUE_LIST, 
	MEDICAL_SERVICE_CD_LIST, FACILITY_CD

IF ("PROMPT" = $MODE)
	execute CCL_PROMPT_API_DATASET "autoset"
	declare init_size 									= i4 with noconstant(100), protect 
ENDIF

set TRACE = RECPERSIST ; makes record defined below persistent.
declare	expand_cntr										= i4 with protect, noconstant(-1)

IF (("EPISODE_PROGRAM" = $TYPE) or ("SPECIALTY" = $TYPE) or ("APPT_TYPE" = $TYPE))
	free record episode_programs
	record episode_programs
	(	1 cnt											= i4
		1 any											= i1 ; 1-Any (*) selected, 0=otherwise
		1 prompt_str									= c100
		1 qual[*]
			2 code_value								= f8
	)
	set episode_programs->cnt			= 0

	if(substring(1,1,reflect(parameter(parameter2($EPISODE_PROGRAM_CD_LIST),0))) = "L")
		set debug = "Multiple episode_programs were selected at episode program group prompt"
		set episode_programs->any = 0
		set lcheck = substring(1,1,reflect(parameter(parameter2($EPISODE_PROGRAM_CD_LIST),episode_programs->cnt + 1)))
		set episode_programs->prompt_str = "Multiple"
		while (lcheck > " ")
			set episode_programs->cnt = episode_programs->cnt + 1
			set stat = alterlist(episode_programs->qual, episode_programs->cnt)
			set episode_programs->qual[episode_programs->cnt]->code_value = \
				cnvtreal(parameter(parameter2($EPISODE_PROGRAM_CD_LIST), episode_programs->cnt))
			set lcheck = substring(1,1,reflect(parameter(parameter2($EPISODE_PROGRAM_CD_LIST),episode_programs->cnt + 1)))
		endwhile
	elseif(cnvtreal(parameter(parameter2($EPISODE_PROGRAM_CD_LIST),1))= 0) ;any was selected at $episode program group prompt
		set debug = "Any episode_programs was selected at episode program group prompt"
		set episode_programs->any = 1
		set episode_programs->prompt_str = "Any (*)"
		SELECT INTO "nl:"

		FROM
			code_value_group eptospec
			, code_value_group spectoappt
			, code_value   ep
			, code_value spec
			, code_value appt

		plan ep 
		where ep.code_set = 101556
		and ep.active_ind = 1

		join eptospec
		where eptospec.code_set = 34
		and eptospec.parent_code_value = ep.code_value

		join spec 
		where spec.code_value = eptospec.child_code_value
		and spec.active_ind = 1

		join spectoappt
		where spectoappt.parent_code_value = spec.code_value

		join appt 
		where appt.code_value = spectoappt.child_code_value
		and appt.active_ind = 1
		ORDER BY ep.code_value
		HEAD ep.code_value
			episode_programs->cnt = episode_programs->cnt + 1
			stat = alterlist(episode_programs->qual, episode_programs->cnt)
			episode_programs->qual[episode_programs->cnt]->code_value = ep.code_value
		WITH nocounter, separator=" ", format
	else ;a single value was selected at the episode program group prompt
		set debug = "A single episode program group was selected at episode program group prompt"
		set episode_programs->any = 0
		set episode_programs->cnt = 1
		set stat = alterlist(episode_programs->qual, episode_programs->cnt)
		set episode_programs->qual[1]->code_value = CNVTREAL($EPISODE_PROGRAM_CD_LIST)
		set episode_programs->prompt_str = uar_get_code_display(episode_programs->qual[1]->code_value)
	endif
	IF (("EPISODE_PROGRAM" = $TYPE) and ("PROMPT" = $MODE))
		SELECT INTO "nl:"
			code_value_disp									= uar_get_code_display(episode_programs->qual[d1.seq]->code_value)
			, code_value									= trim(cnvtstring(episode_programs->qual[d1.seq]->code_value))
		FROM
			(dummyt d1 with seq = value(episode_programs->cnt))

		PLAN d1
			WHERE episode_programs->cnt										!= 0
		ORDER BY code_value_disp
		head report
			stat = MakeDataset(init_size)
		detail
			stat = WriteRecord(0)
		foot report
			stat = CloseDataset(0) 
		WITH format, separator = " ",time = 30, reporthelp
	ENDIF
ENDIF
IF (("ECSMS" = $TYPE) or ("SPECIALTY" = $TYPE) or ("APPT_TYPE" = $TYPE))
	free record extended_code_set_medical_services
	record extended_code_set_medical_services
	(	1 cnt											= i4
		1 any											= i1 ; 1-Any (*) selected, 0=otherwise
		1 prompt_str									= c100
		1 qual[*]
			2 field_value								= c100
	)
	set extended_code_set_medical_services->cnt			= 0

	if(substring(1,1,reflect(parameter(parameter2($ECSMS_FIELD_VALUE_LIST),0))) = "L")
		set debug = "Multiple extended_code_set_medical_services were selected at extended code set medical servicegroup prompt"
		set extended_code_set_medical_services->any = 0
		set lcheck = substring(1,1,reflect(parameter(parameter2($ECSMS_FIELD_VALUE_LIST),extended_code_set_medical_services->cnt + 1)))
		set extended_code_set_medical_services->prompt_str = "Multiple"
		while (lcheck > " ")
			set extended_code_set_medical_services->cnt = extended_code_set_medical_services->cnt + 1
			set stat = alterlist(extended_code_set_medical_services->qual, extended_code_set_medical_services->cnt)
			set extended_code_set_medical_services->qual[extended_code_set_medical_services->cnt]->field_value = \
				parameter(parameter2($ECSMS_FIELD_VALUE_LIST), extended_code_set_medical_services->cnt)
			set lcheck = substring(1,1,reflect(parameter(parameter2($ECSMS_FIELD_VALUE_LIST),extended_code_set_medical_services->cnt + 1)))
		endwhile
	elseif(trim($ECSMS_FIELD_VALUE_LIST)= "Any (*)")
	;any was selected at $extended code set medical servicegroup prompt
		set debug = "Any extended_code_set_medical_services was selected at extended code set medical servicegroup prompt"
		set extended_code_set_medical_services->any = 1
		set extended_code_set_medical_services->prompt_str = "Any (*)"
		SELECT INTO "nl:"
		FROM
			code_value_extension   cve
			, code_value_group   spectoappt
			, code_value   appt

		WHERE cve.code_set = 34
		AND cve.field_name = "Correspondence_Area"
		AND spectoappt.parent_code_value = cve.code_value
		AND appt.code_value = spectoappt.child_code_value
		AND appt.code_set = 14230
		AND appt.active_ind = 1
		ORDER BY cve.field_value
		HEAD cve.field_value
			extended_code_set_medical_services->cnt = extended_code_set_medical_services->cnt + 1
			stat = alterlist(extended_code_set_medical_services->qual, extended_code_set_medical_services->cnt)
			extended_code_set_medical_services->qual[extended_code_set_medical_services->cnt]->field_value = cve.field_value
		WITH nocounter, separator=" ", format
	else ;a single value was selected at the extended code set medical servicegroup prompt
		set debug = "A single extended code set medical servicegroup was selected at extended code set medical servicegroup prompt"
		set extended_code_set_medical_services->any = 0
		set extended_code_set_medical_services->cnt = 1
		set stat = alterlist(extended_code_set_medical_services->qual, extended_code_set_medical_services->cnt)
		set extended_code_set_medical_services->qual[1]->field_value = trim($ECSMS_FIELD_VALUE_LIST)
		set extended_code_set_medical_services->prompt_str = extended_code_set_medical_services->qual[1]->field_value
	endif
	IF ((("ECSMS" = $TYPE)) AND ("PROMPT" = $MODE))
		SELECT INTO "nl:"
			field_value									= trim(extended_code_set_medical_services->qual[d1.seq]->field_value)
		FROM
			(dummyt d1 with seq = value(extended_code_set_medical_services->cnt))

		PLAN d1
			WHERE extended_code_set_medical_services->cnt										!= 0
		ORDER BY field_value
		head report
			stat = MakeDataset(init_size)
		detail
			stat = WriteRecord(0)
		foot report
			stat = CloseDataset(0) 
		WITH format, separator = " ",time = 30, reporthelp
	ENDIF
ENDIF
IF (("SPECIALTY" = $TYPE) or ("APPT_TYPE" = $TYPE))
	free record medical_services
	record medical_services
	(	1 cnt											= i4
		1 any											= i1 ; 1-Any (*) selected, 0=otherwise
		1 prompt_str									= c100
		1 qual[*]
			2 code_value								= f8
	)
	set medical_services->cnt			= 0

	if(substring(1,1,reflect(parameter(parameter2($MEDICAL_SERVICE_CD_LIST),0))) = "L")
		set debug = "Multiple medical_services were selected at medical service group prompt"
		set medical_services->any = 0
		set lcheck = substring(1,1,reflect(parameter(parameter2($MEDICAL_SERVICE_CD_LIST),medical_services->cnt + 1)))
		set medical_services->prompt_str = "Multiple"
		while (lcheck > " ")
			set medical_services->cnt = medical_services->cnt + 1
			set stat = alterlist(medical_services->qual, medical_services->cnt)
			set medical_services->qual[medical_services->cnt]->code_value = \
				cnvtreal(parameter(parameter2($MEDICAL_SERVICE_CD_LIST), medical_services->cnt))
			set lcheck = substring(1,1,reflect(parameter(parameter2($MEDICAL_SERVICE_CD_LIST),medical_services->cnt + 1)))
		endwhile
	elseif(cnvtreal(parameter(parameter2($MEDICAL_SERVICE_CD_LIST),1))= 0) ;any was selected at $medical service group prompt
		set debug = "Any medical_services was selected at medical service group prompt"
		set medical_services->any = 1
		set medical_services->prompt_str = "Any (*)"
		IF ((1 = episode_programs->any) and (1 = extended_code_set_medical_services->any))
			SELECT DISTINCT INTO "nl:"
			FROM
				code_value_group   		spectoappt
				, code_value   			appt
				, code_value 			spec
			PLAN spec
				WHERE spec.code_set = 34
				AND spec.active_ind = 1
			JOIN spectoappt
				WHERE spec.code_value = spectoappt.parent_code_value
			JOIN appt
				WHERE spectoappt.child_code_value = appt.code_value
				AND appt.code_set = 14230
				AND appt.active_ind = 1
			ORDER BY uar_get_code_display(spec.code_value)
			DETAIL
				medical_services->cnt = medical_services->cnt + 1
				stat = alterlist(medical_services->qual, medical_services->cnt)
				medical_services->qual[medical_services->cnt]->code_value = spec.code_value
			WITH nocounter, separator=" ", format
		ENDIF
		IF ((1 = episode_programs->any) and (0 = extended_code_set_medical_services->any))
		; Extended code set medical service
			SELECT DISTINCT INTO "nl:"
			FROM
				code_value_extension   cve
				, code_value_group   spectoappt
				, code_value   appt
			WHERE cve.code_set = 34
			AND cve.field_name = "Correspondence_Area"
			AND spectoappt.parent_code_value = cve.code_value
			AND EXPAND(expand_cntr, 1, extended_code_set_medical_services->cnt, cve.field_value, 
				extended_code_set_medical_services->qual[expand_cntr]->field_value)
			AND appt.code_value = spectoappt.child_code_value
			AND appt.code_set = 14230
			AND appt.active_ind = 1
			ORDER BY uar_get_code_display(cve.code_value)
			DETAIL
				medical_services->cnt = medical_services->cnt + 1
				stat = alterlist(medical_services->qual, medical_services->cnt)
				medical_services->qual[medical_services->cnt]->code_value = cve.code_value
			WITH nocounter, separator=" ", format
		ENDIF
		IF ((0 = episode_programs->any) and (1 = extended_code_set_medical_services->any))
		; Episode Program
			SELECT DISTINCT INTO "nl:"
			FROM
				code_value_group eptospec
				, code_value_group spectoappt
				, code_value   ep
				, code_value spec
				, code_value appt

			where ep.code_set = 101556
			and ep.active_ind = 1
			and EXPAND(expand_cntr, 1, episode_programs->cnt, ep.code_value, episode_programs->qual[expand_cntr]->code_value)
			and eptospec.code_set = 34
			and eptospec.parent_code_value = ep.code_value
			and spec.code_value = eptospec.child_code_value
			and spec.active_ind = 1
			and spectoappt.parent_code_value = spec.code_value
			and appt.code_value = spectoappt.child_code_value
			and appt.active_ind = 1
			ORDER BY uar_get_code_display(spec.code_value)
			DETAIL
				medical_services->cnt = medical_services->cnt + 1
				stat = alterlist(medical_services->qual, medical_services->cnt)
				medical_services->qual[medical_services->cnt]->code_value = spec.code_value
			WITH nocounter, separator=" ", format
		ENDIF
		IF ((0 = episode_programs->any) and (0 = extended_code_set_medical_services->any))
		; Extended code set medical service
			SELECT INTO "nl:"
				spec_cd=cve.code_value
			FROM
				code_value_extension   cve
				, code_value_group   spectoappt
				, code_value   appt
			WHERE cve.code_set = 34
			AND cve.field_name = "Correspondence_Area"
			AND spectoappt.parent_code_value = cve.code_value
			AND EXPAND(expand_cntr, 1, extended_code_set_medical_services->cnt, cve.field_value, 
				extended_code_set_medical_services->qual[expand_cntr]->field_value)
			AND appt.code_value = spectoappt.child_code_value
			AND appt.code_set = 14230
			AND appt.active_ind = 1
		INTERSECT (	
		; Episode Program
			SELECT INTO "nl:"
				spec_cd=spec.code_value
			FROM
				code_value_group eptospec
				, code_value_group spectoappt
				, code_value   ep
				, code_value spec
				, code_value appt

			where ep.code_set = 101556
			and ep.active_ind = 1
			and EXPAND(expand_cntr, 1, episode_programs->cnt, ep.code_value, episode_programs->qual[expand_cntr]->code_value)
			and eptospec.code_set = 34
			and eptospec.parent_code_value = ep.code_value
			and spec.code_value = eptospec.child_code_value
			and spec.active_ind = 1
			and spectoappt.parent_code_value = spec.code_value
			and appt.code_value = spectoappt.child_code_value
			and appt.active_ind = 1
		)
			DETAIL
				medical_services->cnt = medical_services->cnt + 1
				stat = alterlist(medical_services->qual, medical_services->cnt)
				medical_services->qual[medical_services->cnt]->code_value = spec_cd
			WITH nocounter, separator=" ", format
		ENDIF
	else ;a single value was selected at the medical service group prompt
		set debug = "A single medical service group was selected at medical service group prompt"
		set medical_services->any = 0
		set medical_services->cnt = 1
		set stat = alterlist(medical_services->qual, medical_services->cnt)
		set medical_services->qual[1]->code_value = CNVTREAL($MEDICAL_SERVICE_CD_LIST)
		set medical_services->prompt_str = uar_get_code_display(medical_services->qual[1]->code_value)
	endif
	IF (("SPECIALTY" = $TYPE) AND ("PROMPT" = $MODE))
		SELECT INTO "nl:"
			code_value_disp									= uar_get_code_display(medical_services->qual[d1.seq]->code_value)
			, code_value									= trim(cnvtstring(medical_services->qual[d1.seq]->code_value))
		FROM
			(dummyt d1 with seq = value(medical_services->cnt))

		PLAN d1
			WHERE medical_services->cnt										!= 0
		ORDER BY code_value_disp
		head report
			stat = MakeDataset(init_size)
		detail
			stat = WriteRecord(0)
		foot report
			stat = CloseDataset(0) 
		WITH format, separator = " ",time = 30, reporthelp
	ENDIF
ENDIF
IF ("APPT_TYPE" = $TYPE)
	free record appointment_types
	record appointment_types
	(	1 cnt											= i4
		1 any											= i1 ; 1-Any (*) selected, 0=otherwise
		1 prompt_str									= c100
		1 qual[*]
			2 code_value								= f8
	)
	set appointment_types->cnt							= 0

	if(substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),0))) = "L")
		set debug = "Multiple appointment_types were selected at appointment type group prompt"
		set appointment_types->any = 0
		set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),appointment_types->cnt + 1)))
		set appointment_types->prompt_str = "Multiple"
		while (lcheck > " ")
			set appointment_types->cnt = appointment_types->cnt + 1
			set stat = alterlist(appointment_types->qual, appointment_types->cnt)
			set appointment_types->qual[appointment_types->cnt]->code_value = \
				cnvtreal(parameter(parameter2($PROMPT_LIST), appointment_types->cnt))
			set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),appointment_types->cnt + 1)))
		endwhile
	elseif(cnvtreal(parameter(parameter2($PROMPT_LIST),1)) = 0) ;any was selected at $appointment type group prompt
		set debug = "Any appointment_types was selected at appointment type group prompt"
		set appointment_types->any = 1
		set appointment_types->prompt_str = "Any (*)"
		SELECT INTO "nl:"

		FROM
			code_value_group spectoappt
			, code_value spec
			, code_value appt
		plan spec 
		where spec.active_ind = 1
		and EXPAND(expand_cntr, 1, medical_services->cnt, spec.code_value, medical_services->qual[expand_cntr]->code_value)

		join spectoappt
		where spectoappt.parent_code_value = spec.code_value

		join appt 
		where appt.code_value = spectoappt.child_code_value
		and appt.active_ind = 1
		ORDER BY appt.code_value
		HEAD appt.code_value
			appointment_types->cnt = appointment_types->cnt + 1
			stat = alterlist(appointment_types->qual, appointment_types->cnt)
			appointment_types->qual[appointment_types->cnt]->code_value = appt.code_value
		WITH nocounter, separator=" ", format
	else ;a single value was selected at the appointment type group prompt
		set debug = "A single appointment type group was selected at appointment type group prompt"
		set appointment_types->any = 0
		set appointment_types->cnt = 1
		set stat = alterlist(appointment_types->qual, appointment_types->cnt)
		set appointment_types->qual[1]->code_value = CNVTREAL($PROMPT_LIST)
		set appointment_types->prompt_str = uar_get_code_display(appointment_types->qual[1]->code_value)
	endif
	IF ("PROMPT" = $MODE)
		SELECT INTO "nl:"
			code_value_disp									= uar_get_code_display(appointment_types->qual[d1.seq]->code_value)
			, code_value									= trim(cnvtstring(appointment_types->qual[d1.seq]->code_value))
		FROM
			(dummyt d1 with seq = value(appointment_types->cnt))

		PLAN d1
			WHERE appointment_types->cnt										!= 0
		ORDER BY code_value_disp
		head report
			stat = MakeDataset(init_size)
		detail
			stat = WriteRecord(0)
		foot report
			stat = CloseDataset(0) 
		WITH format, separator = " ",time = 30, reporthelp
	ENDIF
ENDIF
IF ("LOCATION_GROUP" = $TYPE)
	free record location_groups
	record location_groups
	(	1 cnt											= i4
		1 any											= i1 ; 1-Any (*) selected, 0=otherwise
		1 prompt_str									= c100
		1 qual[*]
			2 code_value								= f8
	)
	set location_groups->cnt							= 0

	if(substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),0))) = "L")
		set debug = "Multiple location_groups were selected at location group prompt"
		set location_groups->any = 0
		set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),location_groups->cnt + 1)))
		set location_groups->prompt_str = "Multiple"
		while (lcheck > " ")
			set location_groups->cnt = location_groups->cnt + 1
			set stat = alterlist(location_groups->qual, location_groups->cnt)
			set location_groups->qual[location_groups->cnt]->code_value = \
				cnvtreal(parameter(parameter2($PROMPT_LIST), location_groups->cnt))
			set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),location_groups->cnt + 1)))
		endwhile
	elseif(cnvtreal(parameter(parameter2($PROMPT_LIST),1))= 0) ;any was selected at $location group prompt
		set debug = "Any location_groups was selected at location group prompt"
		set location_groups->any = 1
		set location_groups->prompt_str = "Any (*)"
		SELECT INTO "nl:"
		FROM
		  sch_object   so
		  , sch_assoc   sa
		  , location   l
		  , nurse_unit n
		PLAN so
			WHERE so.object_type_meaning = "LOCGROUP"
			AND so.active_ind = 1
		JOIN sa
			WHERE so.sch_object_id = sa.parent_id
			AND sa.active_ind = 1
		JOIN l
			WHERE sa.child_id = l.location_cd
			AND l.active_ind = 1
		JOIN n
			WHERE l.location_cd = n.location_cd
			AND n.active_ind = 1
			AND n.loc_facility_cd = CNVTREAL($FACILITY_CD)
		ORDER BY so.sch_object_id
		HEAD so.sch_object_id
			location_groups->cnt = location_groups->cnt + 1
			stat = alterlist(location_groups->qual, location_groups->cnt)
			location_groups->qual[location_groups->cnt]->code_value = so.sch_object_id
		WITH nocounter, separator=" ", format

	else ;a single value was selected at the location group prompt
		set debug = "A single location group was selected at location group prompt"
		set location_groups->any = 0
		set location_groups->cnt = 1
		set stat = alterlist(location_groups->qual, location_groups->cnt)
		set location_groups->qual[1]->code_value = CNVTREAL($PROMPT_LIST)
		set location_groups->prompt_str = uar_get_code_display(location_groups->qual[1]->code_value)
	endif
	IF ("PROMPT" = $MODE)
		SELECT INTO "nl:"
			code_value_disp									= so.mnemonic
			, code_value									= trim(cnvtstring(location_groups->qual[d1.seq]->code_value))
		FROM
			(dummyt d1 with seq = value(location_groups->cnt))
			, sch_object													so

		PLAN d1
			WHERE location_groups->cnt										!= 0
		JOIN so
			WHERE location_groups->qual[d1.seq]->code_value = so.sch_object_id
		ORDER BY code_value_disp
		head report
			stat = MakeDataset(init_size)
		detail
			stat = WriteRecord(0)
		foot report
			stat = CloseDataset(0) 
		WITH format, separator = " ",time = 30, reporthelp
	ENDIF
ENDIF
IF ("CONTACT_MODE" = $TYPE)
	free record modes_of_contact
	record modes_of_contact
	(	1 cnt											= i4
		1 any											= i1 ; 1-Any (*) selected, 0=otherwise
		1 prompt_str									= c100
		1 qual[*]
			2 code_value								= f8
	)
	set modes_of_contact->cnt							= 0

	if(substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),0))) = "L")
		set debug = "Multiple modes_of_contact were selected at modes of contact group prompt"
		set modes_of_contact->any = 0
		set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),modes_of_contact->cnt + 1)))
		set modes_of_contact->prompt_str = "Multiple"
		while (lcheck > " ")
			set modes_of_contact->cnt = modes_of_contact->cnt + 1
			set stat = alterlist(modes_of_contact->qual, modes_of_contact->cnt)
			set modes_of_contact->qual[modes_of_contact->cnt]->code_value = \
				cnvtreal(parameter(parameter2($PROMPT_LIST), modes_of_contact->cnt))
			set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),modes_of_contact->cnt + 1)))
		endwhile
	elseif(cnvtreal(parameter(parameter2($PROMPT_LIST),1))= 0) ;any was selected at $modes of contact group prompt
		set debug = "Any modes_of_contact was selected at modes of contact group prompt"
		set modes_of_contact->any = 1
		set modes_of_contact->prompt_str = "Any (*)"
		select into "nl:"
			from code_value cv
			where cv.code_set = 101600
			and cv.active_ind = 1
			and cv.end_effective_dt_tm > sysdate
		detail 
			modes_of_contact->cnt = modes_of_contact->cnt + 1
			stat = alterlist(modes_of_contact->qual, modes_of_contact->cnt)
			modes_of_contact->qual[modes_of_contact->cnt]->code_value = cv.code_value
		with nocounter, separator=" ", format

	else ;a single value was selected at the modes of contact group prompt
		set debug = "A single modes of contact group was selected at modes of contact group prompt"
		set modes_of_contact->any = 0
		set modes_of_contact->cnt = 1
		set stat = alterlist(modes_of_contact->qual, modes_of_contact->cnt)
		set modes_of_contact->qual[1]->code_value = CNVTREAL($PROMPT_LIST)
		set modes_of_contact->prompt_str = uar_get_code_display(modes_of_contact->qual[1]->code_value)
	endif
	IF ("PROMPT" = $MODE)
		SELECT INTO "nl:"
			code_value_disp									= uar_get_code_display(modes_of_contact->qual[d1.seq]->code_value)
			, code_value									= trim(cnvtstring(modes_of_contact->qual[d1.seq]->code_value))
		FROM
			(dummyt d1 with seq = value(modes_of_contact->cnt))

		PLAN d1
			WHERE modes_of_contact->cnt										!= 0
		ORDER BY code_value_disp
		head report
			stat = MakeDataset(init_size)
		detail
			stat = WriteRecord(0)
		foot report
			stat = CloseDataset(0) 
		WITH format, separator = " ",time = 30, reporthelp
	ENDIF
ENDIF
IF ("APPT_STATUS" = $TYPE)
	free record appointment_statuses
	record appointment_statuses
	(	1 cnt											= i4
		1 any											= i1 ; 1-Any (*) selected, 0=otherwise
		1 prompt_str									= c100
		1 qual[*]
			2 code_value								= f8
	)
	set appointment_statuses->cnt							= 0

	if(substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),0))) = "L")
		set debug = "Multiple appointment_statuses were selected at appointment status prompt"
		set appointment_statuses->any = 0
		set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),appointment_statuses->cnt + 1)))
		set appointment_statuses->prompt_str = "Multiple"
		while (lcheck > " ")
			set appointment_statuses->cnt = appointment_statuses->cnt + 1
			set stat = alterlist(appointment_statuses->qual, appointment_statuses->cnt)
			set appointment_statuses->qual[appointment_statuses->cnt]->code_value = \
				cnvtreal(parameter(parameter2($PROMPT_LIST), appointment_statuses->cnt))
			set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),appointment_statuses->cnt + 1)))
		endwhile
	elseif(cnvtreal(parameter(parameter2($PROMPT_LIST),1))= 0) ;any was selected at $appointment status prompt
		set debug = "Any appointment_statuses was selected at appointment status prompt"
		set appointment_statuses->any = 1
		set appointment_statuses->prompt_str = "Any (*)"
		select into "nl:"
			from code_value 									cv
			where cv.code_set 									in (14232, 14233)
			and cv.active_ind 									= 1
			and cv.end_effective_dt_tm 							> sysdate
			and cv.code_value in 								(value(uar_get_code_by("MEANING", 14232, "CONFIRM"))
																, value(uar_get_code_by("MEANING", 14232, "PTPATARRVED"))
																, value(uar_get_code_by("MEANING", 14232, "CHECKIN"))
																, value(uar_get_code_by("MEANING", 14232, "PTPATREADY"))
																, value(uar_get_code_by("MEANING", 14232, "PTPATFINISH"))
																, value(uar_get_code_by("MEANING", 14232, "PTPATINROOM"))
																, value(uar_get_code_by("MEANING", 14232, "CHECKOUT"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYPHYSIC"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYNURSE"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYMIDLEV"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYGEN1"))
																, value(uar_get_code_by("MEANING", 14232, "SEENBYGEN2"))
																, value(uar_get_code_by("MEANING", 14232, "HOLD"))
																;*** Note different code set
																, value(uar_get_code_by("MEANING", 14233, "CANCELED"))
																, value(uar_get_code_by("MEANING", 14232, "NOSHOW")))
		detail 
			appointment_statuses->cnt = appointment_statuses->cnt + 1
			stat = alterlist(appointment_statuses->qual, appointment_statuses->cnt)
			appointment_statuses->qual[appointment_statuses->cnt]->code_value = cv.code_value
		with nocounter, separator=" ", format

	else ;a single value was selected at the appointment status prompt
		set debug = "A single appointment type was selected at appointment status prompt"
		set appointment_statuses->any = 0
		set appointment_statuses->cnt = 1
		set stat = alterlist(appointment_statuses->qual, appointment_statuses->cnt)
		set appointment_statuses->qual[1]->code_value = CNVTREAL($PROMPT_LIST)
		set appointment_statuses->prompt_str = uar_get_code_display(appointment_statuses->qual[1]->code_value)
	endif
	IF ("PROMPT" = $MODE)
		SELECT INTO "nl:"
			code_value_disp									= uar_get_code_display(appointment_statuses->qual[d1.seq]->code_value)
			, code_value									= trim(cnvtstring(appointment_statuses->qual[d1.seq]->code_value))
		FROM
			(dummyt d1 with seq = value(appointment_statuses->cnt))

		PLAN d1
			WHERE appointment_statuses->cnt										!= 0
		ORDER BY code_value_disp
		head report
			stat = MakeDataset(init_size)
		detail
			stat = WriteRecord(0)
		foot report
			stat = CloseDataset(0) 
		WITH format, separator = " ",time = 30, reporthelp
	ENDIF
ENDIF
IF ("RESOURCE" = $TYPE)
	free record resources
	record resources
	(	1 cnt											= i4
		1 any											= i1 ; 1-Any (*) selected, 0=otherwise
		1 prompt_str									= c100
		1 qual[*]
			2 code_value								= f8
	)
	set resources->cnt									= 0

	if(substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),0))) = "L")
		set debug = "Multiple resources were selected at resource prompt"
		set resources->any = 0
		set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),resources->cnt + 1)))
		set resources->prompt_str = "Multiple"
		while (lcheck > " ")
			set resources->cnt = resources->cnt + 1
			set stat = alterlist(resources->qual, resources->cnt)
			set resources->qual[resources->cnt]->code_value = \
				cnvtreal(parameter(parameter2($PROMPT_LIST), resources->cnt))
			set lcheck = substring(1,1,reflect(parameter(parameter2($PROMPT_LIST),resources->cnt + 1)))
		endwhile
	elseif(cnvtreal(parameter(parameter2($PROMPT_LIST),1))= 0) ;any was selected at resource prompt
		set debug = "Any resources was selected at resource prompt"
		set resources->any = 1
		set resources->prompt_str = "Any (*)"
		select into "nl:"
			from code_value cv
			where cv.code_set = 14231
			and cv.active_ind = 1
			and cv.end_effective_dt_tm > sysdate
		detail 
			resources->cnt = resources->cnt + 1
			stat = alterlist(resources->qual, resources->cnt)
			resources->qual[resources->cnt]->code_value = cv.code_value
		with nocounter, separator=" ", format

	else ;a single value was selected at the resource prompt
		set debug = "A single appointment type was selected at resource prompt"
		set resources->any = 0
		set resources->cnt = 1
		set stat = alterlist(resources->qual, resources->cnt)
		set resources->qual[1]->code_value = CNVTREAL($PROMPT_LIST)
		set resources->prompt_str = uar_get_code_display(resources->qual[1]->code_value)
	endif
	IF ("PROMPT" = $MODE)
		SELECT INTO "nl:"
			code_value_disp									= uar_get_code_display(resources->qual[d1.seq]->code_value)
			, code_value									= trim(cnvtstring(resources->qual[d1.seq]->code_value))
		FROM
			(dummyt d1 with seq = value(resources->cnt))

		PLAN d1
			WHERE resources->cnt							!= 0
		ORDER BY code_value_disp
		head report
			stat = MakeDataset(init_size)
		detail
			stat = WriteRecord(0)
		foot report
			stat = CloseDataset(0) 
		WITH format, separator = " ",time = 30, reporthelp
	ENDIF
ENDIF
end
go
