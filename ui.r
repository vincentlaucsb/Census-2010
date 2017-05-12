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
    plotOutput("mmhi_biggest_cities")
  ),
  
  # Map
  fluidRow(
    leafletOutput("mmhi_map")
  ),
  
  # Median Income Table Options
  fluidRow(
    selectInput("mmhi_table",
                "Geographic Level",
                c("All", "Towns", "States"))
  ),
  
  # Median Income Table Output
  fluidRow(
    dataTableOutput("mmhi_table")
  )
))