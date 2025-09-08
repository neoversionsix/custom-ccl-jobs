drop program jw1_mpage_patientinfo:dba go
create program jw1_mpage_patientinfo:dba

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Person Id:" = 15779987.00

with OUTDEV, PERSONID

free record patinfo
record patinfo (
	1 info[*]
		2 label = vc
		2 data = vc
		2 hover = vc
)


/**************************************************
 *     Get the Patient Name, DOB and Gender       *
 **************************************************/
select into "nl:"
   dob = format(p.birth_dt_tm,"mm/dd/yyyy;;d"),
   gender = uar_get_code_display(p.sex_cd)
from
   person p
plan p
   where p.person_id = $personId

head report

	stat = alterlist(patinfo->info, 3)
	patinfo->info[1].label = "Patient Name : "
	patinfo->info[1].data = p.name_full_formatted
	patinfo->info[1].hover = build2("This person's name is: ", p.name_full_formatted)

	patinfo->info[2].label = "Birth Date : "
	patinfo->info[2].data = dob
	patinfo->info[2].hover = build2("This person's birthdate is: ", dob)

	patinfo->info[3].label = "Gender : "
	patinfo->info[3].data = gender
	patinfo->info[3].hover = build2("This person's gender is: ", gender)
with nocounter

call echorecord(patinfo)

set _Memory_Reply_String = CNVTRECTOJSON(patinfo)

end
go