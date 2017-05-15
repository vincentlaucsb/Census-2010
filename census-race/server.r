# This block by itself launches a blank page
library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)

# ==== Server ====
shinyServer(func = function(input, output) {
  
  # ==== Maps ====
  output$whites_map <- renderLeaflet(whites_map)
  output$blacks_map <- renderLeaflet(blacks_map)
  output$asians_map <- renderLeaflet(asians_map)
  
  # ==== Data Explorer ====
  output$race_table <- renderDataTable({
    if (input$race_table == "Counties") {
      all_races.county
    } else {
      all_races.towns
    }
  })
  
})