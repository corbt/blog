---
layout: post
published: true
title: World Temperatures
description: Although there are many aspects of culture and lifestyle in those areas that are hard to compare directly, climate is an easy one. This interactive map contains data points from over 2700 meteorological stations worldwide.
---
I've lived in Barcelona, Seattle and Utah, and will be moving to the UK soon. Although many aspects of the culture and lifestyle in those areas are hard to compare directly, climate is an easy one.

This interactive map contains data points from over 2700 meteorological stations worldwide. The data was collated by the US National Oceanic and Atmospheric Administration (NOAA), which provides a number of interesting data sets.

I set the color of each marker based on its similarity to other markers in the dataset. For example, since the UK and the Pacific Northwest of the US experience similar temperatures during a typical year, they both appear in the same color.

By clicking on a marker, you can see the minimum, maximum and average monthly temperatures of that station, averaged over the last 15 years.

<iframe src="//corbt.s3.amazonaws.com/weather/viz/map.html" style="width:100%;height:500px;border:0;"></iframe>
[(fullscreen)](http://corbt.s3-website-us-east-1.amazonaws.com/weather/viz/map.html)

Read on to learn more about how this graphic was created. I've released the source on [Github](https://github.com/kcorbitt/city-weather), so feel free to follow along!

### Finding and Parsing the Data

Finding the right dataset was critical. I investigated a few commercial sources, such as [WeatherUnderground](http://www.wunderground.com/) (I've used their API in the past to gather real-time weather information) and [Weatherbase](http://www.weatherbase.com/). Unfortunately, the breadth of data I needed either wasn't available or was uneconomical. I also investigated NASA's [GISS](http://www.giss.nasa.gov/) datasets, but they appeared to be too macro and processed for a study like this. Finally, I came across the [GHCN Monthly data](http://www.ncdc.noaa.gov/ghcnm/), provided by the National Climatic Data Center, a division of NOAA.

This dataset includes month-by-month minimum, maximum and mean temperatures at thousands of stations worldwide. the US government partners with other organizations to gather the raw data, transforms it using a well-documented normalization process, and publishes the averages periodically. I grabbed the post-normalization datasets for minimum, maximum and mean temperatures that were published on April 22, 2014.

The data is provided in a fixed-column format, which I parsed into a more workable CSV file in [preprocess.py](https://github.com/kcorbitt/city-weather/blob/master/preprocess.py).

### Aggregation and Analysis

I'm more interested in average temperatures than month-by-month values going back in some cases over a hundred years, so I used [Pandas](http://pandas.pydata.org/) to find the average minimum, maximum and mean temperature for each month. Each data entry was of the form `[station ID],[Year],[Jan min],[Jan max],[Jan mean],[Feb min],[Feb max],[Feb mean]...`. Pandas's `groupby` function allowed me to group by the station ID and then simply find the average temperature for each cell across all years. From [aggregate.py](https://github.com/kcorbitt/city-weather/blob/master/aggregate.py):

{% highlight python %}
data = data.groupby(by='id').mean().drop('year',axis=1)
{% endhighlight %}

### Clustering

I wanted similar climates to be visually similar on the map, so I used a clustering algorithm to find data points whose temperature readings matched well. [K Means](http://en.wikipedia.org/wiki/K-means_clustering) is a simple algorithm that is reasonably scalable and robust. I used an optimized implementation from [Scikit-learn](http://scikit-learn.org/stable/modules/generated/sklearn.cluster.MiniBatchKMeans.html), which was able to cluster nearly 2800 points in less than 5 seconds. The only parameter that I  had to set is the number of desired clusters, which I chose as an arbitrary 10. Those clusters are reflected in the colors of the markers for each datapoint.

Additionally, before clustering I rotated the temperature readings in the southern hemisphere by 6 months. This allowed temperatures in both hemispheres to be compared directly. As a result areas with similar climates offset by 6 months, such as California and southern Australia, are grouped together. This code is all found in [cluster.py](https://github.com/kcorbitt/city-weather/blob/master/cluster.py).

### Mapping

The final step was to map my findings. I first experimented with [basemap](http://matplotlib.org/basemap/), but was put off by its overly complex API and lack of interactivity. I finally settled on [folium](https://folium.readthedocs.org/en/latest/) for the maps with [vincent](http://vincent.readthedocs.org/en/latest/) for the pop-up charts. The API is refreshingly simple, and the generated javascript graphics are beautiful. However, functionality is very limited and it's probably best saved for very simple charts with limited customization. [(code)](https://github.com/kcorbitt/city-weather/blob/master/map_points.py)