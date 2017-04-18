'''
Create bar charts of race demographics
'''

import sqlite3 as sql

import plotly.offline as py
import plotly.graph_objs as go

conn = sql.connect('census2010.db')

def top_25_by_percent(conn, race, race_col, percent_col):
    '''
    Create bar charts of the top 25 cities (>100,000 people) with the highest
    percentage of a certain race
    
    Arguments:
     * conn:        sqlite3 Connection object
     * race:        A string specifying the race (should be capitalized like "Asian")
     * race_col:    Column of race counts per place
     * percent_col: Coumn of %age of population that is the specified race per place
    '''
    
    sql_data = conn.execute(
    ''' SELECT NAME, USPS, HD01_S001, {race_col}
        FROM census2010 JOIN places on census2010.GEOID = places.GEOID
        WHERE HD01_S001 > 100000 ORDER BY {percent_col} DESC
        LIMIT 25;
    '''.format(race_col=race_col, percent_col=percent_col))
    
    place = []
    race_count = []
    pop = []
    
    for row in sql_data:
        place.append('{0}, {1}'.format(row[0], row[1]))
        pop.append(row[2])
        race_count.append(row[3])
    
    data = [
        go.Bar(x=place, y=pop, name='Total Population'),
        go.Bar(x=place, y=race_count, name='{0} Population'.format(race))
    ]
    
    layout = {
        'title': 'Highest {0} Concentrations<br><span style="font-size: 90%">(of cities with more than 100,000 people)</span>'.format(race),
        'barmode': 'group'
    }
    
    fig = go.Figure(data=data, layout=layout)
    py.plot(fig, filename='us-top-25-{0}.html'.format(race.lower()))
    
# HD01_S095 = Number of Mixed Race
# HD02_S095 = Percent of Mixed Race
top_25_by_percent(conn, race='Mixed Race', race_col='HD01_S095', percent_col='HD02_S095')
    
    
# HD01_S101 = Number of Blacks (one-race or mixed)
# HD02_S101 = Percent of Blacks (one-race or mixed)
top_25_by_percent(conn, race='African American', race_col='HD01_S101', percent_col='HD02_S101')
    
# HD01_S102 = Number of Native Americans (one-race or mixed)
# HD02_S102 = Percent of Native Americans (one-race or mixed)
top_25_by_percent(conn, race='Native American', race_col='HD01_S102', percent_col='HD02_S102')
    
# HD01_S103 = Number of Asians (one-race or mixed)
# HD02_S103 = Percent of Asians (one-race or mixed)
top_25_by_percent(conn, race='Asian', race_col='HD01_S103', percent_col='HD02_S103')

# HD01_S107 = Number of Hispanics (one-race or mixed)
# HD02_S107 = Percent of Hispanics (one-race or mixed)
top_25_by_percent(conn, race='Hispanic', race_col='HD01_S107', percent_col='HD02_S107')