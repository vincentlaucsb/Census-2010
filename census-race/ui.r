library(shiny)
library(leaflet)

# ==== HTML ====
shinyUI(fluidPage(
  h1("Race and Ethnicity in the United States"),

  # ==== Maps ====
  mainPanel(
    div(
      tabsetPanel(
        tabPanel("Whites", leafletOutput("whites_map")),
        tabPanel("Blacks", leafletOutput("blacks_map")),
        tabPanel("Asians", leafletOutput("asians_map"))
      ),

      style = "width: 100%; height: 100%"
    )
  ),
  
  # ==== Data Explorer ====
  mainPanel(
    h2("Data Explorer"),
    
    # Geography Options
    fluidRow(
      selectInput("race_table",
                  "Geographic Level",
                  c("All", "Towns and Cities", "Counties"))
    ),
    
    dataTableOutput("race_table")
  )
))