library(shiny)
library(leaflet)

# ==== HTML ====
shinyUI(fluidPage(
  titlePanel("Income Distribution in the United States -- Census 2010"),
  
  # Median Household Income Data
  fluidRow(
    plotOutput("median_household_income")
  ),
  
  fluidRow(
    plotOutput("mhhi_biggest_cities")
  ),
  
  # Map
  fluidRow(
    leafletOutput("mhhi_map")
  ),
  
  # Median Income Table Options
  fluidRow(
    selectInput("mhhi_table",
                "Geographic Level",
                c("All", "Towns", "Counties"))
  ),
  
  # Median Income Table Output
  fluidRow(
    dataTableOutput("mhhi_table")
  )
))