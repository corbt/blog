About the Blog
==============

This blog covers topics interesting to me, including entrepreneurship and software development. It can be found online at [my site](https://corbt.com)

About Me
========

I'm a recent college graduate from BYU. Although I'm originally from Seattle, my wife is currently studying at Queen Mary University of London, so we're located in the UK until further notice.

In May of 2014 my friend [Sam](https://www.linkedin.com/profile/view?id=121107913) and I started a new company, [KapShare](http://kapshare.com). (you'll notice, not coincidentally, a substantial narrowing of focus of my blog posts after that date). We're currently developing mobile video recording technology for weddings, funerals, corporate events, and other applications. You can see what we're up to at [kapshare.com](https://kapshare.com).

I can be contacted at kyle@ this domain.

Using this Repository
=====================

I make no guarantees about the suitability of this code for anything more than running my personal blog. However, in the interest of documentation, the usage instructions are as follows.

Installation
------------

```
git clone git@github.com:corbt/blog.git
bundle install
```

Commands
--------

* `rake np Some Title Here`: generates a new post in the _posts/ directory
* `guard`: Runs a local webserver serving the blog (port 4000 by default) and compiles all blog files with autorefresh and autoreload enabled
* `rake push`: Uses rsync to update the server-side blog with local changes.