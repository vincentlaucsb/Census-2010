library(leaflet)
library(geojsonio)
library(rgdal)
library(dplyr)

counties <- geojsonio::geojson_read("data/geography/gz_2010_us_050_00_20m.json",
                                    what = "sp")

# Get helper functions
source('util.r')

# ==== Connect to Postgres ====
source('postgres_pw.r')
census2010_db <- src_postgres("census2010", user=postgres_user, password=password)

# Notes:
#  - Postgres lowercases column names
#  - Needs work-arounds until I properly type-cast the columns


# ==== Get City/Town Data ====
census2010_town <- tbl(census2010_db, "population")

# Total Population: hd01_s001
# Black Population:
#  - hd01_s079 (Black Alone)
#  - hd01_s098 (Black + White)
#  - Other combinations not counted

black_town <- tbl(census2010_db, sql(
  "SELECT
    geo_display_label AS town,
    CAST(hd01_s001 AS INTEGER) AS total_pop,
    CAST(hd01_s079 AS INTEGER) as black_pop,
    CAST(hd01_s079 AS FLOAT8)/CAST(hd01_s001 AS FLOAT8) AS black_percent,
    CAST(intptlat AS FLOAT8) AS latitude,
    CAST(intptlong AS FLOAT8) AS longitude 
   FROM population JOIN geography
    ON geography.geoid = population.geoid
   WHERE CAST(hd01_s001 AS INTEGER) > 0"
))

# Get 25 largest populations of blacks by town
black_town.top_pop <- collect(
  black_town %>%
    arrange(desc(black_pop))) %>%
  slice(1:25)

# ==== Get County Data ====
acs15_race_county <- collect(
  tbl(census2010_db, "acs15_race_county")
)

names(acs15_race_county)[1] = "GEO_ID"

geog_demo_data <- left_join(counties@data, acs15_race_county, by='GEO_ID')

# Type-cast to integer
geog_demo_data <- geog_demo_data %>%
  mutate(hd01_vd01 = as.numeric(hd01_vd01)) %>%
  mutate(hd01_vd04 = as.numeric(hd01_vd04)) %>%
  # mutate(hd01_vd14 = as.numeric(hd01_vd04)) %>%
  # mutate(hd01_vd17 = as.numeric(hd01_vd17)) %>%
  
  # Black Population: hd01_vd04
  mutate(black_pop = hd01_vd04) %>%
  mutate(black_percent = black_pop/hd01_vd01)

pal = colorQuantile(
  # palette=c("#f7fcfd", "#e0ecf4", "#bfd3e6", "#9ebcda",
  #          "#8c96c6", "#8c6bb1", "#88419d", "#6e016b"),
  palette=c("#ffffd9", "#edf8b1", "#c7e9b4", "#7fcdbb",
            "#41b6c4", "#1d91c0", "#225ea8", "#0c2c84"),
  domain=as.numeric(geog_demo_data$black_percent),
  n=6)


get_label <- function(data, n) {
  # n:  Number of bins data was separated into
  
  # Get the breaks that colorQuantile uses
  # quantile(geog_demo_data$black_percent,
  #          probs = seq(0, 1, length.out = 9), na.rm=TRUE)  
  breaks <- quantile(data, probs = seq(0, 1, length.out = n + 1),
                     na.rm=TRUE)
  
  labels <- c()
  
  for (i in 1:n) {
    labels <- append(labels,
                     paste0(round(breaks[i], 3) * 100, "%",
                            " - ",
                            round(breaks[i + 1], 3) * 100, "%")
    )
  }
  
  return(labels)
}

m <- leaflet(counties) %>%
  addPolygons(
    color = ~pal(geog_demo_data$black_percent),
    weight = 1,
    opacity = 1,
    fillOpacity = 0.6,
    
    # Demographic Information
    label = paste("<b>", geog_demo_data$geo_display_label, "</b><br />",
                  "Population: ", geog_demo_data$hd01_vd01, "<br />",
                  "Black Population: ", geog_demo_data$black_pop,
                  " (", round(geog_demo_data$black_percent * 100, digits=2), "%)"
    )) %>%
  
  addMarkers(
    lat = black_town.top_pop$latitude,
    lng = black_town.top_pop$longitude,
    label = black_town.top_pop$town,
    popup = paste0(
      "<b>", black_town.top_pop$town, "</b><br />",
      "Population: ", black_town.top_pop$total_pop, "<br />",
      "Black Population: ", black_town.top_pop$black_pop,
        " (", round(black_town.top_pop$black_percent * 100, digits=2), "%)"
      )
  ) %>%
  
  addLegend(
    title = "Percent Black",
    
    # Works but generates percentiles instead of actual values
    # pal = pal,
    # values = ~geog_demo_data$black_percent,
    
    colors=c("#ffffcc", "#c7e9b4", "#7fcdbb",
             "#41b6c4", "#2c7fb8", "#253494"),
    
    # colors=c("#ffffd9", "#edf8b1", "#c7e9b4", "#7fcdbb",
    #                  "#41b6c4", "#1d91c0", "#225ea8", "#0c2c84"),
    labels=get_label(data=geog_demo_data$black_percent, n=6),
    opacity = 1) %>%
  
  addTiles()

# Print out the map
m