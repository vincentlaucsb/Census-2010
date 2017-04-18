# Census 2010
A data visualization project with US Census 2010 data involving Python, plotly, and SQL.

## Live Demonstration
http://www.vincela.com/census2010

## Files
### Data
 * create_database.py
  * The file used to create `census2010.db` from Census 2010 CSVs/text files
 * settings.py
  * Common variables shared between Plotly graphs
  
### Plotly
All of the Python scripts that are used to generate Plotly graphs (in HTML format) can be run independently of each other.

#### Plotly Graphs
* us_map.py
  * Create a bubble map of the United States, where each bubble is proportional to a city's population
* us_map_by_race.py
  * Also creates a bubble map of the United States, but this time each bubble is proportional to the population of a certain race

#### Plotly Bar Graphs
* us_bars_by_race.py
  * Create bar graphs of the top 25 cities (population > 100,000) with the highest percentage of a certain race
