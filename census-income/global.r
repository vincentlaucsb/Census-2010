# This block by itself launches a blank page
library(leaflet)
library(geojsonio)
library(ggplot2)
library(dplyr)
library(reshape2)

# Get app specific helpers
source('data.r')
source('map.r')

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

# ==== Globals ====
ACS_1YR_RANGE = as.character(seq(2015, 2005))
ACS_1YR_FINANCE_COUNTY <- new('IncomeData',
                              counties=COUNTIES_GEO,
                              sql_conn=census2010_db,
                              query=get_mhhi_ts_query)

ACS_5YR_RANGE = c("2015", "2010")
ACS_5YR_FINANCE_COUNTY <- new('IncomeData',
                              counties=COUNTIES_GEO,
                              sql_conn=census2010_db,
                              query=get_mhhi_acs5)

# ==== Household Income by City (ACS 15 5-YR Estimate) ====
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
mhhi_hist <- ggplot(med_hh_income,
  aes(`Median Household Income`)) +
  labs(y = 'Number of Towns') +
  geom_histogram()

mhhi_hist.county <- ggplot(ACS_5YR_FINANCE_COUNTY$county_data,
  aes(mhhi_15)) +
  labs(y = 'Number of Counties') +
  geom_histogram()

# ==== ggplot: Median Income of 25 Most Populous Cities ====
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
  labs(title = "What Can The Median Annual San Francisco Household Income Buy?",
       x = "City",
       y = "Size of Affordable Home (sq ft)") +
  
  # Angle text a bit to avoid crowding
  theme(axis.text.x = element_text(angle = 75, hjust = 1))

top_25_bar.sf_vs_home

# ==== Leaflet Map ====
# Load a blank map
mhhi_map <- leaflet(counties) %>%
  addTiles()