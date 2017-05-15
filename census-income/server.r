# This block by itself launches a blank page
library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)

# ==== Server ====
shinyServer(func = function(input, output) {
  
  # ==== Median Income Histogram ====
  output$median_household_income <- renderPlot(mhhi_hist)
  output$median_household_income.county <- renderPlot(mhhi_hist.county)
  
  # ==== Median Income of 25 Most Populous Cities ====
  output$mhhi_biggest_cities <- renderPlot(top_25_bar)
  
  # Median Income vs. Housing Prices
  output$top_25_scatter <- renderPlot(top_25_scatter)
  output$top_25_bar.inc_vs_home <- renderPlot(top_25_bar.inc_vs_home)
  output$top_25_bar.sf_vs_home <- renderPlot(top_25_bar.sf_vs_home)

  # ==== Median Income Map ====
  output$mhhi_map <- renderLeaflet(mhhi_map)
  
  # ==== Median Income Table ====
  mhhi_table.cols_subset = c("City", "Population",
                             "Median Household Income")
  
  output$mhhi_table <- renderDataTable({
    data <- med_hh_income[mhhi_table.cols_subset]
    
    if (input$mhhi_table == "Counties") {
      data <- med_hh_income.county[
        c("geo_display_label", "hd01_vd01", "Median Household Income")]
      names(data) = c("County", "Population", "Median Household Income")
    }
    
    data
  })
})