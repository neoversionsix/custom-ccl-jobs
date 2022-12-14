drop program wh_testing_query_88:dba go
create program wh_testing_query_88:dba

prompt 
	"Output to File/Printer/MINE" = "MINE" 

with OUTDEV

SELECT INTO $OUTDEV
/*
*/
declare look_back = C3 with Constant("1,W"), protect


select into $outdev


;    e.person_id


; ,
 e.encntr_type_class_cd


, E_ENCNTR_TYPE_CLASS_DISP = substring(1,20,UAR_GET_CODE_DISPLAY(E.ENCNTR_TYPE_CLASS_CD))


, ecnt = count(e.encntr_id)


from encounter e


where e.reg_dt_tm between cnvtlookbehind(look_back) and cnvtdatetime(curdate,curtime3)


and e.encntr_type_class_cd != 0.0


 GROUP BY


;   e.person_id


 e.encntr_type_class_cd


ORDER BY


;   e.person_id


e.encntr_type_class_cd
; E_ENCNTR_TYPE_CLASS_DISP

;display the values in columns using reportwriter


; head e.person_id
; head e.encntr_type_class_cd
head e.encntr_type_class_cd

;col 0 e.encntr_type_class_cd
; e.encntr_type_class_cd


col_x = 0


detail


if(row +2 > maxrow)


  break


endif


    if(col_x < 100)


          col_x = col_x + 25


          col col_x  E_ENCNTR_TYPE_CLASS_DISP


          row +1


          col col_x ecnt ";L"


          row -1     


    else


          row + 2


          col_x = 25


          col col_x  E_ENCNTR_TYPE_CLASS_DISP


          row +1


          col col_x ecnt ";L"


          row -1


    endif


foot e.encntr_type_class_cd


row +2


WITH TIME = 60,
	MAXREC = 1000,
	NOCOUNTER,  
	SEPARATOR=" ", 
	FORMAT

end
go