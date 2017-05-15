library(shiny)
library(leaflet)

# ==== HTML ====
shinyUI(fluidPage(
  titlePanel("Median Household Income in the United States"),
  
  # Median Household Income Data
  fluidRow(
    p('The US median household income distribution has a strong right skew when 
      counting at a town level, but looks much more symmetric when counting at 
      a county level. A possible explanation for this is while more affluent 
      households tend to live close together in the same town, the towns themselves
      are located in counties with a mixture of different levels of wealth. There 
      are not a lot of "super counties" filled with entirely wealthy towns, although
      the small right skew on the county histogram shows they do exist.'),
    tabsetPanel(
      tabPanel("Towns",
        plotOutput("median_household_income")),
      tabPanel("Counties",
        plotOutput("median_household_income.county")
      )
    )
  ),
  
  # ==== Median Income of 25 Most Populous Cities ====
  fluidRow(
    h2("Median Household Income of 25 Most Populous Cities"),
    p("Apparently, the majority 25 most populous US cities 
      median US household income line (indicated with a solid black line)."),
    plotOutput("mhhi_biggest_cities")
  ),
  
  # Median Income vs. Housing Price
  fluidRow(
    h3("Median Household Income vs. Housing Prices"),
    p(HTML(
      "While some cities have higher earners than others, does this translate
      to an increase in purchasing power? Here, median household income was paired 
      with home prices (courtesy of <a href='https://www.zillow.com/research/data/'>
      Zillow</a>). The median price per square foot of a single-family residence
      was used to compare different cities. This value was averaged across 12 months
      from July 2015 to June 2016 to lessen the effect of potential seasonal
      variation and other random shocks. Unfortunately, six of the twenty-five cities
      could not be included in this analysis because there was no straightforward
      Zillow data available for that city.")),
    p(HTML(
      'After this was done, San Francisco appeared as a large outlier. While the median
      San Francisco household earns more than twice as much than&mdash;for example&mdash;
      the median Philadelphia household, it pays disproportionately much more for a home.
      Thus, there is a bar chart under <b>"San Francisco Money"</b> which shows how  
      much square footage a median household in a city could hypothetically afford if they had 
      the income of a median San Francisco household.')),
    tabsetPanel(
      tabPanel("Income vs. Housing Price", plotOutput("top_25_scatter")),
      tabPanel("Bar Chart", plotOutput("top_25_bar.inc_vs_home")),
      tabPanel("San Francisco Money",
               plotOutput("top_25_bar.sf_vs_home"))
    )
  ),
  
  # Map
  fluidRow(
    h2("Map"),
    p("The blue markers represented the 25 richest counties in the United States when
      ranked by median household income. As we can see, a large number of those are clustered
      around our nation's capital. Furthermore, the only markers on the West Coast all 
      belong counties in the San Francisco Bay Area."),
    leafletOutput("mhhi_map")
  ),
  
  
  # Median Income Table Output
  fluidRow(
    h2("Data Explorer"),
    p("Do you have any more lingering questions about the distribution of income
      in the United States? Want to find out how rich your home town is? This data
      explorer has access to the median household income of every US town and county
      (sans a few missing values)."),
    
    # Median Income Table Options
    selectInput("mhhi_table",
                "Geographic Level",
                c("Towns", "Counties")),
    
    dataTableOutput("mhhi_table")
  )
))