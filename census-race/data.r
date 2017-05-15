library(dplyr)

# A class for storing and manipulating data relating to one race/ethnicity
RaceData <- setRefClass(
  "RaceData",
  fields = c('sql_conn', 'town_data', 'county_data'),
  methods = list(
    initialize = function(sql_conn, counties, pop_col1, pop_col2) {
      # Arguments:
      #  * sql_conn:  A dplyr PostgreSQL connection
      #   * Should be a connection to the database with all Census tables
      #  * pop_col1:  Name of the column containing population data for a race (town)
      #  * pop_col2:  Same as above but for cunties
      #  * counties:  A GeoJSON with county boundary information
      
      sql_conn <<- sql_conn
      town_data <<- get_town_data(sql_conn, pop_col1)
      county_data <<- left_join(counties@data,
                                get_county_data(sql_conn, pop_col2),
                                by='geo_id')
      
    },
    
    # Get largest absolute populations of X race
    get_town_top_n = function(n=25) {
      return(collect(
        .self$town_data %>%
          arrange(desc(race_pop))) %>%
          slice(1:n)
        )
    }
))

# Get data for the race/ethnicity and join it with geographical information
get_town_data = function(sql_conn, pop_col) {
  # Arguments:
  #  * pop_col: Name of the column containing population data for a race
  
  sql_query = sprintf(
    "SELECT
          geo_display_label AS town,
          CAST(hd01_s001 AS INTEGER) AS total_pop,
          CAST(%s AS INTEGER) as race_pop,
          CAST(%s AS FLOAT8)/CAST(hd01_s001 AS FLOAT8) AS race_percent,
          CAST(intptlat AS FLOAT8) AS latitude,
          CAST(intptlong AS FLOAT8) AS longitude 
         FROM population JOIN geography
          ON geography.geoid = population.geoid
         WHERE CAST(hd01_s001 AS INTEGER) > 0",
    pop_col, pop_col)
  
  return(tbl(sql_conn, sql(sql_query)))
}

# Get county data
get_county_data = function(sql_conn, pop_col) {
  sql_query = sprintf(
    "SELECT
      geo_id,
      geo_display_label AS county_name,
      CAST(hd01_vd01 AS INTEGER) AS total_pop,
      CAST(%s AS INTEGER) as race_pop,
      CAST(%s AS FLOAT8)/CAST(hd01_vd01 AS FLOAT8) as race_percent
     FROM acs15_race_county",
    pop_col, pop_col)
  
  data <- collect(tbl(sql_conn, sql(sql_query)))
  
  return(data)
}