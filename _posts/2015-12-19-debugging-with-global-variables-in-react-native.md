---
layout: post
published: true
title: Debugging with Global Variables and the Chrome Console in React Native
comments: true
---

Given Javascript's dynamic nature, a lot of debugging and even development happens in the REPL. React Native's developers understand this, and have provided excellent first-class support for [inspecting and debugging React Native apps](https://facebook.github.io/react-native/docs/debugging.html#chrome-developer-tools) within the Chrome Developer Tools.

Frequently during development it's helpful to inspect the behavior of a particular object or function at the console. If you only care about the shape of an object, it's easy to see in React Native or the web by simply running `console.log(myObject)`.

Sometimes though you need to not only inspect an object but also interact with it. For example, I often want to test queries on an ImmutableJS object from my app's state. Typically in web development, when I want to do something like this I'll put something like `window.myStateObject = myStateObject` in the code, and then from the Chrome console try different methods on the exposed `myStateObject`. (It goes without saying that this pattern is best saved for exploration at the console -- for reusing objects between JS files stick with the [ES2015 module syntax](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import).)

However, when I tried this same pattern in React Native recently, to my puzzlement there was no reference to `myStateObject` available from the Chrome console. It seemed that nothing I was setting to `window`, `global` or `self` was visible in the debugger.

After some investigation I found the problem and an easy solution. It turns out that React Native's Chrome debugger runs all the app's Javascript in a background [Web Worker](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers). Web workers have their own context, and don't share any globals with the page's main execution environment, which is the one the dev tools connect to by default.

To fix this, simply change the execution environment in the Chrome console from the default *\<top frame\>* to *debuggerWorker.js*. Once you've done so any global variables you've defined will be available at the console.

![Change console context](//corbt.s3.amazonaws.com/blog/rn_chrome_change_context.png)