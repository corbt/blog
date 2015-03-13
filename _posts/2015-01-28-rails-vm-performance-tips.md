---
layout: post
published: true
title: Rails VM Performance Tips
comments: true
---

Quick tip for better Rails performance when working within a VM with a shared folder: keep the 3rd party gems out of the shared folder! I recently noticed a performance regression in the Emberall test suite that caused the tests to consistently take about 3x as long to run as before. We hadn't made any changes to the version of Ruby or Rails, and the CI server build times weren't affected. 

Turns out that the culprit was a seemingly-innocuous change I had made a few days ago to install bundled gems in the shared folder to cut down on reprovisioning times in a teardown/rebuild event. Shared folders often come with a performance penalty, and even though I'm using Parallels instead of Virtualbox as a provider it turns out that the gem load directory still made a big difference in app test times.

The fix was as simple as changing

    bin/bundle install --path=/vagrant/vendor/bundle

to

    bin/bundle install --path=/home/vagrant/.bundle

in the VM provisioning scripts and testing time was back to normal.