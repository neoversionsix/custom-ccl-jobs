SELECT
    CONSULTANT = CE.RESULT_VAL ; THIS PULLS WHAT THE DR PUT IN THE FIELD
    , *
    
FROM
CLINICAL_EVENT CE

WHERE
    CE.PERSON_ID = 14126208 ; PERSONS ID GOES HERE
    AND
    CE.EVENT_CD = 134666758 ; EVENT_CD FOR THE FIELD GOES HERE, THIS ONE IS THE 'CONSULTANT' IN B2031
    AND
    CE.VIEW_LEVEL = 1 ; Make sure the data should be viewable, eg, not just for grouping


/*
Consultant	134666758
Clinical Notes	134666765
Imaging	134666811
Pathology	134666827
MDM Question	134666841
MDM Date	134666881
Pre-op/Post-op Discussion	134666895
Clinic Appointment/Follow Up Planned	134666935
Scopes	134667119
Relevant Bloods	134666954
Cancer MDM or Surgical Meeting	134666960

 */