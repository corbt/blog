---
layout: post
published: true
title: 'Puma vs. Unicorn &mdash; Performance'
comments: true
---

After [making our app thread-safe]({% post_url 2015-02-04-redis-reconnection-overhead %}) and transitioning to Puma, I've done a bit of benchmarking to see what effect, if any, the new server has on performance.

Using [Apache Bench](http://httpd.apache.org/docs/2.2/programs/ab.html), we can gather basic information about how our application responds under stress both before and after the transition. Since it was important to me to understand how the server would take the load before making any hard-to-undo changes to the production environment, the following tests were run on our staging server. It should have similar performance characteristics to our production servers, except it has less RAM (2GB instead of 4).

I configured both Unicorn and Puma to use two workers (processes). Puma additionally allows you to configure the minimum and maximum numbers of threads it will spawn, and I was interested in seeing how this might affect throughput. As shown below, I tested 3 different Puma configurations -- a maximum of 1, 2, and 16 (the default number) of threads.

The page I tested was a typical album view page, containing 8 video recordings. It's a good test because it contains a couple of calls to the database, as well as some server-side javascript rendered with the [react-rails](https://github.com/reactjs/react-rails) gem. It's also the most-visited page type on the production site. The test was run from the staging server directly to avoid any network latency. The `ab` commands used for testing took the following form:

    ab -n 100 -c 10 127.0.0.1:3000/mic-test-1scbld4eA7KfCFESbEH2h1oDY7U

`-n 100` indicates that we want 100 total connections to be made, and `-c 10` tells `ab` to attempt 10 connections at a time. This is the number I change to test different concurrency levels.


## Data

<div id="50_response"></div>
<div id="99_response"></div>

## Analysis

Median response time was statistically unchanged across all server variations. Interestingly, 99th-percentile performance is consistently better in Unicorn-land, especially when compared to the single-threaded Puma run, the closest thing to an apples-to-apples comparision. 

Although the MRI global interpreter lock (GIL) fundamentally limits what you can do with concurrency in the default Ruby implementation, I have to admit that I had hoped for more visible improvement with a multithreaded application server, especially with a page that calls out to the database and node.js, actions that should release the GIL while they're being processed. It just goes to show that there is no excuse not to test when making changes that could substantially affect the performance of your app.

Long term, our plans are still to switch to JRuby when JRuby 9000 comes out (hopefully in a few months). At that point I'll repeat these tests, and with a bit of luck its true concurrency will allow for a substantial performance improvement.

<script type="text/javascript">

  // Load the Visualization API and the piechart package.
  google.load('visualization', '1.0', {'packages':['corechart']});

  // Set a callback to run when the Google Visualization API is loaded.
  google.setOnLoadCallback(drawCharts);

  // Callback that creates and populates a data table,
  // instantiates the pie chart, passes in the data and
  // draws it.
  function drawCharts() {

    // Create the data table.
    var data50 = new google.visualization.arrayToDataTable([
      ['Concurrency', 'Unicorn', 'Puma 1 thread', 'Puma 0-2 threads', 'Puma 0-16 threads'],
      [            1,       552,             547,                548,                 544],
      [           10,      5686,            5543,               5758,                5074],
      [           30,     17332,           16568,              16834,               16000],
    ]);

    // Set chart options
    var options = {title: 'Median Response Time (lower is better)',
                   chartArea: {width: '70%'},
                   hAxis: {title: 'Concurrent Connections'},
                   vAxis: {title: 'Response Time (ms)'}};

    // Instantiate and draw our chart, passing in some options.
    var chart50 = new google.visualization.LineChart(document.getElementById('50_response'));
    chart50.draw(data50, options);

    // Create the data table.
    var data99 = new google.visualization.arrayToDataTable([
      ['Concurrency', 'Unicorn', 'Puma 1 thread', 'Puma 0-2 threads', 'Puma 0-16 threads'],
      [            1,       610,            1055,               1053,                1050],
      [           10,      6005,           11002,               7123,                9701],
      [           30,     17332,           20669,              18338,               19730],
    ]);

    // Set chart options
    options.title = '99th-Percentile Response Time (lower is better)';

    // Instantiate and draw our chart, passing in some options.
    var chart99 = new google.visualization.LineChart(document.getElementById('99_response'));
    chart99.draw(data99, options);
  }
</script>