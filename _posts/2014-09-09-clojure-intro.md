---
layout: post
published: false
title: Clojure Intro
---

I moved to London a few weeks ago, and as a result of unavoidable delays (and a few avoidable ones) my wife and I have found ourselves without internet access at home. As a result, I've been working from her university, or sometimes the local library. However, today I had to spend the whole morning at home waiting for a package to arrive. When your day job involves web development it can be pretty hard to find 4 hours of solid work to do that doesn't involve an internet connection at all. As a result, I decided to download some tutorials beforehand and take the morning off to learn something about [Clojure](http://clojure.org/).

I'm not completely new to functional programming (I've used [Racket](http://racket-lang.org/)), but it has been a while since I've used it for anything and even among the lisps there is some difference in function names and idiomatic use. I decided to start by implementing a very simple factorial program just to get back in the mood of functional programming. I had [a clojure introduction](http://java.ociweb.com/mark/clojure/article.html) open, but rather than reading through it I just `ctrl-F`'d it when necessary. The first implementation I came up with that actually ran looked as follows:

{% highlight clojure %}
(def popsicle-map
  {:red :cherry, :green :apple, :purple :grape}) ; same as previous

(doseq [[color flavor] popsicle-map]
  (println (str "The flavor of " color
    " popsicles is " (name flavor) ".")))
{% endhighlight %}