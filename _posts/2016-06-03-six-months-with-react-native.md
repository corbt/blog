---
layout: post
published: true
title: Six Months with React Native
comments: true
---

It's been nearly eight months since I [first played with]({% post_url 2015-09-16-one-day-with-react-native-for-android %}) React Native. Since that time I've spent a lot of time working with the framework, eventually joining the core team. For the last six months, I've also been using React Native full time and building my business's primary iOS application, [Emberall](https://itunes.apple.com/us/app/emberall/id1084183716?mt=8)[^1], in it. We just released our first public version to the App Store, so now is a great time to do a retrospective on how development with React Native feels. I want React Native to succeed and believe it will, but I'll also try to be honest about the places where the project still needs to improve.

## The Good

React Native has continued moving at a breakneck pace over the last six months, and performance especially has improved noticeably. However, the API has substantially matured and most core components are stable. Breaking changes are always well documented in the release notes, and typically give you a version or two with deprecation warnings to migrate to the new syntax before removing the old way of doing things. The core project is well-managed and moving in an encouraging direction.

For many months, I had to maintain my own fork of React Native with a number of commits to fix basic functionality and add features that weren't available in the upstream project. I submitted pull requests for all of these changes, but the mean time between PR and review was something like three months. This wasn't due to a lack of organization or desire, but simply an inevitable byproduct of the terribly overworked React Native team at Facebook. However, in the last two months the team has somehow found more time for reviewing pull requests, shrinking the review time and allowing me to work with the unmodified upstream project (with [one important exception](#ugly)).

Additionally, the React Native core team made the investment of developing the entire framework with the [Flow type system](http://flowtype.org/). This means that every component and API can be statically checked for correctness. If you haven't used a language with a modern type system you may not realize how big of a deal this is, but I'd estimate that for my own use more than 90% of bugs that would otherwise cause runtime errors are caught by Flow. It's an incredible tool and having types baked into the library is a huge asset.

Finally, both the React Native team at Facebook and other core community members are thoughtful, nice, friendly and intelligent. Changes to public APIs tend to make sense, be clearly communicated, and solicit community feedback when appropriate.

## The Bad

Although the React Native platform itself is fairly stable and breaking changes are clearly communicated, the ecosystem surrounding it is still immature. Projects do exist for most native functionality you'd want to include in your app, but quality, stability and documentation standards vary widely. Even some very popular projects regularly break backwards compatibility or simply break functionality unintentionally and without warning. I've needed to contribute PRs to more than half of the third-party native modules that I use just to fix the functionality I care about. Of course, the fact that I'm able to do so is a huge plus for open source, but it would be much better if it weren't necessary.

Additionally, many projects have subtle differences in behavior between their iOS and Android implementations, and many others don't even make an attempt at cross-platform functionality. Based on my interaction with the community I have the impression that *most* React Native developers aren't currently working on cross-platform applications, although certainly some are.

<div id="ugly" />
## The Ugly

More than a year after React Native was released to the public, there still isn't a good story for developing your iOS app on a real device (as opposed to the simulator). Contacting the packager on `localhost` is hardwired into the platform in a couple of places, which requires anyone developing on a device to maintain a fork of React Native with their own local IP replacing `localhost`. This has been discussed numerous times in issues and PRs and a fix [has been promised](https://github.com/facebook/react-native/pull/6362#issuecomment-222325074), but isn't available yet. Relatedly, I'll lose my websocket connection between the device and computer often enough that the red error screens it causes can impede development. This is pretty basic functionality that should **just work**.

## Recommend?

After six months developing primarily with React Native, I have absolutely no regrets about betting on it for our primary business app, and would do it again. The platform has multiplied my productivity and is generally a joy to work with. It's still early days and there are definitely still rough edges, but the platform is so much better than what came before that having to deal with the occasional bug is definitely a price worth paying.

--------------------

[^1]: Emberall is an app for recording home videos, and and saving memories of your children as you grow up. We officially launched in the [App Store](https://itunes.apple.com/us/app/emberall/id1084183716?mt=8) last week!
