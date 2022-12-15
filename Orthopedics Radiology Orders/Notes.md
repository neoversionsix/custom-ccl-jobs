rad orders for Ann

What we want is a list of
- Display ALL Patients with a scheduled OPE outpatient encounter within [prompt date range] with clinical specialty as Orthopaedics
- and IF they have Rad ordered in the OPE encounter - display the Rad order mnemonic and order comments
- OR if they have any Rad ordered in any encounter in the last 6 months, display the rad order mnemonic and order comments

Report name:
Orthopaedics - Appointments and Radiology Orders

Description:
Displays all Orthopaedics outpatient appointments specified time range. Radiology orders ordered in the last 6 months (from today) for each patient.


# Columns
- URN
- Full Name
- Encounter No.
- Clinic Appt
- Ordering Dr
- Ordered Date
- Rad Order

Use arrive_dt_tm on the encounter table to filter scheduled appointments