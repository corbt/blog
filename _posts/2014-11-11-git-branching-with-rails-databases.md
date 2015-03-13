---
layout: post
published: true
comments: true
title: Git Branching with Rails
---

As [emberall.com](https://emberall.com) has grown in the last few months, I've had to implement some new processes to make sure the development flow can scale as well. When we only had a couple of active users it was no problem if a bad deploy took the production server offline for an hour while I got around to fixing the issue, but now that we've grown and have real, paying users, that kind of approach to downtime doesn't cut it anymore. These days I have a better defined process surrounding deployments, including a full suite of functional tests that have to pass before a deploy goes live on production. We also recently configured a staging server to perform manual testing of prospective changes before pushing them live.

Inspired loosely by [A Successful Git Branching Model](http://nvie.com/posts/a-successful-git-branching-model/), the current version of the code on the git `master` branch is automatically deployed to the production server. Likewise, the `develop` branch is automatically pushed to staging. In local development we work off of feature branches that are then merged into `develop` (and eventually `master`).

While this is a good approach, we quickly ran into two issues:

1. When switching branches, the application code for the new branch is autoloaded but initializers aren't run.
2. A non-backwards-compatible database migration in a feature branch could cause trouble for the code on another branch that doesn't know how to deal with it.

## Git hooks to reload code

After a bit of investigation of [git hooks](http://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) the first problem was easy to solve. We do all our development inside a vagrant VM and use [upstart](http://upstart.ubuntu.com/) to run our rails server in development. A simple executable script to restart the upstart service after checking out a new branch ensures that we're always using the correct version of the code.

{% highlight bash %}
#! /bin/sh
# .git/hooks/post-commit
# Restart rails on checkout to load any potentially changed files

sudo service rails restart >> /vagrant/log/development.log &
{% endhighlight %}
*Note the ampersand at the end of the line -- this is just so the command doesn't block, and we can continue working at the terminal while the rails server is restarting.*

## Per-branch databases

The second issue we had with this setup surrounded [database migrations](http://guides.rubyonrails.org/migrations.html). Large features can be developed for a week or more on their own branch before being merged back in. If those features include incompatible database migrations switching to another branch can cause trouble because the database won't be in the state the app expects. One potential solution would be to destroy all data and reseed the database when switching branches, but this takes a long time and seems like overkill. Instead, we decided to (only in development) dynamically switch database versions based on the current branch.

Rails makes this easy by allowing for erb template syntax in the `database.yml` file. To make this work, you need the `git` gem in your Gemfile. Then the following `database.yml` template can take into account the git branch when determining the current database name.

{% highlight yaml %}
<% git_branch = ENV['GIT_BRANCH'] || Git.open('.').current_branch %>
<% db_base = "app_#{Figaro.env.flavor!}_#{git_branch}" %>

development:
  adapter: postgresql
  encoding: utf8
  database: <%= db_base %>

test:
  adapter: postgresql
  encoding: utf8
  database: <%= db_base %>_test
{% endhighlight %}