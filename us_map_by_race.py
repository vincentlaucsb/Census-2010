'''
Uses race demographic data from the Census 2010 database to create maps 
and bar charts

Output: Several HTML files containing plotly map plots
 * us-asians.html
 * us-blacks.html
 * us-hispanics.html
 * us-mixed.html
 * us-natives.html
'''

from collections import OrderedDict
import statistics as stats
import sqlite3 as sql

import plotly.offline as py
import plotly.graph_objs as go

from settings import PLOTLY_MAP_LAYOUT

conn = sql.connect('census2010.db')

# Stores all relevant data pertaining to one race
class RaceData(OrderedDict):
    def __init__(self, race, race_col, percent_col, conn):
        '''
        Arguments:
         * race:        String specifying the race
         * race_col:    Raw number of x race in a place
         * percent_col: Percentage of place that is x race
         * conn:        An sqlite3 connection object
        '''
        
        # The nth item of any list corresponds to the nth row from the SQL database
        # bubble_size is not from the database --> created for plotly
        super(RaceData, self).__init__(
            population=[], absolute=[], percent=[], name=[], state=[],
            latitude=[], longitude=[], bubble_size=[])
        
        self.race = race
        self.conn = conn
        self.insert_sql_data(race_col, percent_col)
        self.upper_bounds = self.get_upper_bounds()
        self.border_widths = self.get_border_widths()
        self.colors = self.create_gradient()
        self.calc_bubble_size(largest_bubble=200)
        
    def __iter__(self):
        return self
        
    def __next__(self):
        try:
            return [self[key].pop() for key in self.keys()]
        except IndexError:  # Out of data
            raise StopIteration
        
    def insert_sql_data(self, race_col, percent_col):
        # Get requested SQL data and save it
        sql_data = self.conn.execute(
            '''SELECT HD01_S001, {absolute}, {percent}, NAME, USPS, INTPTLAT, INTPTLONG
               FROM places JOIN census2010 ON places.GEOID = census2010.GEOID
               WHERE HD01_S001 > 15000 ORDER BY {percent} ASC
            '''.format(absolute=race_col, percent=percent_col))
    
        for row in sql_data:
            self['population'].append(row[0])
            self['absolute'].append(row[1])
            self['percent'].append(row[2])
            self['name'].append(row[3])
            self['state'].append(row[4])
            self['latitude'].append(row[5])
            self['longitude'].append(row[6])
            
    def get_upper_bounds(self):
        '''
        Calculate upper bounds for traces based on these rules:
         * Separate data into seven traces
             * Trace 1: > 3 standard deviations from the mean...
             * Trace 2: 2-3 st devs from the mean...
             * Trace 3: 1-2 st devs from the mean
             * ...
             * Trace 7: < -3 st devs from mean
         * But, if necessary, remove traces so negative values do not appear
        '''

        mean = stats.mean(self['percent'])
        st_dev = stats.stdev(self['percent'])

        trace_bounds = [mean - i*st_dev for i in range(-3, 4)]
        
        # Remove negative bounds
        return [x for x in trace_bounds if x > 0] + [0]
        
    def get_border_widths(self):
        '''
        Create a list of border widths starting from 8 to 1
         * There should be as many border widths as there are traces
         * Places with higher concentrations should have thicker borders
         * Border widths should vary by a constant amount
        '''
        
        length = len(self.upper_bounds)
        
        current_width = 8
        border_widths = [current_width]
        
        width_delta = -6/(length - 2)
        
        for i in range(0, length - 2):
            current_width += width_delta
            border_widths.append(current_width)
            
        return border_widths + [1]
        
    def create_gradient(self):
        '''
        Create a gradient depending on how many colors are needed
         * There should be as many colors as there are traces
         * Places with lower concentrations should be lighter
        '''
        
        length = len(self.upper_bounds)
        
        # Yellow
        start = 'hsla(55, 100%, 50%, 1)'
        end = 'hsla(55, 100%, 100%, 0.4)'

        lightness_delta = 50/(length - 2)
        opacity_delta = -0.6/(length - 2)
        
        colors = [start]
        current_lightness = 50
        current_opacity = 1
        
        for i in range(0, length - 2):
            current_lightness += lightness_delta
            current_opacity += opacity_delta
            
            colors.append('hsla(55, 100%, {0}%, {1}%)'.format(
                           current_lightness, current_opacity))
            
        colors.append(end)
        
        return colors
        
    def calc_bubble_size(self, largest_bubble):
        '''
        Given the absolute number of x race living in a place, calculate
        its corresponding bubble size. The largest bubble will go to the
        city with the largest population.
        
        Arguments:
         * largest_bubble: Size of the largest bubble in pixels
        '''
        
        largest_pop = max(self['absolute'])
        
        def bubble_size(pop):
            # Return bubble size given population
            return pop/largest_pop * largest_bubble
        
        for value in self['absolute']:
            self['bubble_size'].append(bubble_size(value))

