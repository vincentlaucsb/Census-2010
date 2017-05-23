library(leaflet)

# A bunch of helper functions for manipulating live Leaflet maps
IncomeMap <- setRefClass(
  "IncomeMap",
  
  # Fields:
  #  * dataset:       Which dataset (ACS 5-YR, 1-YR, or 3-YR)
  #  * current_data:  Which year and dataset is currently loaded
  
  fields = c('data', 'dataset', 'map', 'pal', 'current_data', 'loaded_data'),
  methods = list(
    initialize = function(
      data,
      map,
      pal=c("#67001f", "#b2182b", "#d6604d", "#f4a582", "#fddbc7",
            "#d1e5f0", "#92c5de", "#4393c3", "#2166ac", "#053061")) {
      
      # Arguments:
      #  * map:      A leafletProxy object
      #  * data:     An IncomeData instance
      #  * pal:      A vector of  colors
      
      # Note:
      # https://www.stat.berkeley.edu/~paciorek/computingTips/Pointers_passing_reference_.html
      #  * Using an IncomeData instance for data allows us to avoid using more memory
      #    because environments are pass by reference in R
      
      pal <<- pal
      data <<- data
      map <<- map
      current_data <<- c('acs5yr_15')
      loaded_data <<- c()
    },
    
    add_year = function(year='15') {
      # Add a new year's worth of data as a map layer
      # Default: 2015
      # cat("Year", year)
      
      year_data <- .self$data$get_mhhi_data(year)
      rich_data <- .self$data$get_top_mhhi(year)[1:25, ]
      
      map_pal <- colorQuantile(
        palette = .self$pal,
        n = 10,
        domain = year_data)
      
      # Layer Name
      group_name <- sprintf('acs%s_%s', .self$dataset, year)
      
      map <<- .self$map %>%
          addPolygons(
            color = ~map_pal(year_data),
            weight = 1,
            opacity = 1,
            fillOpacity = 0.6,
            group = group_name
          ) %>%
        
          # Richest US counties
          addMarkers(
            rich_data$long,
            rich_data$lat,
            popup = paste("<b>",rich_data$geo_display_label, "</b><br />",
                          "Median Household Income:",
                          " $", rich_data$mhhi,
                          sep=""),
            group = group_name)
    },
    
    show_year = function(year) {
      # Get data for year, show it, and hide the previous layer
      # Year should be specified as a character in two-digit format

      # Ex: acs5yr_15 (ACS 2015 5-Year Estimates)
      layer_name = sprintf('acs%s_%s', .self$dataset, year)
      
      if (!(layer_name %in% .self$loaded_data)) {
        .self$add_year(year)
        .self$loaded_data <- append(.self$loaded_data, layer_name)
      }
      
      .self$map %>%
        hideGroup(.self$current_data) %>%
        showGroup(layer_name) %>%

        # Change legend
        clearControls() %>%
        addLegend(
          title = "Median Household Income",
          colors = .self$pal,
          labels = get_label(data= .self$data$get_mhhi_data(year), n=10,
                             transform=c("as.money")),
          opacity = 1)
      
      .self$current_data <- layer_name
    }
  )
)