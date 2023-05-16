import pandas as pd
import os

# Define chunksize
chunksize = 10 ** 6  # adjust this value depending on your available memory

# Function to convert time to hour
def convert_time_to_hour(time):
    try:
        return int(time.replace(" ", "").split(':')[0])
    except Exception:
        return None

# Loop through the chunks and write each filtered chunk to the new CSV file
for chunk in pd.read_csv('ORDER_ACTION.csv', chunksize=chunksize):
    # Remove spaces from 'DT_TIME' and extract the hour
    chunk['DT_TIME'] = chunk['DT_TIME'].apply(convert_time_to_hour)

    # Filter rows where 'DT_TIME' is between 15 (3pm) and 23 (11pm), and not None
    filtered_chunk = chunk[(chunk['DT_TIME'] >= 15) & (chunk['DT_TIME'] < 23) & (chunk['DT_TIME'].notna())]

    # If the file does not exist, write with a header, else skip the header
    if not os.path.isfile('filtered.csv'):
        filtered_chunk.to_csv('filtered.csv', index=False)
    else:  # else it exists so append without writing the header
        filtered_chunk.to_csv('filtered.csv', mode='a', header=False, index=False)
