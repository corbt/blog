---
layout: post
published: true
title: Keeping the Screen on in React Native
comments: true
---

This is a short post just to point to a library I published on npm today. [`react-native-keep-awake`](https://github.com/corbt/react-native-keep-awake) allows you to prevent the screen from going to sleep while your app is active. It's useful for things like navigation or video playback, where the user expects the app to remain visible over long periods without touch interaction.

## Usage

There are two ways to use this package: by rendering it as a component, or by explicitly calling
the `KeepAwake.activate()` and `KeepAwake.deactivate()` static methods. Both are demonstrated below.

```js

import React, { Component } from 'react';
import { View, Text } from 'react-native';

import KeepAwake from 'react-native-keep-awake';

// Method 1
const MyComponent extends Component {
  render() {
    if (this.props.screenShouldBeAwake) {
      return (
        <View>
          <Text>Screen will be kept awake</Text>
          <KeepAwake />
        </View>
      )
    } else {
      return (
        <View>
          <Text>Screen can sleep</Text>
        </View>
      );
    }
  }
}

// Method 2
function changeKeepAwake(shouldBeAwake) {
  if (shouldBeAwake) {
    KeepAwake.activate();
  } else {
    KeepAwake.deactivate();
  }
}

```

In method 1, the screen will be locked awake when the `<KeepAwake />` component is mounted, and the lock will be disabled when the component is unmounted. Method 2 gives you more explicit control of when the lock is active or not.

If you need this functionality in your app, be sure to check the project out on GitHub!
