# This block by itself launches a blank page
library(leaflet)
library(geojsonio)
library(ggplot2)

# Get working directory
source('wd.r')
setwd(working_dir)

# Get helper functions
source('util.r')
source('census-race/data.r')

# ==== Connect to Postgres ====
source('postgres_pw.r')
census2010_db <- src_postgres("census2010",
                              user=postgres_user,
                              password=password,
                              host="localhost")

# Notes:
#  - Postgres lowercases column names
#  - Needs work-arounds until I properly type-cast the columns

# ==== Get County Data ====
counties <- geojsonio::geojson_read("data/geography/gz_2010_us_050_00_20m.json",
                                    what = "sp")

# Lowercase names
names(counties@data) = tolower(names(counties@data))

# ==== Get City/Town Data ====
census2010_town <- tbl(census2010_db, "population")

# Total Population: hd01_s001
# Black Population:
#  - hd01_s079 (Black Alone)
#  - hd01_s098 (Black + White)
#  - Other combinations not differentiated

whites <- new('RaceData', sql_conn=census2010_db, counties=counties,
               pop_col1='hd01_s078', pop_col2='hd01_vd03')

blacks <- new('RaceData', sql_conn=census2010_db, counties=counties,
              pop_col1='hd01_s079', pop_col2='hd01_vd04')

asians <- new('RaceData', sql_conn=census2010_db, counties=counties,
              pop_col1='hd01_s081', pop_col2='hd01_vd06')

# hispanics <- new('RaceData', sql_conn=census2010_db, counties=counties,
#               pop_col1='hd01_s107', pop_col2='hd01_vd06')

# ==== Create a Map ====
create_map <- function(data, top_pop, race) {
  # Arguments
  #  * data:    A data frame with geographic boundaries and demographic information
  #  * top_pop: A data frame with information of the top n populations for X
  #  * race:    Name of the race/ethnicity
  
  map.colors <- c("#ffffcc", "#c7e9b4", "#7fcdbb",
                 "#41b6c4", "#2c7fb8", "#253494")
  
  pal = colorQuantile(
    palette=map.colors,
    domain=as.numeric(data$race_percent),
    n=6)
  
  map <- leaflet(counties) %>%
    addTiles() %>%
    
    addPolygons(
      color = ~pal(data$race_percent),
      weight = 1,
      opacity = 1,
      fillOpacity = 0.6 #,
      # Demographic Information
      # label = paste("<b>", data$county_name, "</b><br />",
      #               "Population: ", data$total_pop, "<br />",
      #               paste(race, "Population: "), data$race_pop,
      #               " (", round(data$race_percent * 100, digits=2), "%)"
      #)
    ) %>%

    addMarkers(
      lat = top_pop$latitude,
      lng = top_pop$longitude,
      label = top_pop$town,
      popup = paste0(
        "<b>", top_pop$town, "</b><br />",
        "Population: ", top_pop$total_pop, "<br />",
        paste(race, "Population: "), top_pop$race_pop,
        " (", round(top_pop$race_percent * 100, digits=2), "%)"
      )
    ) %>%

    addLegend(
      title = paste("Percent", race),
      # Works but generates percentiles instead of actual values
      # pal = pal,
      # values = ~data$race_percent,
      colors = map.colors,
      labels = get_label(data=data$race_percent, n=6, output='percent'),
      opacity = 1)

  # Print out the map
  return(map)
}

# ==== Leaflet Map ====
whites_map <- create_map(race = "White", data = whites$county_data,
                         top_pop = whites$get_town_top_n())

blacks_map <- create_map(race = "Black", data = blacks$county_data,
                         top_pop = blacks$get_town_top_n())

asians_map <- create_map(race = "Asian", data = asians$county_data,
                         top_pop = asians$get_town_top_n())

# hispanics_map <- create_map(race = "Hispanic", data = hispanics$county_data,
#                         top_pop = hispanics$get_town_top_n())

# ==== Data Table ====
all_races.towns <- collect(
  tbl(census2010_db, sql(
    "SELECT (city || ', ' || state) as town,
      CAST(hd01_s001 AS INTEGER) AS total_pop,
      CAST(hd01_s078 AS INTEGER) as white_pop,
      CAST(hd01_s078 AS FLOAT8)/CAST(hd01_s001 AS FLOAT8) AS white_pct,
      CAST(hd01_s079 AS INTEGER) as black_pop,
      CAST(hd01_s079 AS FLOAT8)/CAST(hd01_s001 AS FLOAT8) AS black_pct,
      CAST(hd01_s081 AS INTEGER) as asian_pop,
      CAST(hd01_s081 AS FLOAT8)/CAST(hd01_s001 AS FLOAT8) AS asian_pct
     FROM population JOIN clean_place_names
      ON population.geoid = clean_place_names.geoid
     WHERE CAST(hd01_s001 AS INTEGER) > 0"
  ))
) %>%
  mutate(white_pct = round(white_pct * 100, 2)) %>%
  mutate(black_pct = round(black_pct * 100, 2)) %>%
  mutate(asian_pct = round(asian_pct * 100, 2))

names(all_races.towns) = c("Town", "Total Population", "Whites", "% White",
                           "Blacks", "% Black", "Asians", "% Asian")

all_races.county <- collect(
  tbl(census2010_db, sql(
    "SELECT
      geo_display_label as county,
      CAST(hd01_vd01 as int) as total_pop,
      CAST(hd01_vd03 as int) as white_pop,
      CAST(hd01_vd03 as float8)/CAST(hd01_vd01 as float8) as white_pct,
      CAST(hd01_vd04 as int) as black_pop,
      CAST(hd01_vd04 as float8)/CAST(hd01_vd01 as float8) as black_pct,
      CAST(hd01_vd06 as int) as asian_pop,
      CAST(hd01_vd06 as float8)/CAST(hd01_vd01 as float8) as asian_pct
     FROM acs15_race_county"))
) %>%
  mutate(white_pct = round(white_pct * 100, 2)) %>%
  mutate(black_pct = round(black_pct * 100, 2)) %>%
  mutate(asian_pct = round(asian_pct * 100, 2))

names(all_races.county) = c("County", "Total Population", "White Population",
                            "% White", "Black Population", "% Black",
                            "Asian Population", "% Asian")