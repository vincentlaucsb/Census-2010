# This block by itself launches a blank page
library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)

# ==== Server ====
shinyServer(func = function(input, output) {
  
  # ==== Median Income Histogram ====
  output$median_household_income <- renderPlot(mhhi_hist)
  
  # ==== Median Income of 25 Most Populous Cities ====
  output$mmhi_biggest_cities <- renderPlot(top_25_bar)
  
  # ==== Median Income Map ====
  output$mmhi_map <- renderLeaflet(mhhi_map
  #   {
  #   leaflet(counties) %>%
  #     
  #     # Color
  #     addPolygons(
  #       color = ~pal(county_mhhi$hc01_est_vc14),
  #       weight = 1,
  #       opacity = 1
  #     ) %>%
  #     
  #     addTiles() %>%
  #     
  #     # addLegend(
  #     #   title = "Median Household Income",
  #     #   pal = ~pal(county_mhhi$hc01_est_vc14),
  #     #   values = county_mhhi$hc01_est_vc14,
  #     #   # labels = c("Test", "Test", "Test", "Test", "test", "test", "test", "test", "test", "test"),
  #     #   #labFormat = labelFormat(prefix = "$",
  #     #   #                        transform = function(x) 200 * x),
  #     #   opacity = 1) %>%
  #     
  #     # Richest US counties
  #   addMarkers(
  #     ~acs15_finance_county.rich$long,
  #     ~acs15_finance_county.rich$lat,
  #     popup = paste("<b>", acs15_finance_county.rich$county, "</b><br />",
  #                   "Median Household Income:", 
  #                   " $", acs15_finance_county.rich$median_household_income,
  #                   sep=""))
  # }
  )
  
  # ==== Median Income Table ====
  mmhi_table.cols_subset = c("Location", "Population", "Median Household Income")
  
  output$mmhi_table <- renderDataTable({
    data <- med_hh_income.towns[mmhi_table.cols_subset]
    
    if (input$mmhi_table == "States") {
      data <- med_hh_income.states[mmhi_table.cols_subset]
    }
    
    data
  })
})