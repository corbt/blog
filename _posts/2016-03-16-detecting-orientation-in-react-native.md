---
layout: post
published: true
title: Detecting Device Orientation in React Native
comments: true
---

Typically, when designing a view either on the web or mobile it should be responsive to changes in size and be usable in a variety of aspect ratios. When done correctly, this allows a mobile app to provide a useful UI in landscape or portrait orientation. However, sometimes it's still useful to know the display orientation of the device.

As a concrete example, in the [Emberall](https://emberall.com) app (currently in private beta) we allow users to record personal histories on video. We've found that when a video is recorded in landscape, watching it later becomes a much more enjoyable experience. To facilitate this, we prompt users who we detect are recording a video in portrait orentation to rotate their phones.

To display this prompt, we need to know the current orientation of the device's UI. We first investigated using the [react-native-orientation](https://github.com/yamill/react-native-orientation) library, but unfortunately on iOS it reports the device's orientation as determined by accelerometer data directly, without taking into account any orientation lock the user may have enabled. It won't get us the actual UI orientation.

## Solution

An elegant solution is to set an [`onLayout`](https://facebook.github.io/react-native/docs/view.html#onlayout) listener on our app's root view. This callback is only fired when a view's layout has been changed, which in the root element's case normally occurs on app startup or when the device's orientation changes. Here's an extract from our app's code:

```js
// Extract from the root element in our app's index.js

class App extends Component {
  _onLayout = event => this.props.appLayout(event.nativeEvent.layout);

  render() {
    return (
      <View onLayout={this._onLayout}>
        {/* Subviews... */}
      </View>
    );
  }
}
```

In our case `this.props.appLayout` is connected to a Redux [action](http://redux.js.org/docs/basics/Actions.html), which is implemented as follows (you can just ignore the (Flow)[] annotations if you don't use it):

```js
export const SET_ORIENTATION = 'deviceStatus/SET_ORIENTATION';
export function appLayout(event: {width:number, height:number}):StoreAction {
  const { width, height } = event;
  const orientation = (width > height) ? 'LANDSCAPE' : 'PORTRAIT';
  return { type: SET_ORIENTATION, payload: orientation };
}

```

We then implement a Redux [reducer](http://redux.js.org/docs/basics/Reducers.html) to listen for the `SET_ORIENTATION` event, and make the device's orientation available to store consumers.

### Limitations

Since we use window size as a proxy for camera orientation, this approach will fail when the window's orientation doesn't match the camera's. For example, if our app is loaded on an Android or iOS tablet in split-screen it may believe that the device is in portrait orientation when it's really in landscape.