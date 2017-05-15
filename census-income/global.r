# This block by itself launches a blank page
library(leaflet)
library(geojsonio)
library(ggplot2)
library(dplyr)
library(reshape2)

# Get working directory
source('wd.r')
setwd(working_dir)

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
    (city || ', ' || state) as location,
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
) %>%
  
  # Replace "Nashville-Davidson metropolitan government" with "Nashville"
  mutate(location = ifelse(
    grepl("Nashville-Davidson", location),
    yes="Nashville, Tennessee", no=location))

names(med_hh_income) = c("geoid", "Population", "City",
                         "Median Household Income")

# Median household income of richest 25 cities
med_hh_income_big25 <- arrange(med_hh_income,
  desc(Population))[1:25, ]

# ==== Household income data by county ====
# hc01_est_vc14 = Median Household Income (in the past 12 months)
# hd01_vd01 = Total population

med_hh_income.county <- collect(
  tbl(census2010_db, sql(
        "SELECT acs15_finance_county.geo_id,
            acs15_finance_county.geo_display_label,
            hc01_est_vc14, hd01_vd01
         FROM acs15_finance_county JOIN acs15_race_county
            ON acs15_finance_county.geo_id = acs15_race_county.geo_id
         WHERE (hc01_est_vc14 IS NOT NULL)
         AND (hc01_est_vc14 NOT LIKE '%(X)%')"))) %>%
  mutate(hc01_est_vc14 = as.numeric(hc01_est_vc14))

names(med_hh_income.county)[1] = "geo_id"
names(med_hh_income.county)[3] = "Median Household Income"

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

# ==== Zillow Home Prices Data (joined with biggest 25 cities) ====
zillow <- collect(
  tbl(census2010_db, sql(
    "SELECT
	city, harambe.state, hc01,
    CAST(_2015_07 as float8), CAST(_2015_08 as float8),
    CAST(_2015_09 as float8), CAST(_2015_10 as float8),
    CAST(_2015_11 as float8), CAST(_2015_12 as float8),
    CAST(_2016_01 as float8), CAST(_2016_02 as float8),
    CAST(_2016_03 as float8), CAST(_2016_04 as float8),
    CAST(_2016_05 as float8), CAST(_2016_06 as float8)
    FROM city_median_soldpricepersqft_singlefamily RIGHT JOIN
    (SELECT
    population.geoid, city, abbreviation as state,
    CAST(hd01_s001 AS integer) as population,
    CAST(hc01 AS integer)
    FROM median_household_income LEFT JOIN population
    ON population.geoid = median_household_income.geoid
    JOIN clean_place_names
    ON population.geoid = clean_place_names.geoid
    ORDER BY population DESC
    LIMIT 25) as harambe
    ON (harambe.city || harambe.state) = (regionname || city_median_soldpricepersqft_singlefamily.state)"
  ))
) %>%
  mutate(yr_avg = rowMeans(.[4:15], na.rm=TRUE))

# ==== ggplots ====
# ==== ggplot: Median Household Income ====

# hist(med_hh_income$`Median Household Income`, breaks=50,
#     main="Distribution of US Median Household Income by Town")

mhhi_hist <- ggplot(med_hh_income,
  aes(`Median Household Income`)) +
  labs(y = 'Number of Towns') +
  geom_histogram()

mhhi_hist.county <- ggplot(med_hh_income.county,
  aes(`Median Household Income`)) +
  labs(y = 'Number of Counties') +
  geom_histogram()

# ==== ggplot: Median Income of 25 Most Populous Cities ====
# hist(med_hh_income_big25$`Median Household Income`, breaks=50)

top_25_bar <- ggplot(med_hh_income_big25) + 
  geom_col(aes(x=City, y=`Median Household Income`)) +
  ggtitle("Median Household Income -- 25 Most Populous US Cities") + 
  theme(axis.text.x = element_text(angle = 75, hjust = 1)) + 
  
  # Add line for US median household income
  geom_hline(yintercept = 53889)

# ==== ggplots: Income vs Housing Price ====
# Scatter Plot of Median Household Income vs. Home Prices
sf_median_income <- as.numeric(
  zillow %>%
    filter(city == 'San Francisco') %>% select(hc01)
)

top_25_scatter.df <- zillow %>%
  filter(!is.na(yr_avg)) %>%
  mutate(inc_vs_home = hc01/yr_avg) %>%
  mutate(sf_vs_home = sf_median_income/yr_avg)
  
top_25_scatter <- ggplot(
  top_25_scatter.df, aes(x=hc01, y=yr_avg)) + 
  geom_point() + 
  geom_text(aes(label=city), hjust=-0.15, vjust=0.5) +
  labs(x = "Median Household Income",
       y = "Median Price of a Single-Family Home (per sq ft)")
  
# Bar Plot: Median Household Income/Price per Ft^2
top_25_bar.inc_vs_home <- ggplot(
  top_25_scatter.df, aes(x=city, y=inc_vs_home)) +
  geom_col() + 
  labs(title = "What Can A Year's Income Buy?",
       subtitle = "(Each city's respective median household income and median price/sq ft of a single family home was used)",
       x = "City",
       y = "Size of Affordable Home (sq ft)") +

  # Angle text a bit to avoid crowding
  theme(axis.text.x = element_text(angle = 75, hjust = 1))

# Bar Plot: If every household had the income of a median San Franciscan...
# vs. how much they can currently buy
top_25_bar.sf_vs_home.df <- melt({
  data <- top_25_scatter.df %>%
    select(city, inc_vs_home, sf_vs_home)
  
  names(data)[2:3] = c(
    "With Actual Median Household Income",
    "With SF Median Household Income")
    
  data},
  vars=city)

top_25_bar.sf_vs_home <- ggplot(
  top_25_bar.sf_vs_home.df,
  aes(x=city, y=value)) +
  geom_bar(aes(fill = variable), position="dodge", stat="identity") +
  labs(x = "City",
       y = "Size of Affordable Home (sq ft)") +
  
  # Angle text a bit to avoid crowding
  theme(axis.text.x = element_text(angle = 75, hjust = 1))

top_25_bar.sf_vs_home

# Not a very useful visualization
#
# # Standardize rows and convert to long format
# top_25_bar.df <- melt(
#   zillow %>%
#     # Remove NAs with zero
#     mutate(yr_avg = ifelse(is.na(yr_avg), 0, yr_avg)) %>%
#     
#     # Standardize
#     mutate_each_(funs(scale(.) %>% as.vector), 
#                  vars=c("hc01","yr_avg")) %>%
#     select(city, hc01, yr_avg),
#   vars = city)
# 
# # Reference for grouped bar chart:
# # http://www.r-graph-gallery.com/48-grouped-barplot-with-ggplot2/
# # Standardizing bars
# # http://stackoverflow.com/questions/15215457/standardize-data-columns-in-r
# top_25_bar.std <- ggplot(top_25_bar.df, aes(city, value)) + 
#   geom_bar(aes(fill = variable), position="dodge", stat="identity") + 
#   ggtitle("Median Household Income -- 25 Most Populous US Cities") + 
#   theme(axis.text.x = element_text(angle = 75, hjust = 1))

# ==== Leaflet Map ====
# mhhi_pal <- c("#a50026", "#d73027", "#f46d43", "#fdae61", "#fee090",
#               "#e0f3f8", "#abd9e9", "#74add1", "#4575b4", "#313695")

mhhi_pal <- c("#67001f", "#b2182b", "#d6604d", "#f4a582", "#fddbc7",
              "#d1e5f0", "#92c5de", "#4393c3", "#2166ac", "#053061")

pal = colorQuantile(
  palette = mhhi_pal,
  n = 10,
  domain = county_mhhi$`Median Household Income`)

mhhi_map <- leaflet(counties) %>%
  # Color
  addPolygons(
    color = ~pal(county_mhhi$`Median Household Income`),
    weight = 1,
    opacity = 1,
    fillOpacity = 0.6
  ) %>%
  
  addLegend(
    title = "Median Household Income",
    colors = mhhi_pal,
    labels = get_label(data=county_mhhi$`Median Household Income`, n=10,
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