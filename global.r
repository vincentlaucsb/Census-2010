# This block by itself launches a blank page
library(leaflet)
library(geojsonio)
library(dplyr)
library(ggplot2)

# Load helper functions
source('util.r')

# ==== Load Data ====
source('postgres_pw.r')

census2010_db <- src_postgres("census2010",
                              user=postgres_user,
                              password=password,
                              host="localhost")

# ==== Household Income by City ====
med_hh_income.sql <- tbl(census2010_db, sql("
  SELECT
    population.geoid,
    CAST(hd01_s001 AS integer) as population,
    (city || ',' || state) as location,
    CAST(hc01 AS integer)
  
  FROM median_household_income LEFT JOIN population
    ON population.geoid = median_household_income.geoid
  JOIN clean_place_names
    ON population.geoid = clean_place_names.geoid"))

# Remove missing values and rearrange in descending order
med_hh_income <- collect(
  filter(med_hh_income.sql, !is.null(hc01)) %>%
    select(geoid, population, location, hc01) %>%
    mutate(hc01 = as.numeric(hc01)) %>%
    arrange(desc(hc01))
)

names(med_hh_income) = c("geoid", "Population", "City",
                         "Median Household Income")

# Median household income of richest 25 cities
med_hh_income_big25 <- arrange(med_hh_income,
  desc(Population))[1:25, ]

# ==== Household income data by county ====
med_hh_income.county <- collect(
  tbl(census2010_db, sql(
        "SELECT acs15_finance_county.geo_id,
            acs15_finance_county.geo_display_label,
            hc01_est_vc14, hd01_vd02
         FROM acs15_finance_county JOIN acs15_race_county
            ON acs15_finance_county.geo_id = acs15_race_county.geo_id
         WHERE (hc01_est_vc14 IS NOT NULL)
         AND (hc01_est_vc14 NOT LIKE '%(X)%')"))) %>%
  mutate(hc01_est_vc14 = as.numeric(hc01_est_vc14))

names(med_hh_income.county)[1] = "geo_id"

# Get 10 richest counties and their geographic coordinates
# WHERE hc01_est_vc14 NOT LIKE '%(X)%' is temporary

med_hh_income.county.rich <- collect(tbl(census2010_db,
   sql("SELECT geo_display_label as county,
          hc01_est_vc14 as median_household_income,
          geography_county.geoid as geoid,
          CAST(intptlat AS float8) as lat,
          CAST(intptlong AS float8) as long
        FROM geography_county JOIN acs15_finance_county
          ON geography_county.geoid = acs15_finance_county.geoid
        WHERE hc01_est_vc14 NOT LIKE '%(X)%'
          ORDER BY hc01_est_vc14 DESC
          LIMIT 25")))

# ==== US County Map Data ====
counties <- geojsonio::geojson_read("data/geography/gz_2010_us_050_00_20m.json",
                                    what = "sp")

# Lowercase names
names(counties@data) = tolower(names(counties@data))

county_mhhi <- left_join(counties@data, med_hh_income.county, by='geo_id')

# ==== ggplots ====
# ==== ggplot: Median Household Income ====

# hist(med_hh_income$`Median Household Income`, breaks=50,
#     main="Distribution of US Median Household Income by Town")

mhhi_hist <- ggplot(med_hh_income,
                    aes(`Median Household Income`)) +
  geom_histogram()

# ==== ggplot: Median Income of 25 Most Populous Cities ====
# hist(med_hh_income_big25$`Median Household Income`, breaks=50)

top_25_bar <- ggplot(med_hh_income_big25) + 
  geom_col(aes(x=City, y=`Median Household Income`)) +
  ggtitle("Median Household Income -- 25 Most Populous US Cities") + 
  theme(axis.text.x = element_text(angle = 75, hjust = 1)) + 
  
  # Add line for US median household income
  geom_hline(yintercept = 53889)

# ==== Leaflet Map ====
# mhhi_pal <- c("#a50026", "#d73027", "#f46d43", "#fdae61", "#fee090",
#               "#e0f3f8", "#abd9e9", "#74add1", "#4575b4", "#313695")

mhhi_pal <- c("#67001f", "#b2182b", "#d6604d", "#f4a582", "#fddbc7",
              "#d1e5f0", "#92c5de", "#4393c3", "#2166ac", "#053061")

pal = colorQuantile(
  palette = mhhi_pal,
  n = 10,
  domain = county_mhhi$hc01_est_vc14)

mhhi_map <- leaflet(counties) %>%
  # Color
  addPolygons(
    color = ~pal(county_mhhi$hc01_est_vc14),
    weight = 1,
    opacity = 1,
    fillOpacity = 0.6
  ) %>%
  
  addLegend(
    title = "Median Household Income",
    colors = mhhi_pal,
    labels = get_label(data=county_mhhi$hc01_est_vc14, n=10,
                       transform=c("as.money")),
    opacity = 1) %>%
  
  addTiles() %>%
  
  # Richest US counties
  addMarkers(
    ~med_hh_income.county.rich$long,
    ~med_hh_income.county.rich$lat,
    popup = paste("<b>", med_hh_income.county.rich$county, "</b><br />",
                  "Median Household Income:",
                  " $", med_hh_income.county.rich$median_household_income,
                  sep=""))