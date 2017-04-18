''' Variables and functions shared between scripts '''
   
# Constants
PLOTLY_MAP_LAYOUT = {
    'margin': {
        'b': 0,
        'l': 0,
        'r': 0,
        't': 0,  # Omit title
        'autoexpand': False
        },
    'showlegend': True,
    'geo': {
        'scope': 'usa',
        'bgcolor': 'hsla(81, 8%, 90%, 1)',
        'landcolor': 'rgb(175, 204, 128)',
        'lakecolor': 'rgb(111, 138, 204)',
        'rivercolor': 'rgb(111, 138, 204)',
        'subunitcolor': 'rgb(255, 251, 211)',
        'showland': True,
        'showocean': True,
        'showsubunits': True,
        'showlakes': True,
        'showrivers': True,
        'lataxis': {
                'showgrid': True,
                'dtick': 5,
                'gridcolor': 'rgba(35, 35, 41, 0.05)'
            },
        'lonaxis': {
                'showgrid': True,
                'dtick': 4,
                'gridcolor': 'rgba(35, 35, 41, 0.05)'
            }
        },
    'paper_bgcolor': 'rgba(0, 0, 0, 0)',
    'plot_bgcolor': 'rgba(0, 0, 0, 0)'
}