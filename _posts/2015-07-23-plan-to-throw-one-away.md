---
layout: post
published: true
title: Plan to Throw One Away
comments: true
---

One of my favorite books on project management is Fred Brooks' [The Mythical Man Month](https://en.wikipedia.org/wiki/The_Mythical_Man-Month). There's a lot of good stuff in there, including a chapter titled *Plan to Throw One Away*.

Brooks claims that no matter how much time you put into getting the design right the first time, and no matter how much foresight you have in the architecture of your system, you'll end up having to throw the first version out anyway. By extension, it's often not worth your time to polish every possible use case and interaction with your system before you absolutely have to -- because there's a good chance that you'll be doing work on something that you're just going to throw away anyway.

I decided to test this on the [Emberall](https://emberall.com) website code base, which is almost exactly one year old. Although we've pivoted to a new market (from wedding and funeral albums to interviewing senior citizens) and completely rewritten our Android application to match it, we've never needed to do a complete rewrite from scratch on the backend code. Functionality has changed significantly, even drastically, but we've gotten where we are through an evolutionary process.

I wrote a simple script -- embedded below if you're interested -- to iterate through every commit in our git log and sum the insertions and deletions to source files in the repository. After letting it chug through our now-extensive history, it came back with the result that **over two thirds** of every line we've written in the last year has subsequently been deleted. Bear in mind that I ran this against the `master` branch, so this is only counting code that has been committed and was running in production at some point.

Although the huge proportion of code we throw out may appear wasteful at first, I don't anticipate this information substantially affecting the way we develop software at Emberall. Even knowing that most of what we write will likely not stay in the product long-term, it's hard to predict *which* features will actually be important to our bottom line until we've seen how people use them in the real world. Even code that doesn't stick around can still be invaluable because of the learning its usage or lack-thereof brings.

{% highlight ruby %}
require 'git'

repo = Git.open('../emberall')
prev = repo.log.first

deletions = 0
insertions = 0
repo.log(count = 5000).each do |commit|
  stats = repo.diff(commit, prev).stats[:files]
  deletions += stats
                .select { |f| f =~ /.*(rb)|(jsx)|(scss)|(yml)/ }
                .inject(0) { |sum, f| sum + f.last[:deletions] }
  insertions += stats
                .select { |f| f =~ /.*(rb)|(jsx)|(scss)|(yml)/ }
                .inject(0) { |sum, f| sum + f.last[:insertions] }

  prev = commit
end

puts "Deletions: #{deletions}"
puts "Insertions: #{insertions}"
{% endhighlight %}