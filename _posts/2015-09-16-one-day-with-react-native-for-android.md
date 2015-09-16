---
layout: post
published: true
title: One Day with React Native for Android
comments: true
---
I was extremely excited on Monday to hear that React Native for Android had [officially been released](https://code.facebook.com/posts/1189117404435352/). I've been looking forward to playing with it for some time, and finally have a chance.

After spending most of a day implementing a toy project using the framework, I have some initial thoughts that I hope are useful to anyone deciding whether to dive in now or wait for the platform to become more stable.

By way of background, I have a fair amount of experience with both React on the web and native Android development. My interest in React Native isn't primarily based on its use of Javascript (I'm actually using Kotlin for most of my recent native development, and find it a pleasant compromise between the wild west of dynamically typed languages and the cumbersome verboseness of Java) or even the interoperability with iOS, although that's a nice bonus. My primary attraction to React Native is based on the React world view. Describing the UI declaratively as a function of application state just feels really clean, and I've used React long enough to know that it's a stable and scalable solution. There are no existing libraries or frameworks on the Android platform that really target this same abstraction, making React Native a very attractive alternative.

## The Project
I decided to implement a simple [Hacker News](https://news.ycombinator.com) reader to put the framework through its paces. You can find the source on [Github](https://github.com/corbt/HNReact), although it's not fully functional (reasons discussed below). The main view looks like this:

![hacker news top stories](https://s3.amazonaws.com/corbt/blog/hn_home.png)

## Setup
[Getting started](http://facebook.github.io/react-native/docs/getting-started.html#content) with React Native is easy. This isn't a project that Facebook just threw over the wall to the community -- there's obviously been a real effort to document how to get everything working and make the process as painless as possible. Setting everything up and getting the "Hello World" app running on an emulator probably took about 20 minutes. I spent another hour on false starts trying to get the sample app to run and reload correctly on my physical android device, but it turns out there's [a guide](http://facebook.github.io/react-native/docs/running-on-device-android.html#content) for that too.

One thing worth noting is that all of the materials/guides Facebook provides are written from the perspective of writing a React-Native-first or React-Native-only application. I don't think it would be hard to integrate React Native into an existing native application to render some or all views, but the primary use case the docs write towards is definitely RN-first. And for the most part, they make it easy to do. Beyond getting the emulator set up my existing Android knowledge wasn't needed for anything (they abstract away everything about the Activity lifecycle -- in fact your entire app lives within a single Activity). A familiarity with React, on the other hand, was essential.

## The Good
  * Pretty much everything you can do with React/JS works here. Building beautiful UIs is easy. 
  * With just a couple of taps you can enable debugging in Chrome, with everything that gives you (breakpoints, logging, error messages). Another tap turns on live code reloading on save. Frontend web developers are used to these niceties by now, but I cannot overstate how much they change the game when compared to the typical mobile workflow of save-compile-deploy, where every minor change takes a minute or two to test on the device. I can imagine mobile developers moving to React Native for this feature alone -- it's that good.
  * Although I still have some reservations about the Flexbox-only layout concept, it seems to be an effective replacement for the constellation of different layouts you have to choose from with stock Android. 
  * You can pull in libraries from npm and include them with your project -- anything that would work with browserify/webpack will also work here. 
  * Most of ES6 is supported with the Babel transpiler, including classes. It appears that [Flow](http://flowtype.org/) is also configured by default, although I haven't tested it. This may be a good solution for my general concern over Javascript's lack of static typing.
  * As a bonus, Facebook has implemented a number of cross-platform components like `View`, `Text`, `ListView`, etc. These make it easy to build a UI that is cross-platform by default. More advanced apps will probably need explicit customizations to deal with platform differences, but for the simple app I built I only used the default cross-platform components and it should work just as well on iOS. **UPDATE:** I compiled the app for iOS and it works identically. The coolest part about this is that I didn't even write it with compatibility in mind -- by using RN's included cross-platform components the iOS version came fore free!

## The Confusing
With a project as new as React Native for Android, there are bound to be things that aren't documented or just plain don't work. I ran into a number of these as I tried to build my app. Bear in mind that I wasn't trying to do anything crazy, just arrange standard UI components on a screen.

* Sometimes the device lost its connection to the Chrome debugging console, and I had to close the app and reopen it and restart the debugging. I never identified exactly what caused this, although it sometimes happened when I tried to compile javascript with syntax errors. Not a big deal (and still certainly faster than recompiling the app each time) but confusing at first.
* Some handy ES6 features aren't enabled by default, like `let`/`const` and `import`. Since React Native uses the Babel transpiler anyway, it would be convenient if they allowed the user to decide what features to enable.
* The [Navigator](https://facebook.github.io/react-native/docs/navigator.html#content) component, which is basically the sanctioned way to transition between "Scenes" (pages or activities), is surprisingly poorly documented, and possibly not fully implemented on Android. I spent a couple of hours playing with it before I was able to reliably open one scene from another and pass in props. There doesn't seem to be a standard way to do this, or at least not one I could find in the documentation/source. My eventual solution was to use an ES6 spread to pass a specific route property as props (see [source](https://github.com/corbt/HNReact/blob/c60ef9e61ef85fc453784f6ab2b9ae8a49880df6/index.android.js#L39)).
* No easy way to incorporate vector icons like FontAwesome. I expect this to come from the community soon; it looks like there are already several libraries to do this for iOS.
* Some basic views and actions haven't been implemented yet for Android. This bit me when adding the HN Article view. Since `WebView` hasn't been implemented and neither have Intents (the canonical Android way to launch third-party apps), there was no way to actually load an article without falling back to native code. However, they're [working on it](https://facebook.github.io/react-native/docs/known-issues.html#content).
* I was unable to successfully get the Back button to do anything other than close the app. I tried a variety of implementations of `_handleBackButtonPress()`, `BackAndroid`, and even listening for the native event with `RCTDeviceEventEmitter`. None of my callbacks were apparently even touched, and I haven't figured out why yet. This is probably just a case of a lack of documentation on the right way to use this.
* There appear to be a few bugs in RN's Flexbox implementation that made it impossible for me to center story headlines vertically in their box unless I made the entire box a fixed height. I opened [an issue](https://github.com/facebook/react-native/issues/2724#issuecomment-140491988).

## The Ugly
Let me preface this by saying I have a *lot* more issues with the standard way of doing Android development than with React Native. That said, there are a couple of concerns I have with it besides the growing pains listed above.

* Since all layout is done with FlexBoxes instead of higher-level layout primitives available in Android, the view hierarchy tends to get really deep. My views tend to be nested 4 or 5 levels deep to get everything to look right, compared to something like `GridLayout` on Android that would give you the same layout with one or two layers of nesting. While normal in HTML layout, this is considered an antipattern in Android development and the docs warn that it can cause performance issues. However, the React documentation [claims](https://facebook.github.io/react-native/docs/known-issues.html#layout-only-nodes-on-android) that layout-only nodes are collapsed as an optimization feature, so until I see real performance problems related to it this may be a non-issue.
* Using the default transition between scenes provided by the `Navigator` consistently dropped frames and lagged on my device. I have a high-end phone from 2014, which makes me worry about the performance characteristics of the framework in general on typical devices.

## Recommend?
Despite the hiccups, I'm still as excited about React Native as I was at the start. It lives up to its promise of making native development more rapid and enjoyable, while bringing a powerful new UI paradigm to the table and opening up mobile development to a new class of developers. I have no qualms about saying that it is enormously better than what came before.

That said, I won't be rewriting any production applications in React Native just yet. There are enough gotcha's and unanswered questions still around that I would rather give the developers a few more months to sand down the rough edges before betting the farm.