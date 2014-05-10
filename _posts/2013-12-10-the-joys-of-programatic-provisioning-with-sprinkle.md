---
layout: post
published: true
title: The Joys of Programatic Provisioning (with Sprinkle)
---
About 8 months ago now I decided it would be handy to have my own server in the cloud, in addition to the limited resources provided by my university and the I'm-still-not-sure-if-I'm-allowed-to-use-it server in the research lab I was part of on campus.  Over the next month or so [corbt.com](http://corbt.com) was born.

I dislike DevOps as much as the next guy so I considered a couple of PaaS platforms like Heroku and DotCloud, but decided on a true VPS because I wanted the flexibility of controlling my own server.  I ended up renting a $5 box on DigitalOcean, which was enough to host this site as well as run a few long-running projects and other background tasks that I wanted hosted in the cloud.

As I began setting the box up I quickly decided that installing everything by hand wasn't a ton of fun and began looking at different provisioning toolboxes.  I started out by messing around with [Chef](http://opscode.com/chef/) but its emphasis on a dedicated provisioning server and thousand-server deploys made it a sledgehammer when all I really needed was a chisel.  After a bit more investigation I found [Ansible](http://github.com/ansible-provisioning/ansible-provisioning) which seemed to match my needs more closely.  However, the syntax was still more complicated than I cared to learn for the simple task of provisioning a single server.

Finally, I ran across a blog post entitled [Forget Chef or Puppet - Automate with Sprinkle](http://mt.gomiso.com/2011/08/26/forget-chef-or-puppet-automate-with-sprinkle/) (2011).  Link-bait title aside, I found that the system described, Sprinkle, was a perfect match for the level of complexity I was willing to get into for provisioning.  It includes the essential tools for configuration management -- dependency resolution, verification of correct installation, and helpers for common tasks like transfering files and installing packages from apt, and doesn't make you learn more complex abstractions to use it effectively.

A few days ago I switched from the DigitalOcean box I was on to a RamNode instance that gives me a more flexible plan for disk space.  This was my first chance to test my Sprinkle provisioning on a completely fresh machine.  It worked as well as I hoped, and after running the provisioning script and waiting about 40 minutes (most of which was the time it took Ruby 2.0 to compile from source) I had a fully functional box.  After pointing Capistrano at the new address and running `cap deploy:setup` and `cap deploy` my site and blog have seamlessly been transfered to the new server (well, almost seamlessly, I still had to copy over the database).

I've open sourced my Sprinkle packages on [Github](https://github.com/kcorbitt/deploy-corbt).  Happy provisioning.