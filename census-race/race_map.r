library(leaflet)
library(geojsonio)
library(dplyr)

counties <- geojsonio::geojson_read("data/geography/gz_2010_us_050_00_20m.json",
                                    what = "sp")

# Get helper functions
source('util.r')
source('race/data.r')

# ==== Connect to Postgres ====
source('postgres_pw.r')
census2010_db <- src_postgres("census2010", user=postgres_user, password=password)

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

niggas <- new('RaceData', sql_conn=census2010_db, counties=counties,
              pop_col1='hd01_s079', pop_col2='hd01_vd04')
top_pop <- niggas$get_town_top_n()
niggas_in_counties <- niggas$county_data

# ==== Get County Data ====
# Black Population: 

# ==== Create a Map ====
create_map <- function(data, top_pop) {
  # Arguments
  #  * data:    A data frame with geographic boundaries and demographic information
  #  * top_pop: A data frame with information of the top n populations for X
  
  map.colors <- c("#ffffcc", "#c7e9b4", "#7fcdbb",
                  "#41b6c4", "#2c7fb8", "#253494")
  
  pal = colorQuantile(
    palette=map.colors,
    domain=as.numeric(data$race_percent),
    n=6)
  
  map <- leaflet(counties) %>%
    addPolygons(
      color = ~pal(data$race_percent),
      weight = 1,
      opacity = 1,
      fillOpacity = 0.6
      
      # Demographic Information
      # label = paste("<b>", data$county_name, "</b><br />",
      #               "Population: ", data$hd01_vd01, "<br />",
      #               "Black Population: ", data$race_pop,
      #               " (", round(data$race_percent * 100, digits=2), "%)"
      # ))
      ) %>%
    
    addMarkers(
      lat = top_pop$latitude,
      lng = top_pop$longitude,
      label = top_pop$town,
      popup = paste0(
        "<b>", top_pop$town, "</b><br />",
        "Population: ", top_pop$total_pop, "<br />",
        "Black Population: ", top_pop$race_pop,
          " (", round(top_pop$race_percent * 100, digits=2), "%)"
        )
    ) %>%
    
    addLegend(
      title = "Percent Black",
      # Works but generates percentiles instead of actual values
      # pal = pal,
      # values = ~data$race_percent,
      colors = map.colors,
      labels = get_label(data=data$race_percent, n=6, output='percent'),
      opacity = 1) %>%
    
    addTiles()
  
  # Print out the map
  return(map)
}

create_map(data = niggas_in_counties, top_pop = top_pop)