def create_data(data):
    '''
    Create a dictionary of data to be used by plotly's go.Figure()
    
    Arguments:
     * data: A RaceData object
    '''
    
    plotly_data = []
    
    for limit in data.upper_bounds:
        color = data.colors[data.upper_bounds.index(limit)]
        border_width = data.border_widths[data.upper_bounds.index(limit)]
    
        lat = []
        long = []
        text = []
        race_percent = []
        race_pop = []
        total_pop = []
        bubble_size = []

        for row in data:
            '''
            Notes:
             1. The data should be ordered by lowest percentages first
             2. Also, once a row is read from data it no longer exists
             
            Data is in this order:
             population=[], absolute=[], percent=[], name=[], state=[],
             latitude=[], longitude=[], bubble_size=[]
            '''
            if row[2] > limit:
                race_percent.append(row[2])
                race_pop.append(row[1])
                lat.append(row[5])
                long.append(row[6])
                text.append(str("{place}, {state}<br />Population: {pop})"
                                "<br />{race}: {race_pop} ({percent}% of "
                                "the population)").format(
                    place=row[3], state=row[4], race=data.race, race_pop=row[1], 
                    percent=row[2], pop=row[0]))
                bubble_size.append(row[7])
            else:
                break
        
        trace = {
            "lat": lat,
            "lon": long,
            "text": text,
            "type": 'scattergeo',
            "marker": {
                "color": color, # Documentation has a typo?
                "size": bubble_size,
                "line": {
                    'color': 'rgba(50, 50, 59, 0.8)',
                    'width': border_width,  # Vary border line width
                }
            },
            "name": ">{0}%".format(round(limit,1))
        }
        
        plotly_data.append(trace)
        
    return plotly_data

# HD01_S095 = Number of Mixed Race
# HD02_S095 = Percent of Mixed Race 
fig_mixed = go.Figure(
    data=create_data(RaceData(race='Mixed Race', race_col='HD01_S095',
        percent_col='HD02_S095', conn=conn)),
    layout=PLOTLY_MAP_LAYOUT)
    
py.plot(fig_mixed, filename='us-mixed.html')

# HD01_S101 = Number of Blacks (one-race or mixed)
# HD02_S101 = Percent of Blacks (one-race or mixed)
fig_blacks = go.Figure(
    data=create_data(RaceData(race='Blacks', race_col='HD01_S101',
        percent_col='HD02_S101', conn=conn)),
    layout=PLOTLY_MAP_LAYOUT)
    
py.plot(fig_blacks, filename='us-blacks.html')

# HD01_S102 = Number of Native Americans (one-race or mixed)
# HD02_S102 = Percent of Native Americans (one-race or mixed)
fig_natives = go.Figure(
    data=create_data(RaceData(race='Native Americans', race_col='HD01_S102',
        percent_col='HD02_S102', conn=conn)),
    layout=PLOTLY_MAP_LAYOUT)
    
py.plot(fig_natives, filename='us-natives.html')

# HD01_S103 = Number of Asians (one-race or mixed)
# HD02_S103 = Percent of Asians (one-race or mixed)
fig_asians = go.Figure(
    data=create_data(RaceData(race='Asians', race_col='HD01_S103',
        percent_col='HD02_S103', conn=conn)),
    layout=PLOTLY_MAP_LAYOUT)
    
py.plot(fig_asians, filename='us-asians.html')

# HD01_S107 = Number of Hispanics (one-race or mixed)
# HD02_S107 = Percent of Hispanics (one-race or mixed)
fig_hispanics = go.Figure(
    data=create_data(RaceData(race='Hispanics', race_col='HD01_S107',
        percent_col='HD02_S107', conn=conn)),
    layout=PLOTLY_MAP_LAYOUT)
    
py.plot(fig_hispanics, filename='us-hispanics.html')

conn.close()