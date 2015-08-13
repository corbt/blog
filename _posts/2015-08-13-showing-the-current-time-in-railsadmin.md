---
layout: post
published: true
title: Showing the current time in rails_admin
comments: true
---

At Emberall we use [rails_admin](https://github.com/sferik/rails_admin) as an easy way to administer data in our backend. It's convenient because it gives us a visual way to edit data and fix customer issues that any employee can use without having to learn SQL.

A minor inconvenience that we've run into is the necessity of doing time zone calculations in our heads as part of normal usage. Our servers are set to the "America/Los_Angeles" timezone, but we have employees in several timezones (and I'm currently based out of London!). When a customer calls in saying that their recorder isn't syncing, it's very helpful to be able to look at our data and see when the last successful sync was.

To avoid having to mentally translate that timestamp into the current timezone, I've configured our admin interface to show the server's local time as part of the rails_admin header. To add this to your own configuration, just add the following to your rails_admin initializer.

```ruby
RailsAdmin.config do |config|
  config.main_app_name = Proc.new {
    ["Emberall Admin", "(#{Time.zone.now.to_s(:time)})"]
  }
end
```