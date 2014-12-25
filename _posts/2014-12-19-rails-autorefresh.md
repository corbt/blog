---
layout: post
published: true
title: Rails Auto-Refresh
comments: true
---

In my [last post]({% post_url 2014-12-18-clojure-for-rails-programmers %}) I discussed some of the attractive elements of the Clojure ecosystem. The primary KapShare app is still written in Rails and that's still where most development happens, so I decided to take some time to enable the auto-refresh functionality built into Clojure's [Ring](https://github.com/ring-clojure). Rails already gets us halfway there by automatically reloading updated files on the server, but by following these steps any open pages will also automatically refresh when code is updated in development.

### Installing the Gems
Add the following two gems to your `Gemfile`, then run `bundle` and `bundle binstub guard`:
{% highlight ruby %}
# Gemfile
group :development do 
  gem 'rack-livereload'
  gem 'guard-livereload', require: false
end
{% endhighlight %}

### Configuring Rails
The `rack-livereload` gem takes care of bundling [livereload.js](https://github.com/livereload/livereload-js) and injecting it into all HTML pages served in development. To configure it, add the following lines to your environment:
{% highlight ruby %}
# config/environments/development.rb
Rails.application.configure do
  config.middleware.use(Rack::LiveReload, source: :vendored)
end
{% endhighlight %}

For the full list of configuration options see [rack-livereload](https://github.com/johnbintz/rack-livereload).

Restart Rails, and verify that `livereload.js` is correctly included in your HTML pages. Note that at this point your page should be trying to open a websocket to port 35729 unsuccessfully; we'll fix that in the next step.

### Configuring Guard
Configure [Guard](https://github.com/guard/guard) to watch your `views` and `assets` folder. I modified the default `guard-livereload` template slightly to indicate that all of my SCSS files get included into `application.css`, even in development. Other than that, this is the default Guard livereload configuration.

{% highlight ruby %}
guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  
  # This is where I tell Guard that any .css file should be 
  # treated as a change to application.css
  watch(%r{(app|vendor)(/assets/\w+/(.+\.css)).*}) do |m| 
    "/assets/application.css"
  end
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(js|html|png|jpg))).*}) do |m| 
    "/assets/#{m[3]}"
  end
end
{% endhighlight %}

### Running Guard
If you binstubbed Guard above you should now be able to run it simply with the `bin/guard` command. If all goes well, as long as Guard is running making a change to a view or asset file will now automatically refresh the page with the new file!

### Caveats

* We use Vagrant virtual machines for development, and Guard doesn't pick up on filesystem changes for shared folders or remote NFS mounts. I got around this by using Vagrant's relatively new [rsync](https://www.vagrantup.com/blog/feature-preview-vagrant-1-5-rsync.html) folder-sharing strategy. This actually improves performance compared to NFS or a shared folder in Virtualbox, but does introduce a second or two of lag in synchronization.
* If you use HTTPS in development (for example, to check that HTTPS is forced for certain routes) LiveReload will fail in Chrome because it attempts to open an unencrypted `ws://` websocket channel to the livereload server which is blocked for security reasons. From what I can tell guard-livereload doesn't currently support TLS-secured websockets. If this is important to you, it should be possible to use [stunnel](http://blog.heidt.biz/blog/2012/07/19/ssl-websocket-proxy-with-stunnel-howto/) as the websocket TLS termination and then pass the connection on to livereload.

### Bonus -- Livereload for Jekyll
Just for fun, I've also enabled livereload on this Jekyll-powered blog, which was quite straightforward (the only slightly tricky bit was using a custom Liquid template to include the Livereload javascript only in development). You can find all the source [here](https://github.com/corbt/blog).