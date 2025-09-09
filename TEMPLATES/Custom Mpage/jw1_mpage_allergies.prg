drop program jw1_mpage_allergies:dba go
create program jw1_mpage_allergies:dba

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Person Id:" = 0
with outdev, personid

/*  Begin the xml string  */
declare sXML = vc with protect, noconstant("")

set sXML = "<?xml version='1.0' encoding='iso-8859-1' standalone='no' ?><RPT_DATA>"

/**************************************************
 *     Get the Allergies and Reactions            *
 **************************************************/

declare reactionString = vc with public, noconstant("")

select into "nl:"
   sortName = if( n.nomenclature_id = 0 and TRIM( a.substance_ftdesc ) != "" )
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
      and r.end_effective_dt_tm > outerjoin(sysdate)
      and r.active_ind = outerjoin(1)

join n2
   where n2.nomenclature_id = outerjoin(r.reaction_nom_id)

order by sortName, a.allergy_id

head report
   cnt = 0
   reactionString = ""

head a.allergy_id
   reactionString = ""

   cnt = cnt + 1
   sXML = concat(sXML, "<allergy>")

   if( n.nomenclature_id = 0 and TRIM( a.substance_ftdesc ) != "" )
      sXML = concat(sXML, "<allergy_name>", a.SUBSTANCE_FTDESC, "</allergy_name>")
   else
      sXML = concat(sXML, "<allergy_name>", trim(n.SOURCE_STRING), "</allergy_name>")
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
   sXML = concat(sXML, "<allergy_reaction>", reactionString, "</allergy_reaction>")
   sXML = concat(sXML, "<allergy_id>", trim(BUILD2(a.allergy_id),3), "</allergy_id>")

   sXML = concat(sXML, "</allergy>")
with nocounter

/*  End the xml string  */
set sXML = concat(sXML, "</RPT_DATA>")

call echo(sXML)

 ;Set public memory variable equal to our XML string
set _Memory_Reply_String = sXML

end
go
