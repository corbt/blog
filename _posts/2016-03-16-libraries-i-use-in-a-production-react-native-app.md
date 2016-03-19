---
layout: post
published: true
title: Libraries I Use in a Production React Native App
comments: true
---

React Native is an exciting technology, as I've written about before. Facebook and outside collaborators are working hard and iterating fast on the core technology, and a community of users and library authors is growing and maturing quickly.

I thought it might be helpful for those new to the React Native community to document some of the third-party libraries I've found useful in the [Emberall](https://emberall.com) app (currently in private beta). Right now we're focusing on iOS, but most mature React Native libraries, including most of the ones I list below, make an effort to support iOS and Android with a similar or identical API.

Things tend to move quickly and are still stabilizing, so comments I make here may be out of date by the time you read it. If you find any outdated or simply wrong information in this list, let me know in the comments and I'll update it.

In case you missed the link in the docs, [js.coach](https://js.coach/react-native) is the de facto solution for searching for available RN libraries. It has a fairly complete index and lets you easily find the most popular projects to implement common functionality.

## Libraries

#### React Native

This one's obvious. However, it's worth pointing out that I've found it necessary to run off a forked version of the library with a few tweaks I need for my own personal productivity. Where these changes are general, I've opened [Pull](https://github.com/facebook/react-native/pull/5624) [Requests](https://github.com/facebook/react-native/pull/5556). In others, like setting my correct local IP address for testing on the device, I've had to maintain a fork and rebase it periodically against RN master (there are also a couple of PRs open that should make this unnecessary once merged). It can be frustrating how long it takes core contributors to make a decision on open PRs, but things have been getting better recently and I maintain the hope that action is imminent on all my outstanding issues.

#### [ImmutableJS](http://facebook.github.io/immutable-js/docs/#/)

This probably deserves its own blog post. ImmutableJS [`Record`](http://facebook.github.io/immutable-js/docs/#/Record)s (as well as [`Map`](http://facebook.github.io/immutable-js/docs/#/Map)s, [`List`](http://facebook.github.io/immutable-js/docs/#/List)s and even [`Set`](http://facebook.github.io/immutable-js/docs/#/Set)s where appropriate) are almost as fundamental to my app's data model as Redux itself. These are incredibly useful data structures with an expansive set of functional transforms defined on them which allow you to concisely transform and query immutable data.

#### [Sentry](https://getsentry.com/welcome/)

Currently the react-native [Sentry plugin](https://github.com/getsentry/raven-js/blob/master/docs/integrations/react-native.rst) is quite limited (if the app crashes hard or doesn't have internet connectivity when a crash occurs the report is lost), but it seems to work better than anything else I found and the team is [interested in improving it](https://github.com/getsentry/raven-js/issues/489#issuecomment-188419708). If you've found a better exception reporting/monitoring solution for React Native I'd love to hear about it in the comments!

#### [ExNavigator](https://github.com/exponentjs/ex-navigator)

This is currently the most stable and probably most widely adopted React Native navigator implementation. It's built on top of the default navigator, and provieds a clean way to organize scenes into routes. Once [`NavigationExperimental`](https://github.com/facebook/react-native/tree/master/Libraries/NavigationExperimental) stabilizes though I may switch to that and storing all route information in Redux, which is a better conceptual fit for how the rest of app data is stored anyway.

#### [next-frame](https://github.com/corbt/next-frame)

This is my own library (wrote about it [here]({% post_url 2015-12-22-breaking-up-heavy-processing-in-react-native %})) that I use to split data reconciliation after sync (which can take a while) into smaller chunks to maintain UI responsiveness.

#### [react-native-blur](https://github.com/react-native-fellowship/react-native-blur)

What the name says.

#### [react-native-camera](https://github.com/lwansbrough/react-native-camera)

A reasonably feature-complete photo/video camera component.

#### [react-native-code-push](https://github.com/Microsoft/react-native-code-push)

This is a fantastic library by Microsoft for updating React Native code in production. It has a simple but configurable API. You can start using it in your app by adding about 4 lines of configuration/code. My only concern is that it's currently in a free beta, and there hasn't been any signaling from the team if/how much they're planning on charging for the service in the future.

#### [react-native-device-info](https://github.com/rebeccahughes/react-native-device-info)

We're currently depending on this to report the unique device ID and app version for every API call for debugging purposes. Useful little utility.

#### [react-native-fs](https://github.com/johanneslumpe/react-native-fs)

Reasonably sane (if somewhat bare-bones) file system access. We use this to shuffle recorded video files around; many apps won't need it and should just stick with [`AsyncStorage`](https://facebook.github.io/react-native/docs/asyncstorage.html) for persistence.

#### [react-native-gifted-spinner](https://github.com/FaridSafi/react-native-gifted-spinner)

A cross-platform loading spinner. Use with care -- spinners can make your app actually feel slower if used in excess. Prefer a pretty transition if loading times are short and predictable.

#### [react-native-linear-gradient](https://github.com/brentvatne/react-native-linear-gradient)

Neat little component to show gradients. We use this as the background of our login screen and for a fading-to-transparent overlay a-la Google Hangouts on our recording screen.

#### [react-native-orientation](https://github.com/yamill/react-native-orientation)

Reports device orientation, and lets you lock it on a per-scene basis if necessary.

#### [react-native-scrollable-tab-view](https://github.com/brentvatne/react-native-scrollable-tab-view)

We use this to switch between the main screens of our app. I'm considering transitioning to a more traditional (non-scrolling) tab bar though, because I've run into a number of smoothness/performance issues that seem inevitable based on the nature of this component.

#### [react-native-sound](https://github.com/zmxv/react-native-sound)

Fairly simple and self-explanatory. We use this to play a sound when recording begins and ends.

#### [react-native-vector-icons](https://github.com/oblador/react-native-vector-icons)

This is the swiss army chainsaw of icon libraries. It includes everything and because the icons are all included as vectors it's possible to set their size/color/outline easily in your code. I have a sneaking suspicion there might be performance concerns with rendering a bunch of these icons in one scene but so far I haven't had any issues.

#### [react-native-video](https://github.com/brentvatne/react-native-video)

Video playback. It seems to work fine on iOS, although a bit underdocumented (I had to play with the sample app to figure out the options and API).

#### [Redux](http://redux.js.org/index.html) and [react-redux](https://github.com/reactjs/react-redux)

Redux has been heavily discussed elsewhere so I won't say much here. Work has also finished recently to make [Relay](https://facebook.github.io/relay/) compatible with React Native, but I don't think it's the best option for most apps today because there's no story for local optimistic updates or offline actions, which are critical to making an app feel nicer than a prettified web view.

#### [redux-persist](https://github.com/rt2zz/redux-persist)

This handy library allows a Redux store to be persisted to and restored from disk. However, there's no mechanism to partially store/restore results, so this technique is only appropriate if all of your app's data can fit in memory easily. If you have more data than this I recommend checking out [Realm](https://realm.io/docs/react-native/latest/api/), which behaves more like a traditional disk-based database (think SQLite) while still having great RN support. This app at one point used an early beta version of realm, but I found the performance wasn't there yet compared to pure in-memory Redux. Hopefully it's better now.

#### [redux-persist-immutable](https://github.com/rt2zz/redux-persist-immutable)

A plugin for redux-persist that allows it to seamlessly handle immutable values. I have an [old PR](https://github.com/rt2zz/redux-persist-immutable/pull/2) on this for better `Record` handling, but haven't ever gotten a response from the maintainer.

#### [redux-thunk](https://github.com/gaearon/redux-thunk)

[Sagas](https://github.com/yelouafi/redux-saga) are an alternative action framework that seems to be gaining in popularity, but thunks along with `async`/`await` work fine for me.
