

;---OEF default field value correction---------------------------------------------------------------------------------
UPDATE INTO
    OE_FORMAT_FIELDS    OEF_FIELDS
SET
    OEF_FIELDS.DEFAULT_VALUE = "8,14,16,12,17,2,3,21,18,5,4,13,6,11,15,7,1,9,10,20,19" ; EDIT THIS!
    , OEF_FIELDS.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
    , OEF_FIELDS.UPDT_ID = REQINFO->UPDT_ID
    , OEF_FIELDS.UPDT_CNT = OEF_FIELDS.UPDT_CNT + 1
WHERE
    OEF_FIELDS.OE_FORMAT_ID = __OE_FORMAT_ID__ ; EDIT THIS! F8
    AND OEF_FIELDS.ACTION_TYPE_CD = __ACTION_TYPE_CD__ ; EDIT THIS! F8
    AND OEF_FIELDS.OE_FIELD_ID = __OE_FIELD_ID__ ; EDIT THIS! F8
;----------------------------------------------------------------------------------------------------------------------
