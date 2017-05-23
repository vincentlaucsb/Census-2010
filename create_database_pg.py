import sys
sys.path.append("C:/Users/vince/Dropbox/My Projects")

import sqlify

# ==== Load CPI Data ====
# sqlify.text_to_pg('data/cpi/cu.data.1.AllItems.txt', delimiter='\t',
                  # database='census2010', name='cpi', header=0)

# ==== Load Census Data ====
# sqlify.csv_to_pg('data/population/DEC_10_DP_DPDP1_with_ann.csv',
                  # database='census2010', 
                  # name='population',
                  # col_rename={'GEO.id2': 'GEOID'},
                  # skip_lines=2,
                  # header=0,
                  # p_key=1,
                  # na_values=' ( X ) ')

# # Load geographic data (for places)
# # Note: Text loader fails to delete header row for some reason
# sqlify.text_to_pg('data/geography/2016_Gaz_place_national.txt',
                   # database='census2010', name='geography', delimiter='\t',
                   # header=0, p_key=1)

# # Load geographic data (for counties)
# sqlify.text_to_pg('data/geography/2016_Gaz_counties_national.txt',
                    # database='census2010', name='geography_county',
                    # delimiter='\t', header=0, p_key = 1)

# # Load median household income data (by city)
# sqlify.csv_to_pg(
    # 'data/median-household-income/ACS_15_5YR_GCT1901.US13PR.csv',
    # database='census2010',
    # name="median_household_income",
    # col_rename={'GCT_STUB.target-geo-id2': 'GEOID',
                # 'GCT_STUB.display-label': 'LOCATION'},
    # header = 0,
    # skip_lines = 3,
    # p_key = 4)

# # # Not that useful: Can't load -- too wide
# # sqlify.csv_to_pg(
    # # 'data/acs15-pop-county/ACS_15_1YR_S0201_with_ann.csv',
    # # database='census2010',
    # # name="acs15_pop_county",
    # # col_rename={'GEO.id2': 'GEOID'},
    # # header=0,
    # # skip_lines=2,
    # # p_key=None)
    
# # Load detailed race data by county
# sqlify.csv_to_pg(
    # 'data/acs15-race-county/ACS_15_5YR_C02003.csv',
    # database='census2010',
    # name="acs15_race_county",
    # col_rename={'GEO.id2': 'GEOID'},
    # header=0,
    # skip_lines=2,
    # p_key=1)
    
# # Load Zillow Data
# sqlify.csv_to_pg(
    # 'data/zillow/City_MedianSoldPricePerSqft_SingleFamilyResidence.csv',
    # database='census2010',
    # name='city_median_soldpricepersqft_singlefamily',
    # p_key=0,
    # header=0)
    
# # State abbreviations
# sqlify.csv_to_pg(
    # 'data/geography/states.csv',
    # database='census2010',
    # name='state_abbrev',
    # header=0
# )

