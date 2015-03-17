---
layout: post
published: true
title: ClojureScript in Rails
comments: true
---

Since I wasn't able to find any information online on the best way to integrate Clojurescript into the Rails asset pipeline, I've decided to write up our experiences here. If you've found a more straightforward way to accomplish this, please feel free to chime in in the comments!

## ClojureScript environment

This guide will assume you're using Boot to compile your .cljs files, but a similar setup should be possible with Leiningen. 

The first step is to decide where to keep the ClojureScript source in our project. The cljs build process creates several .js files that need to be accessible from the rails-served environment in development, but there is only *one* file that needs to be included in production -- the generated `target/main.js`. We'll take advantage of that fact when we set up the asset pipeline. In Rails land, `app/assets/javascripts/cljs` might seem like a logical location, but the following excerpt from the [Ruby on Rails guide](http://guides.rubyonrails.org/asset_pipeline.html) makes it clear why this is a bad idea:

> The default matcher for compiling files includes application.js,
> application.css and all non-JS/CSS files (this will include all image assets
> automatically) from app/assets folders


By including our assets in the normal `app/assets` path, Rails will create digested versions of all of them. While this may or may not cause trouble, it would certainly slow down asset precompilation.

With that in mind, we've chosen to keep our ClojureScript source in the `lib/assets/cljs` folder. This can still be explicitly accessed by the asset pipeline as we'll need to do later on, but only the file we care about will be precompiled in production.

Withing the `lib/assets/cljs` folder, set up your directory structure like a normal boot-based cljs project.

    lib
    ├── assets
    │   └── cljs
    │       ├── build.boot
    │       ├── src
    │       │   └── core
    │       │       ├── my_file.cljs
    │       │       └── other_file.cljs

You shouldn't need to do anything special with your `build.boot`. Here is ours for reference:

~~~ clojure
(set-env!
 :source-paths   #{"src"}

 :dependencies '[[adzerk/boot-cljs      "0.0-2814-3" :scope "test"]
                 [adzerk/boot-cljs-repl "0.1.9"      :scope "test"]
                 [adzerk/boot-reload    "0.2.6"      :scope "test"]

                 [reagent "0.5.0" :exclusions [cljsjs/react]]])

(require
 '[adzerk.boot-cljs      :refer [cljs]]
 '[adzerk.boot-cljs-repl :refer [cljs-repl start-repl]]
 '[adzerk.boot-reload    :refer [reload]])

(deftask dev
  "Watch/compile clojurescript files in development"
  []
  (comp
    (watch)
    (cljs-repl)
    (cljs :source-map true
          :optimizations :none)))

(deftask prod
  "Compile clojurescript files for production"
  []
  (comp
    (cljs :optimizations :advanced
          :compiler-options {:output-wrapper
                             :true})))
~~~

We define two tasks above:
  
 * **dev** starts a file watcher and compiles ClojureScript during development. We leave this task running in the background while developing.
 * **prod** compiles all the clojurescript files with advanced optimizations for production use. We run this task right before `rake assets:precompile` as part of our release process.

## Rails Environment

You'll need to make a few tweaks to your Rails project to successfully detect and load the javascript that boot generates. First, add ClojureScript's generated `main.js` to your application layout. I recommend adding it as a separate script, rather than including it in `application.js`. Some of the module-loading code on the cljs side of things assumes that your script is named `main.js`, so keeping it separate means less hassle.

This means that if you're using ERB for your `application.html` layout, you can just add the following line right above or below wherever you include `application.js`:

~~~ erb
<script src=<%= asset_path('target/main.js') %> ></script>
~~~

As mentioned, some ClojureScript autoload code depends on being in a file called `main.js`. Since the Rails asset pipeline adds md5 digests to the end of asset names, this fails. To fix this, we need to turn off the md5 digest in development (in production no autoloading is used, so this doesn't matter).

~~~ ruby
# config/environments/development.rb

config.assets.digest = false
~~~

### Preparing for Deployment

We need to inform rails that there is a new file that needs to be precompiled as part of the deployment process -- `target/main.js`. The asset pipeline already knows to look in `lib/assets/*/` for assets to precompile, so we just need to give it the name relative to that directory.

~~~ ruby
# config/initializers/assets.rb
Rails.application.config.assets.precompile += %w( target/main.js )
~~~

That's all the setup you need! Now you just need to remember to compile your ClojureScript before running `rake assets:precompile`. This will generate the `target/main.js` file that the asset pipeline will look for as part of its compilation process. We use a custom ansible-based deployment process, but adding this as a custom step in capistrano or whatever you use to manage your deploys should be fairly simple.

### Bonus: .gitignore

I recommend gitignoring all of the generated ClojureScript files. We've added the following lines to our project .gitignore:

    .nrepl-history
    .nrepl-port
    target/
    .repl/