# Census 2010 Data Visualization
A data visualization project with US Census Bureau Data, including the 2010 Census and the American Community Survey.

## Dependencies
* R
  * Shiny (for interactive web apps)
  * Leaflet (for maps)
  * ggplot2 (for plots)
  * geojsonio (for loading GeoJSON files)
  * dplyr + RPostgreSQL
* PostgreSQL
* Python (optional)
  * Only if you want to recreate the SQL database from the original database
  * (A PostgreSQL dump file is already provided)

## Recreating this project
In addition to cloning this repository and installing the required dependencies, you should:
* Load the PostgreSQL database from the dump file (easier/recommended)
  * census2010_postgres_dump.sql
* Or, run 'create_database_pg.py' using my (SQL converter library)[https://github.com/vincentlaucsb/sqlify]
  * For each function call, set `engine='sqlite'` if you want to use SQLite instead of Postgres.
  * This will create a SQLite database in the same directory.
  * ***Note:*** This method will not recreate the database used exactly as some data cleaning was performed via SQL
  
And...
* Recreate a file named `postgres_pw.r` in the root directory which defines these variables:
~~~~
postgres_user <- 'postgres'
password <- '**********'
~~~~
* Alternatively, modify the database access settings at the top of `global.r`
 
## Plotly
The previous version of this project was created with Python, Plotly, and SQLite.
See the plotly/ subdirectory for the .zip file containing the original files.
