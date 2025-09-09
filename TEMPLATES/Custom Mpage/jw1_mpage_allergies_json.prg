drop program jw1_mpage_allergies_json:dba go
create program jw1_mpage_allergies_json:dba

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Person Id:" = 0.0

with outdev, personid

/*
Creates a JSON object as follows:

{
    "ALLERGIES": {
        "ALLERGY": [
            {
                "ALLERGY_NAME": "Adhesive bandage",
                "ALLERGY_REACTION": "None Documented",
                "ALLERGY_ID": 1.0
            },
            {
                "ALLERGY_NAME": "Ambien",
                "ALLERGY_REACTION": "Coma (3)",
                "ALLERGY_ID": 2.0
            },
            {
                "ALLERGY_NAME": "Tylenol",
                "ALLERGY_REACTION": "None Documented",
                "ALLERGY_ID": 3.0
            },
            {
                "ALLERGY_NAME": "aspirin",
                "ALLERGY_REACTION": "Nausea",
                "ALLERGY_ID": 4.0
            },
            {
                "ALLERGY_NAME": "penicillins",
                "ALLERGY_REACTION": "Hives, flourescent green rash",
                "ALLERGY_ID": 5.0
            }
        ]
    }
}

*/
free record ALLERGIES
record ALLERGIES (
	1 ALLERGY[*]
		2 ALLERGY_NAME = vc
		2 ALLERGY_REACTION = vc
		2 ALLERGY_ID = f8
)

/**************************************************
 *     Get the Allergies and Reactions            *
 **************************************************/

declare reactionString = vc with public, noconstant("")

select into "nl:"
	sortName = 	if( n.nomenclature_id = 0 and TRIM( a.substance_ftdesc ) != "" )
					cnvtupper(a.SUBSTANCE_FTDESC)
				else
					cnvtupper(n.SOURCE_STRING)
				endif

from
	allergy a,
	nomenclature n,
	reaction r,
	nomenclature n2

plan a
	where a.person_id = $PersonId
		and   a.substance_nom_id > 0.0
		and   a.cancel_dt_tm = NULL
		and   a.active_ind + 0 = 1

join n
	where n.nomenclature_id = a.substance_nom_id

join r
	where r.allergy_id = outerjoin(a.allergy_id)
		and r.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
		and r.active_ind = outerjoin(1)

join n2
	where n2.nomenclature_id = outerjoin(r.reaction_nom_id)

order by sortName, a.allergy_id

head report
	cnt = 0
	reactionString = ""

head a.allergy_id
	cnt = cnt+1
	if (cnt > size(ALLERGIES->ALLERGY,5))
		stat = alterlist(ALLERGIES->ALLERGY,cnt + 9)
	endif

	reactionString = ""

	if( n.nomenclature_id = 0 and TRIM( a.substance_ftdesc ) != "" )
		ALLERGIES->ALLERGY[cnt].ALLERGY_NAME = BUILD(a.SUBSTANCE_FTDESC)
	else
		ALLERGIES->ALLERGY[cnt].ALLERGY_NAME = BUILD(n.SOURCE_STRING)
	endif

detail
	if( n2.nomenclature_id = 0 and TRIM( r.reaction_ftdesc ) != "" )
		if(reactionString > " ")
			reactionString = build2(reactionString,", ",trim(r.reaction_ftdesc,3))
		else
			reactionString = concat(trim(r.reaction_ftdesc,3))
		endif
	else
		if(reactionString > " ")
			reactionString = build2(reactionString,", ",trim(n2.source_string,3))
		else
			reactionString = concat(trim(n2.source_string,3))
		endif
	endif

foot a.allergy_id
    if (reactionString = "")
       reactionString = "None Documented"
    endif
	ALLERGIES->ALLERGY[cnt].ALLERGY_REACTION = trim(reactionString,3)
	ALLERGIES->ALLERGY[cnt].ALLERGY_ID = a.allergy_id

foot report
	stat = alterlist(ALLERGIES->ALLERGY,cnt)

with nocounter

call echorecord(ALLERGIES)

;Set public memory variable equal to our XML string
set _Memory_Reply_String = CNVTRECTOJSON(ALLERGIES)

free record ALLERGIES

end
go