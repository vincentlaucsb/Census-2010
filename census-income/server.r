# This block by itself launches a blank page
library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)

# ==== Server ====
shinyServer(func = function(input, output, session) {
  
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
  
  # Change Dataset
  observe({
    dataset <- input$map_dataset
    
    if (input$map_dataset == "ACS 5-Year Estimates") {
      updateSelectInput(session, "map_year",
                        choices = ACS_5YR_RANGE)
    } else {
      updateSelectInput(session, "map_year",
                        choices = ACS_1YR_RANGE)
    }
  })
  
  # Change Year
  observe({
    # browser()
    # debug(session_map$show_year)
    
    session_map <- IncomeMap(data = ACS_5YR_FINANCE_COUNTY,
                             map = leafletProxy("mhhi_map",
                                                data=COUNTIES_GEO,
                                                session))
    
    if (input$map_dataset == "ACS 5-Year Estimates") {
      # Swap pointers
      session_map$data = ACS_5YR_FINANCE_COUNTY
      session_map$dataset = '5yr'
      
      # Make sure map years are valid
      if (input$map_year %in% ACS_5YR_RANGE) {
        # Load map layer
        # cat("Input Year:", as.td_yr(input$map_year))
        session_map$show_year(as.td_yr(input$map_year))
      }
    } else {
      # Swap pointers
      session_map$data = ACS_1YR_FINANCE_COUNTY
      session_map$dataset = '1yr'
      
      # Make sure map years are valid
      if (input$map_year %in% ACS_1YR_RANGE) {
        # Load map layer
        cat("Input Year:", as.td_yr(input$map_year))
        session_map$show_year(as.td_yr(input$map_year))
      }
    }
  })
  
  # ==== Median Income Table ====
  mhhi_table.cols_subset = c("City", "Population",
                             "Median Household Income")
  
  output$mhhi_table <- renderDataTable({
    if (input$mhhi_table == "Counties (ACS 1-Year Estimates)") {
      data <- ACS_1YR_FINANCE_COUNTY$county_data[
        c("geo_display_label",
          "mhhi_15", "mhhi_moe_15", 
          "mhhi_13", "mhhi_moe_13",
          "mhhi_11", "mhhi_moe_11",
          "mhhi_09", "mhhi_moe_09",
          "mhhi_07", "mhhi_moe_07",
          "mhhi_05", "mhhi_moe_05")] %>%
        filter(!is.na(geo_display_label))
      
      names(data) = c("County", "2015", "MoE", "2013", "MoE", 
                      "2011", "MoE", "2009", "MoE", 
                      "2007", "MoE", "2005", "MoE")
      
      
    } else if (input$mhhi_table == "Counties (ACS 5-Year Estimates)") {
      data <- ACS_5YR_FINANCE_COUNTY$county_data[
        c("geo_display_label", "mhhi_15", "mhhi_moe_15", "mhhi_10", "mhhi_moe_10")] %>%
        filter(!is.na(geo_display_label))
      names(data) = c("County", "2015", "MoE", "2010", "MoE")
    } else {
      data <- med_hh_income[mhhi_table.cols_subset]
    }
    
    data
  })
})