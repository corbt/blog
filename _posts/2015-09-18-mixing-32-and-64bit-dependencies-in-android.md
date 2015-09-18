---
layout: post
published: true
title: Mixing 32- and 64-bit Dependencies in Android
comments: true
---
As I've been experimenting with integrating React Native into the existing Emberall app (post coming soon) I found that the app consistently crashed on the Nexus 9 I was using for testing with the strange error:

    java.lang.UnsatisfiedLinkError: could find DSO to load: libreactnativejni.so

This was odd because the indicated library definitely did exist in the APK, and loaded just fine on other devices and apps.

It turns out that Android isn't able to load 32- and 64-bit native libraries concurrently. This becomes an issue if you have at least one dependency with extensions compiled with ARM64 support and another that only supports ARM32. The system will detect the ARM64 dependency, load it, and then refuse to load the ARM32-only library, likely causing your application to crash.

The worst part about this error is that you might not even notice it in development, if you test on an emulator or 32bit device. However, as more ARM64 devices, including the popular Nexus 9 and Samsung Galaxy S6 [enter the market](https://androidbycode.wordpress.com/2015/07/07/android-ndk-a-guide-to-deploying-apps-with-native-libraries/), your users may start having fatal crashes.

Long-term, the solution is for all library authors to provide 64-bit support -- it's obviously the future of the Android platform. But in the meantime, how do you deal with this issue, assuming you want to use mixed dependencies?

## The Solution

The best solution I've found so far (and be warned: it's a nasty hack) is to simply exclude all 64-bit binaries from your APK. If there are no 64-bit dependencies found, Android will happily load the 32-bit fallback versions of all `.so`s and work just fine, assuming you're not dependent on any 64-bit-specific functionality. To implement this in your project, follow these steps:

1. Generate an APK with the mixed binaries, like normal.
2. Unzip the .apk file (`unzip *.apk` from the command line works fine) and examine the `lib/arm64-v8a` directory. (If the directory doesn't exist, you have no packaged ARM64 libraries, and shouldn't have a problem.)
3. In your `gradle.properties` in the project root, add the line `android.useDeprecatedNdk=true`.
4. Add the following block to your `build.gradle` file, adding an `exclude` line for every 64-bit dependency you found in step 2.

```groovy
android {
    ...
    defaultConfig {
        ...
        ndk {
            abiFilters "armeabi-v7a", "x86"
        }

        packagingOptions {
            exclude "lib/arm64-v8a/librealm-jni.so"
        }
    }
}
```

Once you're done be sure to generate an APK with the new configuration and test it on an ARM64 device.