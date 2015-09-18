---
layout: post
published: true
title: Integrating React Native with an Existing App
comments: true
---

After my [last post]({% post_url 2015-09-16-one-day-with-react-native-for-android %}) I decided to see how difficult it would be to add React Native to an existing Android application. Turns out not that hard! (Although there are still a few gotcha's).

The purpose of this post is really just getting from 0 to "hello world" with React Native in an existing app. The idea is to create an activity where React Native renders the view. I haven't tried any 2-way communication between the JS/Java, or any more [complicated](https://facebook.github.io/react-native/docs/native-modules-android.html#content) [integrations](https://facebook.github.io/react-native/docs/native-components-android.html#content). If we go forward with actually building future functionality for Emberall in React Native I'll certainly have more to say. And you won't find any instructions here for cross-platform (iOS) support -- adding React Native as a dependency obviously won't magically make your app compile on iOS.

Before following these steps, make sure you're able to get a "Hello World" React Native project compiling/running from your machine on your device. Follow the instructions at [Getting Started](https://facebook.github.io/react-native/docs/getting-started.html#content) if you haven't yet gone through the process.

## Steps
1. Run `react-native init TempProject` in a temporary directory.
2. Copy `package.json` and `index.android.js` from `TempProject` to the root of your Android project.
3. In the root of your Android project, run `npm install`.
4. In your app's `build.gradle`, add `compile 'com.facebook.react:react-native:0.11.+'` to the `dependencies {}` block.
5. In your `AndroidManifest.xml`, add `<activity android:name="com.facebook.react.devsupport.DevSettingsActivity" />`
6. Create a new activity in your app like normal. Copy in the methods from [this gist](https://gist.github.com/corbt/7cf2f0282a8936122c28), customizing them as necessary.
7. (Optional) add "node_modules/" to your `.gitignore` file.

You should now be able to run your app, and the view for your new activity will be rendered with React Native. All the dev tools, hot reloading etc. should work as intended.

## Gotcha's

I ran into a couple of issues just in getting this far:

* If you have any 64-bit dependencies or libraries, React Native won't load on 64-bit devices because it only provides 32-bit binaries for the JSC interop. I opened an [issue](https://github.com/facebook/react-native/issues/2814) about this and have also provided a [workaround]({% post_url 2015-09-18-mixing-32-and-64bit-dependencies-in-android %}).
* Oddly, the dev options menu accessed through "Rage Shake" > "Dev Settings" pulls in any existing `PreferenceScreen` your app has instead of loading the React Native preferences. This is likely a bug in how React Native is implemented and I may open a PR if I have time to investigate the exact issue.