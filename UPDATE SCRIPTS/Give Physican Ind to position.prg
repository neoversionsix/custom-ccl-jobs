UPDATE INTO prsnl p
SET 
    p.physician_ind = 1
    , p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    , p.updt_id = reqinfo->updt_id
    , p.updt_cnt = cred.updt_cnt + 1
WHERE 
    p.position_cd = 9655109 ; 9655109 is Medical Officer P1 in P2031
    AND 
    p.physician_ind = 0
