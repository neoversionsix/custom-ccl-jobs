# Path for input data
path = 'input.xlsx'
input_data = pd.read_excel(path, dtype= 'str' ) # Read data

# Output code location
outfilp = r'C:\Users\\whittlj2\\'

# filetype for output code
filetype = '.txt'

# CCL Code
ccl_code = [
'; CREDENTIAL MOVE SCRIPT'
, 'update into credential cred'
, 'set cred.prsnl_id = (select person_id from prsnl where username = "SWAPME_1")'
, ', cred.credential_cd = (select code_value from code_value where code_set = 29600 and display = "SWAPME_2")'
, ', cred.credential_type_cd = 686580 ; License from code set 254874'
, ', cred.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)'
, ', cred.active_ind = 1'
, ', cred.active_status_dt_tm = cnvtdatetime(curdate,curtime3)'
, ', cred.active_status_cd = 188 ; Active from code set 48'
, ', cred.updt_dt_tm = cnvtdatetime(curdate,curtime3)'
, ', cred.updt_id = reqinfo->updt_id'
, ', cred.updt_cnt = cred.updt_cnt + 1'
, 'where cred.credential_id  = ('
, 'select min(credential_id)'
, 'from credential'
, 'where prsnl_id = 13876656 ; Credential Box user in prod or cert'
, ')'
, 'and not exists ('
, 'select 1'
, 'from credential'
, 'where prsnl_id = (select person_id from prsnl where username = "SWAPME_1")'
, 'and credential_cd = (select code_value from code_value where code_set = 29600 and display = "SWAPME_2")'
, 'and active_ind = 1'
, ')'
, ''
, '; DIRECTORY IND SCRIPT'
, 'update into ea_user eau'
, 'set'
, 'eau.directory_ind = 1'
, ',eau.updt_dt_tm = cnvtdatetime(curdate,curtime3)'
, ',eau.updt_id = reqinfo->updt_id'
, ',eau.updt_cnt = eau.updt_cnt + 1'
, 'where eau.username = "SWAPME_1"'
]

# Create unique filname with current date-time
outputfilename = '-UPDATE-CODE'
datetime_str = str(datetime.datetime.now())
datetime_str = datetime_str.replace('.', '_')
datetime_str = datetime_str.replace(':', '-')
outputfilename = outfilp + datetime_str + outputfilename + filetype
outputfilename = str(outputfilename)

# WRITE CODE TO TXT FILE
for index, row in input_data.iterrows():
    # Column that has the usernames to put in the code. The next two lines need adjusting
    to_switch_1 = str(row['USERNAME'].upper())
    to_switch_2 = str(row['CREDENTIAL'])
    #Write to file
    for a_row in ccl_code:
        # Only generate code where a credential is filled out
        if to_switch_2 != 'nan':
            # REPLACE SWAPME_1 with the username in each row of the code slab. The next two lines need adjusting
            new_row = a_row.replace('SWAPME_1', to_switch_1)
            new_row_2 = new_row.replace('SWAPME_2', to_switch_2)
            f = open(outputfilename, "a")
            f.write(new_row_2 + '\n')
f.close()