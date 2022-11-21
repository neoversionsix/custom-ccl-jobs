rad orders for Ann

What we want is a list of
- Display ALL Patients with a scheduled OPE outpatient encounter within [prompt date range] with clinical specialty as Orthopaedics
- and IF they have Rad ordered in the OPE encounter - display the Rad order mnemonic and order comments
- OR if they have any Rad ordered in any encounter in the last 6 months, display the rad order mnemonic and order comments



# Columns
- URN
- Full Name
- Encounter No.
- Clinic Appt
- Ordering Dr
- Ordered Date
- Rad Order

Use arrive_dt_tm on the encounter table to filter scheduled appointments