# This block by itself launches a blank page
library(leaflet)
library(geojsonio)
library(dplyr)
library(ggplot2)

# ==== Load Data ====
source('postgres_pw.r')

census2010_db <- src_postgres("census2010",
                              user=postgres_user,
                              password=password,
                              host="localhost")

med_hh_income.sql <- tbl(census2010_db, sql(
  "SELECT
  population.geoid,
  CAST(hd01_s001 AS integer) as population,
  location,
  hc01
  FROM median_household_income
  LEFT JOIN population
  ON population.geoid = median_household_income.geoid"))

# med_hh_income.sql <- tbl(census2010_db, "median_household_income")

# Remove missing values
med_hh_income <- collect(
  filter(med_hh_income.sql, !is.null(hc01)) %>%
    select(geoid, population, location, hc01) %>%
    mutate(hc01 = as.numeric(hc01)) %>%
    arrange(desc(hc01))
)

names(med_hh_income) = c("geoid", "Population", "Location", "Median Household Income")

# ==== Household income data by county ====
acs15_finance_county <- collect(
  tbl(census2010_db,
      sql("SELECT * FROM acs15_finance_county
          WHERE (hc01_est_vc14 IS NOT NULL)
          AND (hc01_est_vc14 NOT LIKE '%(X)%')")) %>%
    mutate(hc01_est_vc14 = as.numeric(hc01_est_vc14))
      )

names(acs15_finance_county)[1] = "geo_id"

# Get 10 richest counties and their geographic coordinates
# WHERE hc01_est_vc14 NOT LIKE '%(X)%' is temporary

acs15_finance_county.rich.sql <- tbl(census2010_db, sql("
                                                        SELECT geo_display_label as county,
                                                        hc01_est_vc14 as median_household_income,
                                                        geography_county.geoid as geoid,
                                                        CAST(intptlat AS float8) as lat,
                                                        CAST(intptlong AS float8) as long
                                                        FROM geography_county
                                                        JOIN acs15_finance_county
                                                        ON geography_county.geoid = acs15_finance_county.geoid
                                                        WHERE hc01_est_vc14 NOT LIKE '%(X)%'
                                                        ORDER BY hc01_est_vc14 DESC
                                                        LIMIT 25
                                                        "))

acs15_finance_county.rich <- collect(acs15_finance_county.rich.sql)

# ===== Separate states from towns ====
# States have a geoid < 100
med_hh_income.states <- filter(med_hh_income, geoid < 100)
med_hh_income.towns <- filter(med_hh_income, geoid > 100)

# Ordered by biggest 50 cities (population)
med_hh_income.towns_big25 <- arrange(
  med_hh_income.towns,
  desc(Population))[1:25, ]

# ==== US County Map Data ====
counties <- geojsonio::geojson_read("data/geography/gz_2010_us_050_00_20m.json",
                                    what = "sp")

# Lowercase names
names(counties@data) = tolower(names(counties@data))

county_mhhi <- left_join(counties@data, acs15_finance_county, by='geo_id')

# ==== Helper Function ====
clean_names <- function(city) {
  # Ex result of strsplit:
  # "United States " " Colorado "     " Crisman CDP"  
  city <- strsplit(city, "-")[[1]][3]
  
  return(city)
}

# Temporary: Clean up city names
med_hh_income.towns_big25$Location <- sapply(
  med_hh_income.towns_big25$Location, clean_names)

# ==== ggplots ====
# ==== ggplot: Median Household Income ====

# hist(med_hh_income.towns$`Median Household Income`, breaks=50,
#     main="Distribution of US Median Household Income by Town")

mhhi_hist <- ggplot(med_hh_income.towns,
                    aes(`Median Household Income`)) +
  geom_histogram()

# ==== ggplot: Median Income of 25 Most Populous Cities ====
# hist(med_hh_income.towns_big25$`Median Household Income`, breaks=50)

top_25_bar <- ggplot(med_hh_income.towns_big25) + 
  geom_col(aes(x=Location, y=`Median Household Income`)) +
  ggtitle("Median Household Income -- 25 Most Populous US Cities") + 
  theme(axis.text.x = element_text(angle = 75, hjust = 1)) + 
  
  # Add line for US median household income
  geom_hline(yintercept = 53889)

# ==== Leaflet Map ====
pal = colorQuantile(
  palette = c("#d7191c", "#fdae61", "#ffffbf", "#abd9e9", "#2c7bb6"),
  n = 10,
  domain = county_mhhi$hc01_est_vc14)

mhhi_map <- leaflet(counties) %>%
  # Color
  addPolygons(
    color = ~pal(county_mhhi$hc01_est_vc14),
    weight = 1,
    opacity = 1
  ) %>%
  
  addTiles() %>%
  
  # Richest US counties
  addMarkers(
    ~acs15_finance_county.rich$long,
    ~acs15_finance_county.rich$lat,
    popup = paste("<b>", acs15_finance_county.rich$county, "</b><br />",
                  "Median Household Income:",
                  " $", acs15_finance_county.rich$median_household_income,
                  sep=""))