# coding=utf-8
# Get this figure: fig = py.get_figure("https://plot.ly/~mmdemirbas/2/")
# Get this figure's data: data = py.get_figure("https://plot.ly/~mmdemirbas/2/").get_data()
# Add data to this figure: py.plot(Data([Scatter(x=[1, 2], y=[2, 3])]), filename ="API Gateways Comparison", fileopt="extend")
# Get y data of first trace: y1 = py.get_figure("https://plot.ly/~mmdemirbas/2/").get_data()[0]["y"]

# Get figure documentation: https://plot.ly/python/get-requests/
# Add data documentation: https://plot.ly/python/file-options/

# If you're using unicode in your file, you may need to specify the encoding.
# You can reproduce this figure in Python with the following code!

# Learn about API authentication here: https://plot.ly/python/getting-started
# Find your api_key here: https://plot.ly/settings/api

import plotly.plotly as py
from plotly.graph_objs import *
py.sign_in('username', 'api_key')
trace1 = {
    "y": ["6765.27", "8898.05", "9588.27", "11097.88", "9161.71", "8040.01", "8066.28", "9441.21", "9771.39"],
    "connectgaps": False,
    "hoverinfo": "y+name",
    "line": {"shape": "spline"},
    "marker": {"color": "rgb(31, 119, 180)"},
    "mode": "lines+markers",
    "name": "spring-local",
    "showlegend": True,
    "type": "scatter",
    "uid": "e783f7",
    "visible": "legendonly",
    "ysrc": "mmdemirbas:0:978dc0"
}
trace2 = {
    "y": ["18886.91", "18886.91", "18886.91", "18886.91", "18886.91", "18886.91", "18886.91", "18886.91", "18886.91"],
    "connectgaps": False,
    "hoverinfo": "y+name",
    "line": {"shape": "spline"},
    "marker": {"color": "rgb(255, 127, 14)"},
    "mode": "lines+markers",
    "name": "no-proxy-local",
    "showlegend": True,
    "type": "scatter",
    "uid": "03c877",
    "visible": "legendonly",
    "ysrc": "mmdemirbas:0:807251"
}
trace3 = {
    "y": ["8242.70", "10517.41", "9958.72", "9596.69", "9249.86", "8616.46", "10187.52", "8828.40", "8832.72"],
    "connectgaps": False,
    "hoverinfo": "y+name",
    "line": {"shape": "spline"},
    "marker": {"color": "rgb(44, 160, 44)"},
    "mode": "lines+markers",
    "name": "linkerd-local",
    "showlegend": True,
    "type": "scatter",
    "uid": "8b5318",
    "visible": "legendonly",
    "ysrc": "mmdemirbas:0:bf1089"
}
trace4 = {
    "y": ["4326.09", "6206.92", "6560.39", "6353.69", "5587.75", "5316.02", "6041.99", "6324.25", "6140.60"],
    "connectgaps": False,
    "hoverinfo": "y+name",
    "line": {"shape": "spline"},
    "marker": {"color": "rgb(214, 39, 40)"},
    "mode": "lines+markers",
    "name": "zuul-local",
    "showlegend": True,
    "type": "scatter",
    "uid": "cf59df",
    "visible": "legendonly",
    "ysrc": "mmdemirbas:0:04bdd9"
}
trace5 = {
    "y": ["1429.82", "2260.59", "3095.24", "3181.24", "3213.85", "3243.90", "3177.61", "3226.99", "3190.95"],
    "connectgaps": False,
    "hoverinfo": "y+name",
    "line": {"shape": "spline"},
    "marker": {"color": "rgb(148, 103, 189)"},
    "mode": "lines+markers",
    "name": "spring-ec2",
    "showlegend": True,
    "type": "scatter",
    "uid": "e77406",
    "ysrc": "mmdemirbas:1:f2ca0c"
}
trace6 = {
    "y": ["18081.60", "18081.60", "18081.60", "18081.60", "18081.60", "18081.60", "18081.60", "18081.60", "18081.60"],
    "connectgaps": False,
    "hoverinfo": "y+name",
    "line": {"shape": "spline"},
    "marker": {"color": "rgb(140, 86, 75)"},
    "mode": "lines+markers",
    "name": "no-proxy-ec2",
    "showlegend": True,
    "type": "scatter",
    "uid": "9560ec",
    "visible": "legendonly",
    "ysrc": "mmdemirbas:1:7eea91"
}
trace7 = {
    "y": ["1632.64", "2122.27", "2976.03", "3261.69", "3348.86", "3357.71", "3323.00", "3372.09", "3348.44"],
    "connectgaps": False,
    "hoverinfo": "y+name",
    "line": {"shape": "spline"},
    "marker": {"color": "rgb(227, 119, 194)"},
    "mode": "lines+markers",
    "name": "linkerd-ec2",
    "showlegend": True,
    "type": "scatter",
    "uid": "66c71d",
    "ysrc": "mmdemirbas:1:a6c48c"
}
trace8 = {
    "y": ["498.93", "690.66", "852.39", "1172.84", "1221.32", "1112.02", "1211.82", "1178.10", "1194.99"],
    "connectgaps": False,
    "hoverinfo": "y+name",
    "line": {"shape": "spline"},
    "marker": {"color": "rgb(127, 127, 127)"},
    "mode": "lines+markers",
    "name": "zuul-ec2",
    "showlegend": True,
    "type": "scatter",
    "uid": "dd3a4c",
    "ysrc": "mmdemirbas:1:a8f50b"
}
data = Data([trace1, trace2, trace3, trace4, trace5, trace6, trace7, trace8])
layout = {
    "autosize": True,
    "boxmode": "group",
    "dragmode": "pan",
    "hovermode": "x",
    "scene": {
        "aspectmode": "auto",
        "aspectratio": {
            "x": 1,
            "y": 1,
            "z": 1
        }
    },
    "showlegend": True,
    "title": "API Gateways Comparison",
    "xaxis": {
        "autorange": True,
        "range": [-0.493198771391, 8.49319877139],
        "rangeslider": {"visible": False},
        "showspikes": False,
        "title": "Successive Runs"
    },
    "yaxis": {
        "autorange": True,
        "range": [303.712319358, 3567.30768064],
        "showspikes": False,
        "title": "Requests/sec",
        "type": "linear"
    }
}
fig = Figure(data=data, layout=layout)
plot_url = py.plot(fig)
