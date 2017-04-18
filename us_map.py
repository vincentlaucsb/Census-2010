'''
Generate a map of the United States highlighting population of each place
 * Bigger places get bigger bubbles
'''

import sqlite3 as sql

import plotly.offline as py
import plotly.graph_objs as go

from settings import PLOTLY_MAP_LAYOUT

conn = sql.connect('census2010.db')

def create_map(conn):
    '''
    Arguments:
     * conn:    An sqlite3 connection object
    '''
    
    # HD01_S001 = Population
    sql_data = conn.execute(
    ''' SELECT HD01_S001, NAME, USPS, INTPTLAT, INTPTLONG
        FROM places JOIN census2010 ON places.GEOID = census2010.GEOID
        WHERE HD01_S001 > 15000 ORDER BY HD01_S001 DESC;
    ''')

    pop = []
    text = []
    lat = []
    long = []
    largest_pop = None

    for row in sql_data:
        # Get population of largest city (first row) so it can be used to 
        # calculate bubble sizes
        if not largest_pop:
            largest_pop = row[0]
    
        pop.append(row[0])
        text.append("{place}, {state}<br />Population: {pop})".format(
            place=row[1], state=row[2], pop=row[0]))
        lat.append(row[3])
        long.append(row[4])
        
    data = [{
        "lat": lat,
        "lon": long,
        "text": text,
        "type": 'scattergeo',
        "marker": {
            "color": "rgba(222, 232, 207, 0.35)", # Documentation has a typo?
            
            # Bubble Sizes determined below:
            #  - Largest bubble (corresponding to largest city) should be 200px
            #  - All other places' bubbles should be a fraction of that
            
            "size": [x/largest_pop * 200 for x in pop],
            "line": {
                'color': 'rgba(50, 50, 59, 0.9)',
                'width': 2,
            }
        }
    }]
      
    us_map_layout = PLOTLY_MAP_LAYOUT
    us_map_layout['showlegend'] = False
      
    fig = go.Figure(data=data, layout=us_map_layout)
    py.plot(fig, filename='us-map.html')
    
# Bar Chart: 25 Most Populous Cities
def create_bar_plot(conn):
    sql_data = conn.execute(
        ''' SELECT HD01_S001, NAME, USPS FROM census2010 JOIN places
            ON places.GEOID = census2010.GEOID
            ORDER BY HD01_S001 DESC
            LIMIT 25;
        ''')

    place = []
    pop = []
                         
    for row in sql_data:
        place.append("{place}, {state}".format(
            place=row[1], state=row[2], pop=row[0]))
        pop.append(row[0])
        
    data = [go.Bar(x=place, y=pop)]
    layout = {'title': 'Largest 25 Cities in the United States'}
    
    fig = go.Figure(data=data, layout=layout)
    py.plot(fig, filename='us-top-25-pop.html')

create_map(conn)
create_bar_plot(conn)
    
# Close the database
conn.close()