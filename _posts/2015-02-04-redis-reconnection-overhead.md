---
layout: post
published: true
title: Redis Reconnection Overhead
comments: true
---
For our main Rails application, we're currently migrating from the process-based [Unicorn](http://unicorn.bogomips.org/) server to the thread-focused [Puma](http://puma.io/). This should allow us to serve more requests with a smaller memory footprint, and paves the way for a possible future transition to [JRuby](http://jruby.org/), which can benefit from true multi-thread concurrency.

As part of the transition, we need to make sure that the entire application is thread-safe. Most of the app already is, but we use Redis in a few places including page caching, and are currently using a single connection in a non-thread-safe global way.

One solution would be to replace every reference to the global `$cache` object with a call to `Redis.new`. This would definitely be thread-safe, but would involve creating a new connection to the Redis server every time we need to access the cache. To see whether the overhead of creating this connection is a problem or not, I ran the following benchmark. It simply `set`s 50,000 keys in Redis, first by reusing a single connection 50,000 times and second by creating 50,000 separate connections and using each one once (the Redis server appears to close down these connections once it hits a certain limit -- the total number of open connections never exceeded about 300 in my test).

{% highlight ruby %}
require 'benchmark'
require 'redis'

n = 50000
r = Redis.new
Benchmark.bm(10) do |x|
  x.report('reuse redis') { (0..n).each { |i| r.set(i, i+5) }}
  x.report('new redis')   { (0..n).each { |i| Redis.new.set(i, i+5) }}
end
{% endhighlight %}

### The results:

                     user     system      total        real
    reuse redis  1.700000   0.970000   2.670000 (  2.827811)
    new redis    6.010000   3.340000   9.350000 (  9.580777)

In the simple case of `set`ing a single key with a redis instance running on localhost, recreating the connection each time adds over 200% total overhead. Looks like we'll be looking for some way to reuse a Redis connection in a thead-safe way after all.