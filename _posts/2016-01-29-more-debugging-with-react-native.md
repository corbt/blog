---
layout: post
published: true
title: More Debugging with React Native
comments: true
---

Last month I [wrote a bit]({% post_url 2015-12-19-debugging-with-global-variables-in-react-native %}) about debugging React Native in the Chrome console. For some types of development, particularly experimenting with APIs that you're not familiar with, the console is a very productive environment.

Expanding on that post, I'd like to share an annotated version of the init script that I use to get the console ready for debugging. I include this `config.js` file near the beginning of my project's `index.[ios|android].js` so the debugging functions are always available.

```js
// config.js

// Only load these in the development environment, you'll never need them
// outside of it.
if (__DEV__) {
  
  // I use getState() all the time to inspect our app's redux state. Even when
  // using Redux Devtools, it's often much faster to find what you're looking
  // for by navigating at the console with autocomplete.
  window.getState = require('./model/store').getState;

  // Pretty-prints ImmutableJS data structures in the chrome console
  const installDevTools = require('immutable-devtools').default;
  const Immutable = require('immutable');
  installDevTools(Immutable);

  // Disable spammy error messages when you're developing on a device
  // and the computer's clock is out of sync.
  // https://github.com/facebook/react-native/issues/1598
  console.ignoredYellowBox = ['jsSchedulingOverhead'];

  // Keep a reference to React handy in the console to experiment with
  // component APIs.
  window.React = require('react-native');

  // We do a lot of filesystem manipulation for storing photo/video, and it's
  // great to be able to query it from the console.
  window.FS = require('react-native-fs');
}
```

And in my Redux store definition file:

```js
// model/store.js

const store = /* ... */
export const getState = store.getState;
```

That's it! Having these objects and helpers always available makes debugging sessions at the console much more productive.