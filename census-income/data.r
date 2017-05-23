library(dplyr)

# Not Needed: Use PostgreSQL version instead
# # Gets inflation-adjusted numbers
# InflationCalculator <- setRefClass(
#   "InflationCalculator",
#   fields = c('cpi_data'),
#   methods = list(
#     initialize = function(sql_conn) {
#       # Arguments:
#       #  * sql_conn:  A dplyr PostgreSQL connection
#       cpi_data <<- collect(
#         tbl(sql_conn, sql(
#         "SELECT year, CAST(value  as float8) FROM cpi
#          WHERE series_id LIKE '%CUUR0000AA0%'
#          AND period LIKE '%M13%'"))
#      )
#    },
#    
#    inflate = function(money, start_year, end_year) {
#      # Arguments:
#      #  * money:        Dollar amount to be inflation adjusted
#      #  * start_year:   The year money is calculated from
#      #  * end_year:     The year money should be converted to
#      
#      start_cpi <- as.numeric(.self$cpi_data %>%
#                                filter(year==start_year) %>%
#                                select(value))
#      
#      end_cpi <- as.numeric(.self$cpi_data %>%
#                                filter(year==end_year) %>%
#                                select(value))
#      
#      inflation = end_cpi/start_cpi
#      
#      return(money * inflation)
#    }
#  )
# )

# Lazy loads median household income data for county
IncomeData <- setRefClass(
  "IncomeData",
  fields = c('sql_conn', 'county_data'),
  methods = list(
    initialize = function(sql_conn, counties, query) {
      # Arguments:
      #  * sql_conn:  A dplyr PostgreSQL connection
      #   * Should be a connection to the database with all Census tables
      #  * counties:  A GeoJSON with county boundary information
      #  * query:     A SQL string containing an SQL query which gets the data
      
      sql_conn <<- sql_conn
      county_data <<- left_join(counties@data,
                                collect(tbl(sql_conn, sql(query()))),
                                by='geo_id')
    },
    
    get_mhhi_data = function(year) {
      # Return a subset of median household income data for one year
      #  * year:  Should be in two digit format e.g. '05', '12', ...
      #  * top:   Get top N entries
      
      # Get integer position of correct column
      col_name = sprintf('mhhi_%s', year)
      col_pos = which(names(.self$county_data) == col_name)
      
      return(unlist(.self$county_data %>%
                      select(col_pos)))
    },
    
    get_top_mhhi = function(year) {
      # Get top 100 counties by median household income
      # along with geographic information
      
      # Get integer position of correct column
      col_name = sprintf('mhhi_%s', year)
      col_pos = which(names(.self$county_data) == col_name)
      
      # browser()
      data <- .self$county_data %>%
        select(geo_display_label, lat, long, col_pos) %>%
        
        # Strip out excessive whitespace
        mutate(lat = as.numeric(lat)) %>%
        mutate(long = as.numeric(long))
      
      # Rename median household income column
      names(data)[4] = "mhhi"
      
      return((data %>%
        arrange(desc(mhhi)))[1:100, ])
    }
  )
)

# Generate SQL query that gets median household income time series data
# Use writeLines(get_mhhi_ts_query()) to test output
get_mhhi_ts_query = function() {
  columns_temp <- c()
  joins_temp <- c()
  
  k <- 1
  
  # Count backwards because ACS 15 has more counties
  for (i in seq(15, 5)) {
    # 5 -> 2005, 13 -> 2013, ...
    four_digit_year <- 2000 + i
    
    # 5 -> 05, 6 -> 06, ...
    if (nchar(i) == 1) { i <- sprintf('0%s', i) }
    
    columns_temp <- append(columns_temp, sprintf('mhhi_%s, mhhi_moe_%s', i, i))
    
    # Return inflation adjusted numbers
    joins_temp <- append(joins_temp, sprintf(
      "(SELECT geo_id, geo_id2, geo_display_label,
          inflate(float_or_null(hc01_est_vc14), %s, 2016) AS mhhi_%s,
          inflate(float_or_null(hc01_moe_vc14), %s, 2016) AS mhhi_moe_%s FROM acs%s_finance_county) as q%s",
        four_digit_year, # Inflation start year
        i,               # Get correct column name
        four_digit_year, # Inflation start year
        i, i, k)
      )

    k <- k + 1;
  }
  
  columns <- paste(columns_temp, collapse=', ')
  
  k <- 1
  
  for (j in joins_temp) {
    if (k == length(joins_temp)) {
      # Last item
      joins_temp[k] = sprintf('%s ON q1.geo_id = q%s.geo_id', j, k);
    } else if (k > 1) {
      # Not first item
      joins_temp[k] = sprintf('%s ON q1.geo_id = q%s.geo_id
                              FULL OUTER JOIN ', j, k)
    } else {
      # First Item
      joins_temp[k] = sprintf('%s
                              FULL OUTER JOIN', j)
    }
    k <- k + 1
  }
  
  joins <- paste(joins_temp, collapse='')
  
  return(sprintf('SELECT q1.geo_id, q1.geo_display_label,
                    intptlat as lat,
                    intptlong as long,
                 %s FROM %s
                 JOIN geography_county ON
                    geography_county.geoid = q1.geo_id2', columns, joins))
}

# Get ACS 5-Year Estimates of Financial Information
get_mhhi_acs5 = function() {
  return(
  'SELECT
      acs15_5yr_finance_county.geo_id,
      acs15_5yr_finance_county.geo_display_label,
      intptlat as lat,
      intptlong as long,
      inflate(float_or_null(acs15_5yr_finance_county.hc01_est_vc14), 2015, 2016) as mhhi_15,
      inflate(float_or_null(acs15_5yr_finance_county.hc01_moe_vc14), 2015, 2016) as mhhi_moe_15,
      inflate(float_or_null(acs10_5yr_finance_county.hc01_est_vc14), 2010, 2016) as mhhi_10,
      inflate(float_or_null(acs10_5yr_finance_county.hc01_moe_vc14), 2010, 2016) as mhhi_moe_10
    FROM
      acs15_5yr_finance_county
    JOIN
      acs10_5yr_finance_county
    ON acs10_5yr_finance_county.geo_id = acs15_5yr_finance_county.geo_id
    JOIN
      geography_county
    ON geography_county.geoid = acs15_5yr_finance_county.geo_id2'
    )
}