# # ==== Load ACS Financial Data ====
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_05_EST_S2503_with_ann.csv',
    # database='census2010', name='acs05_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_06_EST_S2503_with_ann.csv',
    # database='census2010', name='acs06_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_07_1YR_S2503_with_ann.csv',
    # database='census2010', name='acs07_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_07_3YR_S2503_with_ann.csv',
    # database='census2010', name='acs07_3yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_08_1YR_S2503_with_ann.csv',
    # database='census2010', name='acs08_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_08_3YR_S2503_with_ann.csv',
    # database='census2010', name='acs08_3yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_09_1YR_S2503_with_ann.csv',
    # database='census2010', name='acs09_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_09_3YR_S2503_with_ann.csv',
    # database='census2010', name='acs09_3yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_09_5YR_S2503_with_ann.csv',
    # database='census2010', name='acs09_5yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_10_1YR_S2503_with_ann.csv',
    # database='census2010', name='acs10_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_10_3YR_S2503_with_ann.csv',
    # database='census2010', name='acs10_3yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_10_5YR_S2503_with_ann.csv',
    # database='census2010', name='acs10_5yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_11_1YR_S2503_with_ann.csv',
    # database='census2010', name='acs11_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_11_3YR_S2503_with_ann.csv',
    # database='census2010', name='acs11_3yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_12_1YR_S2503_with_ann.csv',
    # database='census2010', name='acs12_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_12_3YR_S2503_with_ann.csv',
    # database='census2010', name='acs12_3yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_12_5YR_S2503_with_ann.csv',
    # database='census2010', name='acs12_5yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_13_1YR_S2503_with_ann.csv',
    # database='census2010', name='acs13_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_13_3YR_S2503_with_ann.csv',
    # database='census2010', name='acs13_3yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_13_5YR_S2503_with_ann.csv',
    # database='census2010', name='acs13_5yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_14_1YR_S2503_with_ann.csv',
    # database='census2010', name='acs14_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_14_5YR_S2503_with_ann.csv',
    # database='census2010', name='acs14_5yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_15_1YR_S2503_with_ann.csv',
    # database='census2010', name='acs15_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# sqlify.csv_to_pg(
    # 'data/acs-finance-county/ACS_15_5YR_S2503_with_ann.csv',
    # database='census2010', name='acs15_5yr_finance_county', header=0,
    # skip_lines=2, na_values="(X)")
    
# ==== Load ACS Race Data ====
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_05_EST_C02003_with_ann.csv',
    # database='census2010', name='acs05_race_county', header=0,
    # skip_lines=2)

# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_06_EST_C02003_with_ann.csv',
    # database='census2010', name='acs06_race_county', header=0,
    # skip_lines=2)

# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_07_1YR_C02003_with_ann.csv',
    # database='census2010', name='acs07_race_county', header=0,
    # skip_lines=2)

# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_07_3YR_C02003_with_ann.csv',
    # database='census2010', name='acs07_3yr_race_county', header=0,
    # skip_lines=2
# )

# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_08_1YR_C02003_with_ann.csv',
    # database='census2010', name='acs08_race_county', header=0,
    # skip_lines=2)

# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_08_3YR_C02003_with_ann.csv',
    # database='census2010', name='acs08_3yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_09_1YR_C02003_with_ann.csv',
    # database='census2010', name='acs09_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_09_3YR_C02003_with_ann.csv',
    # database='census2010', name='acs09_3yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_09_5YR_C02003_with_ann.csv',
    # database='census2010', name='acs09_5yr_race_county', header=0,
    # skip_lines=2)

# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_10_1YR_C02003_with_ann.csv',
    # database='census2010', name='acs10_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_10_3YR_C02003_with_ann.csv',
    # database='census2010', name='acs10_3yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_10_5YR_C02003_with_ann.csv',
    # database='census2010', name='acs10_5yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_11_1YR_C02003_with_ann.csv',
    # database='census2010', name='acs11_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_11_3YR_C02003_with_ann.csv',
    # database='census2010', name='acs11_3yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_11_5YR_C02003_with_ann.csv',
    # database='census2010', name='acs11_5yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_12_1YR_C02003_with_ann.csv',
    # database='census2010', name='acs12_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_12_3YR_C02003_with_ann.csv',
    # database='census2010', name='acs12_3yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_12_5YR_C02003_with_ann.csv',
    # database='census2010', name='acs12_5yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_13_1YR_C02003_with_ann.csv',
    # database='census2010', name='acs13yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_13_3YR_C02003_with_ann.csv',
    # database='census2010', name='acs13_3yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_13_5YR_C02003_with_ann.csv',
    # database='census2010', name='acs13_5yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_14_1YR_C02003_with_ann.csv',
    # database='census2010', name='acs14_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_14_5YR_C02003_with_ann.csv',
    # database='census2010', name='acs14_5yr_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_15_1YR_C02003_with_ann.csv',
    # database='census2010', name='acs15_race_county', header=0,
    # skip_lines=2)
    
# sqlify.csv_to_pg(
    # 'data/acs-race-county/ACS_15_5YR_C02003_with_ann.csv',
    # database='census2010', name='acs15_5yr_race_county', header=0,
    # skip_lines=2)