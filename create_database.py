import sys
sys.path.append("C:/Users/vince/Dropbox/My Projects")

import sqlify

# Load Census Data
census_tbl = sqlify.csv_to_table('data/DEC_10_DP_DPDP1_with_ann.csv',
                  name='census2010', skip_lines=2, header=True, p_key=1)                          
census_tbl.col_names[1] = 'GEOID'

'''
 * HD01_S001 (population counts) sometimes have 'r(some number)' to indicate the original count was revised
 * We want to remove this
'''

def remove_revision(entry):
    return entry.split('(')[0]
    
census_tbl['HD01_S001'].apply(remove_revision)

sqlify.table_to_sql(census_tbl, 'census2010.db')

# Load geographic data
places_tbl = sqlify.text_to_table('data/2016_Gaz_place_national.txt',
                   name='places', delimiter='\t', header=True, p_key=1)
                   
# Fix issues caused by extra whitespace
places_tbl.col_names[-1] = places_tbl.col_names[-1].replace(' ', '')
                   
places_tbl['ALAND_SQMI'].apply(sqlify.utils.strip_whitespace)
places_tbl['AWATER_SQMI'].apply(sqlify.utils.strip_whitespace)
places_tbl['INTPTLAT'].apply(sqlify.utils.strip_whitespace)
places_tbl['INTPTLONG'].apply(sqlify.utils.strip_whitespace)

# Previously 'TEXT'
places_tbl.col_types = places_tbl.guess_type()

# Load to SQL
sqlify.table_to_sql(places_tbl, 'census2010.db')