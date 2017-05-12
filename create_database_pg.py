import sys
sys.path.append("C:/Users/vince/Dropbox/My Projects")

import sqlify

# ==== Load Census Data ====
# sqlify.csv_to_sql('data/population/DEC_10_DP_DPDP1_with_ann.csv',
                  # database='census2010', 
                  # name='population',
                  # col_rename={'GEO.id2': 'GEOID'},
                  # skip_lines=2,
                  # header=0,
                  # p_key=1,
                  # engine='postgres')          

# Load geographic data (for places)
# Note: Text loader fails to delete header row for some reason
# sqlify.text_to_sql('data/geography/2016_Gaz_place_national.txt',
                   # database='census2010',
                   # name='geography', delimiter='\t', header=0, p_key=1,
                   # engine='postgres')                   

# Load geographic data (for counties)
# sqlify.text_to_sql('data/geography/2016_Gaz_counties_national.txt',
                    # database='census2010', name='geography_county',
                    # delimiter='\t', header=0, p_key = 1, engine='postgres')

# Load median household income data
# sqlify.csv_to_sql(
    # 'data/median-household-income/ACS_15_5YR_GCT1901.US13PR.csv',
    # database='census2010',
    # name="median_household_income",
    # col_rename={'GCT_STUB.target-geo-id2': 'GEOID',
                # 'GCT_STUB.display-label': 'LOCATION'},
    # header = 0,
    # skip_lines = 3,
    # p_key = 4,
    # engine='postgres'
# )

# Not that useful
# sqlify.csv_to_sql(
    # 'data/acs15-pop-county/ACS_15_1YR_S0201_with_ann.csv',
    # database='census2010',
    # name="acs15_pop_county",
    # col_rename={'GEO.id2': 'GEOID'},
    # header=0,
    # skip_lines=2,
    # p_key=None)
    
# Load detailed race data by county
# sqlify.csv_to_sql(
    # 'data/acs15-race-county/ACS_15_5YR_C02003.csv',
    # database='census2010',
    # name="acs15_race_county",
    # col_rename={'GEO.id2': 'GEOID'},
    # header=0,
    # skip_lines=2,
    # p_key=1,
    # engine='postgres')

# Load county detailed financial data
sqlify.csv_to_sql(
    'data/acs15-finance-county/ACS_15_5YR_S2503_with_ann.csv',
    database='census2010',
    delimiter=',',
    name="acs15_finance_county",
    col_rename={'GEO.id2': 'GEOID'},
    header=0,
    skip_lines=2,
    p_key=1,
    na_values="(X)",
    engine='postgres')