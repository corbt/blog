---
layout: post
published: true
title: Signing Android Builds with Gradle
comments: true
---
At Emberall we're in the relatively uncommon position of developing a consumer Android application while enjoying complete control over the hardware it's deployed to (our Emberall video recorders). This gives us the ability to integrate the way our software and hardware work together extremely tightly, leading to a delightful user experience.

It also means that we can streamline some steps of the application development and deployment process, compared to a normal Android app distributed through Google's Play Store. Specifically, we push our app to users via a custom deployment channel running on our own servers, which helps us ensure that our recorders are updated to the latest version of our software as soon as a new release becomes available without ever having to visit the Play Store. I may give an overview of our deployment process (which includes staging, preview and release channels as well as intelligent rollback in the case of a failed push) in another post.

For now I'll be sharing the best way we've found to sign releases directly from Gradle without going through Android Studio's "Generate Signed APK" GUI. This allows our command line compile/deploy script to generate signed release APKs through Gradle's `./gradlew assembleRelease` command.

## The Secrets
There are two types of secrets required to sign the release: a keystore (with the actual signing keys) and the passwords necessary to unlock the keystore and the app signing key. We choose to keep these secrets files inside the repository tree, but keep them from being checked in through our `.gitignore` file. For greater security you could keep them somewhere on your filesystem outside the project directory, and the steps below would all still work.

```gitignore
# .gitignore

# Secret files
config/secrets.properties
config/secrets.keystore
```

The keystore file you should already have, if you've signed your app. We keep it in `config/secrets.keystore`, as seen in the `.gitignore`. The signing keys we put in the following file:

```jproperties
# config/secrets.properties

keystore_password=XXX
app_password=XXX

# We push to S3 as part of our deployment and the deployment script needs 
# keys to do so, so we keep them in this file as well.
s3_id=XXX
s3_key=XXX
```

## The Signing
Once the secrets are in place, actually using them from Gradle to sign the release build of the app is straightforward. Within the `android` stanza of the app's `build.gradle`, simply include the following block:

```groovy
signingConfigs {
    release {
        Properties secrets = new Properties()
        secrets.load(project.rootProject.file('config/secrets.properties').newDataInputStream())

        storeFile file("../config/secrets.keystore")
        storePassword secrets["keystore_password"]
        keyAlias "emberall"
        keyPassword secrets["app_password"]
    }
}
```

From now on all releases built by Gradle's `./gradlew assembleRelease` command (or builds from within Android Studio configured as "release") will be signed and ready to push to users.