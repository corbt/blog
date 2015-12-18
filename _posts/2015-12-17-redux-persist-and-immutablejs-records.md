---
layout: post
published: true
title: Redux Persist and ImmutableJS Records
comments: true
---

At [Emberall](https://emberall.com) we're using [React Native](https://facebook.github.io/react-native/) for our newest mobile video history recording application, which should be available in a few months for both iOS and Android. Given that React Native was only open sourced in April and is still under very active development, the tools are in flux as well.

We're using [Redux](https://github.com/rackt/redux) for state management, coupled with Facebook's [ImmutableJS](https://facebook.github.io/immutable-js/) for high-performance immutable data structures.

Unlike our web interface that we've also built using React/Redux, users of a mobile app expect to be able to access and save their data and settings immediately upon opening the app, even if they're not connected to the internet. This usually requires saving some state to disk and reloading it when the app is opened.

In order to implement this, we're using the [redux-persist](https://github.com/rt2zz/redux-persist) store enhancer that can be configured to automatically persist Redux state updates to disk using React Native's `AsyncStore`. Unfortunately, redux-persist (even if combined with [redux-persist-immutable](https://github.com/rt2zz/redux-persist-immutable)) doesn't support the hydration of ImmutableJS [`Record`](https://facebook.github.io/immutable-js/docs/#/Record) objects, which we use extensively in our state tree.

Records have the desirable properties of (1) defining ahead of time the allowed keys, (2) requiring all keys to have a default value and (3) (unlike an ImmutableJS map) allowing standard JS object property access syntax. They're a great way to encode something like app settings, where you know everything you're ever going to store there and what your default values are.

Luckily, getting Records working with redux-persist is quite straightforward. On the persistence side you don't have to do anything at all -- all ImmutableJS data structures implement `.toJSON()` out of the box, which redux-persist calls under the hood when writing the data to disk. 

For data retrieval things are only slightly more complicated. I've inserted below a dummy `settings` reducer that implements the necessary functionality:

```javascript
import { Record } from 'immutable';
import { REHYDRATE } from 'redux-persist/constants';

export const SettingsRecord = new Record({
  useFrontCamera: true,
  wifiSyncOnly: true,
});

export default function settings(state = new SettingsRecord(), action) {
  switch (action.type) {
    case REHYDRATE:
      if( action.key == 'settings' )
        return new SettingsRecord(action.payload);
    // handle other actions here
    // ...
    default:
      return state;
  }
}
```

Essentially, we handle redux-persist's `REHYDRATE` action by creating a new `Record` with all the values that redux-persist restored from disk.

While this is slightly more verbose than having the data rehydrated into an instance of our `Record` type automagically, in any non-trivial app you'll probably need to handle the `REHYDRATE` action anyway, because that's the best place to perform any necessary migrations as you update and change the shape of your data.