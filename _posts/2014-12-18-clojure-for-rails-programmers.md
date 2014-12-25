---
layout: post
published: true
title: Clojure for Rails Programmers
comments: true
---

I've been experimenting with Clojure for a new product we're working on at [KapShare](http://kapshare.com). We're already using [React](http://facebook.github.io/react/) fairly extensively in our front-end code in the main app, and I became intrigued by the possibilities of [Reagent](https://github.com/reagent-project/reagent), a ClojureScript wrapper for the framework. 

As the design of the product evolved we decided to go with a native Android app for the frontend instead of a web app, backed by a simple API-focused backend. Since it's a small, standalone service I decided it was low-risk enough to implement the backend in Clojure anyway, and take advantage of the opportunity to learn a new language and paradigm.

I finished the app this week and it's in private beta now. Obviously, it's too early for me to tell how maintainability and reliability will play out over the long term. However, after about 2 weeks of development and immersion in the Clojure ecosystem (and worldview!), I'd like to record my experience.

## Pure Functions
There are some domains where a objects-encapsulating-state paradigm makes a lot of sense. Serving web requests is not one of them. HTTP requests are self-contained and mostly stateless, the perfect application for a language based on [pure functions](http://blogs.msdn.com/b/ericwhite/archive/2006/10/03/pure-functions.aspx). Pure functions are easy to understand -- they're just functions that rely exclusively on their explicit inputs, rather than any global or object-level state, and which don't affect the world in any way apart from the output they produce.

One big benefit of pure functions in a dynamically typed language like Clojure is that they're really easy to compose and reuse -- just by looking at a function's signature and/or implementation it's straightforward to tell whether it applies. Additionally, using pure functions enables and simplifies reasoning about the concurrency and rapid prototyping I'll discuss below.

## Effortless Concurrency
The Clojure backend receives a photo from the Android kiosk that needs to be persisted to S3. In Rails, it would be very bad practice to perform the S3 upload on the same thread as the request, in part because common servers like [Unicorn](http://unicorn.bogomips.org/) block the whole Ruby process for the duration of a request, leading to low throughput and queued requests[^unicorn]. With Clojure, requests are processed by a pool of very lightweight threads, so blocking for the duration of one is much less of a big deal.

### ...And Queuing
Of course, even though we *can* block for an entire request in Clojure it's still not ideal. In this case the upload to S3 doesn't need to complete before the server acknowledges the request, so it would be better to shunt it off to the background. In Rails, this would typically involve installing a task runner like [Sidekiq](https://github.com/mperham/sidekiq), running a background Ruby process to run the jobs and Redis to queue them, and then defining a special Task class that actually contains the upload logic. In Clojure, there's a better way. Since tasks can easily be run in another thread in the same process, we sidestep the need for a separate synchronization server and task-runner process. Using `future`, running a process on a background thread is literally as easy as changing.
{% highlight clojure %}
(when (:image data)
  (upload-image (-> data :image :tempfile) slug))
{% endhighlight %}

to 

{% highlight clojure %}
(when (:image data)
  (future (upload-image (-> data :image :tempfile) slug)))
{% endhighlight %}

That's it -- the image is now uploaded in the background[^background].

## Everything is a REPL
As far as I can tell, Lisp invented the idea of the [REPL](http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop). REPLs are an important feature of other modern scripting languages like Python and Ruby, but they're uniquely well suited to purely functional languages. Since a function's inputs tend to be explicit and limited, they can be called straight from the REPL without having to build up surrounding state.

### REPLs are Better when Bigger
The two most common Clojure editors are Emacs with [SLIME](http://en.wikipedia.org/wiki/SLIME) and the newer [Light Table](http://lighttable.com/). Both have interaction modes that leverage the REPL environment in the editor itself. Any buffer or file can easily be processed as a REPL and be completely reevaluated at each keystroke, using a transparent connection to a Clojure environment with all the app's dependencies preloaded. In Light Table, this technique is called an "InstaREPL." Compared to the save-reload-test workflow typical with Rails, the instant feedback is a real boost to productivity.

### Even the App is a REPL
The REPL philosophy is visible in the standard tools as well. Clojure's most popular HTTP middleware library, [Ring](https://github.com/ring-clojure/ring), has tooling to make feedback in development as quick as possible. In addition to automatically reloading changed files, it can be configured, in development, to automatically inject a javascript file into all HTML pages that polls for changes and refreshes the page when a new version is available. This makes for an incredibly efficient workflow that allows changes to be implemented and previewed without ever leaving the editor. Web development with this feature enabled is like instantly activating an unobtrusive WYSIWYG mode. 

## Conclusion
We won't be switching our existing codebase over from Rails anytime soon. However, for new projects Clojure has proved its worth and will certainly be a serious contender.

## Footnotes
[^unicorn]: Other Ruby servers like [Puma](http://puma.io/) use threads instead of or in addition to processes. However, the default MRI Ruby implementation has a global interpreter lock anyway, so the upside is limited. Clojure's standard functions and data structures are all designed for high-performance concurrency from the start so there is a lot more to gain with threads.

[^background]: Since we're not tracking what happens with this job, we'll only find out if it fails through a log message. More sophisticated background processing and tracking can be built on top of Clojure's [core.async](https://github.com/clojure/core.async).