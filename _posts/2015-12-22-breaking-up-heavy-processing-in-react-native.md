---
layout: post
published: true
title: Breaking up Heavy Processing in React Native
comments: true
---

This post describes the importance of not blocking the Javascript thread in React Native, a few of the built-in strategies for accomplishing this, and finally a new solution I've developed for breaking up "background" tasks in React Native so they don't block user interactions. If you already know a bit about performance in Javascript and want to skip straight to the good stuff, check out the [next-frame](https://github.com/corbt/next-frame) repo.

# Introduction

Fluidity and responsiveness are important properties in user interfaces, and especially so in a native app. Users expect smooth 60-fps animations and near-instant feedback from actions.

React Native has a couple of strategies to help developers meet this expectation. Most importantly, all Javascript execution takes place [on a background thread](https://facebook.github.io/react-native/docs/performance.html#javascript-frame-rate), and interaction with the UI thread takes place over an asynchronous bridge that implements some smarts like batching actions. This allows a user to interact with the UI to some degree (scrolling a ListView, getting touch feedback from a button) even if the JS thread is busy.

However, this doesn't obviate the need for performant JS. A blocked JS thread will still prevent the app from responding to user input by rendering a new scene or updating the UI. It will also block Javascript-powered animations from taking place, such as Navigator transitions or anything using `Animated` or `LayoutAnimation` (although the React Native team has mentioned plans to [move animations to the main thread](https://facebook.github.io/react-native/docs/performance.html#slow-navigator-transitions), which should alleviate this issue).

# The Problem

Sometimes, though, you have a data processing task that will inevitably take more than the 1/60th of a second, and thus impact your app's responsiveness. For the new [Emberall](https://emberall.com/) app, this tends to happen when syncing data from the server. We fetch the data asynchronously, but once loaded the response can take up to a couple seconds to parse and insert into the database[^realm]. In traditional native apps, the whole sync process would be executed on a background thread and not block the UI. However, Javascript is single-threaded so any form of background execution would require writing a native module which we'd prefer to avoid.

As a concrete example of this problem, let's examine a typical sync implementation.

```javascript
let response = await fetch("https://emberall.com/user/1/recordings");
let recordingsJSON = await response.json();

for (let recording of recordingsJSON) {
  mergeRecordingToLocalDatabase(recording);
}
```

Assuming you have several hundred `recording`s and each one takes about 1/100th of a second to process (as is the case in our actual app), running the entire sync processing in one go can block the JS thread for several seconds, and is obviously unacceptable.

# A Solution

The sync process as a whole takes so long that it will lead to a jittery UI. However, the process of merging each *individual* database record takes less than 1/60th of a second, and so if there were a way to break up the process over multiple cycles in the Javascript event loop there would be little noticeable decrease in responsiveness. 

Luckily, Javascript gives us the perfect tool for this: [requestAnimationFrame](https://developer.mozilla.org/en-US/docs/Web/API/window/requestAnimationFrame). By calling code in the callback to [requestAnimationFrame], we can cause it to be deferred until the next repaint, allowing the javascript event loop to terminate and any user input to be handled before processing the next recording. Here's one way that might look:

```javascript
let response = await fetch("https://emberall.com/user/1/recordings");
let recordingsJSON = await response.json();

function processRecording(recordingIndex) {
  if (recordingIndex < recordingsJSON.length) {
    mergeRecordingToLocalDatabase(recordings[recordingIndex]);
    requestAnimationFrame(() => processRecording(recordingIndex + 1));
  }
}
processRecording(0);
```

This works! However, the code is a little awkward because of the callback-based flow of `requestAnimationFrame`. We can do better than this.

# Packaged up: await nextFrame()

The solution described above works fine, but isn't very pretty. By wrapping it up with promises and using ES7's `async/await` syntax, we can make the code much cleaner. I've published a [simple helper function](https://www.npmjs.com/package/next-frame) that wraps `requestAnimationFrame` in a promise that resolves when the next frame is to be rendered. Using this function, we can go back to cleaner syntax:

```javascript
import nextFrame from 'next-frame';

// ...

for (let recording of recordingsJSON) {
  await nextFrame(); // This is all we need to add!
  mergeRecordingToLocalDatabase(recording);
}
```

Every time `await nextFrame()` is called, the function's execution will pause until the next render cycle starts. This allows the app to respond to user input and render animations before coming back to process the next item in our list.

## Bonus: mapInFrames

`await nextFrame()` too imperative for you? In the common case (like this one) that you just want to iterate over a collection and process one element per iteration, I've also included a function `mapInFrames` that does exactly that. The loop above could be rewritten with this function as follows:

```javascript
import { mapInFrames } from 'next-frame';

// ...

await mapInFrames(recordingJSON, mergeRecordingToLocalDatabase);
```

'next-frame' is live on npm, and you can find it on Github [here](https://github.com/corbt/next-frame). Use it next time you have an expensive operation to run on the Javascript thread -- your users will thank you for it.

### Footnotes
[^realm]: We're storing app data in [realm](https://realm.io/), a simple, performant and well-made mobile database. Unfortunately the official React Native Javascript bindings (still in [private beta](https://twitter.com/realm/status/661734570618920961)) only allow synchronous DB writes, which of course block the JS thread. The developers have said they're planning on adding async interactions, which should help with performance.