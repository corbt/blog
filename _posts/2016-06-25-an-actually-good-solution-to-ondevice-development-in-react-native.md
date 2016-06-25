---
layout: post
published: true
title: An Actually Good Solution to On-Device Development in React Native
comments: true
---

I recently [complained]({% post_url 2016-06-03-six-months-with-react-native %}#ugly) about how hard it is to develop on a physical device with React Native. By default, a React Native app in development will try to contact the packager on `localhost:8081` to get updates to the javascript code. This works well in a simulator or emulator where `localhost` will pass through to the host machine running the packager. Unfortunately, when running on a device loading from `localhost` won't work at all on iOS, and on Android requires a cumbersome extra step of calling [adb reverse](https://facebook.github.io/react-native/docs/running-on-device-android.html#using-adb-reverse) to forward the port properly every time the device is plugged in to the computer.

If your computer's IP address doesn't change frequently or you have control over a local DNS server that can resolve your machine, this is pretty easy to deal with by just hardcoding the packager to look at your computer's IP address for updates. This of course becomes unruly if you change networks frequently, and especially if (like me) you travel often and don't have control of the networks you're connected to.

The problem is compounded when developing a client-server application that you want to test against a copy of the server running on your local machine. Not only do you have to change where your packager loads from, but you have to somehow find a way to dynamically update the endpoint your app talks to, in addition to the packager.

## ZeroTier to the Rescue

It would be great if we could depend on our computer having a static IP that we could hardcode into our app across both iOS and Android to connect to load from in development. And in fact, we can!

[ZeroTier](https://www.zerotier.com/) is a robust minimal-configuration VPN provider. By setting it up across your development machine and any devices you use to develop and test, you can depend on always being able to access your computer at a known, static IP address, which you can then include in your apps. As a bonus, once you have the ZeroTier VPN set up this solution will work even if your devices happen to be connected to different networks (wifi/cellular) or are in different parts of the world! And it comes without a performance penalty, because the VPN connection is peer-to-peer so if you *are* on the same local network communication will still happen locally without having to round-trip out to a separate server.

### Basic Setup

Unfortunately the documentation for ZeroTier is pretty sparse and assumes you know a lot about virtual networking already. The product is fairly simple though, so it's not too hard to figure out on your own. I'll walk you through the basic steps I took to get started:

1. Create an account on [zerotier.com](https://zerotier.com). The product is free for up to 100 devices, but you will need an account to manage your network.

2. Within the ZeroTier admin interface, select "Networks" > "Create New Network". Then click on your new network's name.

3. Within the network's settings page, change "IPv4 Address Management" and "IPv6 Address Management" to both be "ZeroTier Managed".
![ZeroTier management interface](https://s3.amazonaws.com/corbt/blog/zerotier/config.png)

4. On your computer, install the appropriate [ZeroTier client](https://www.zerotier.com/product-one.shtml) (available for macOS, Windows, iOS, Android, Linux and FreeBSD). Follow the instructions on that page to connect to open the ZeroTier GUI and connect to the network you created in the previous step.

5. Return to your network's configuration page online and refresh the page. At the bottom, you should see something like the following, demonstrating that your computer is attempting to connect to the network:
![ZeroTier one connection](https://s3.amazonaws.com/corbt/blog/zerotier/authorize.png)
Click on the red circle to approve the computer (it should change to a green checkmark).

6. On your Android or iOS device, download the ZeroTier client for your platform (available in the App and Play Stores). Configure it to connect to the same network. Repeat step 5 to authorize all of your devices on the virtual network.

7. If you configured ZeroTier to manage your IP addresses in step (3), your computer should have been assigned an IP address by now. In the network interface, it will look something like this:
![ZeroTier computer with IP address](https://s3.amazonaws.com/corbt/blog/zerotier/dev_ip.png)

8. Run the React Native packager on your development machine, and confirm that it's running and accessible on the port assigned by the VPN by navigating to `http://[your_assigned_port]:8081`. You should see a message that says "React Native Packager is running" or something like that.
![Local packager](https://s3.amazonaws.com/corbt/blog/zerotier/local_packager.png)

9. If that worked, try it now from your device! Open Chrome or Safari on the device, and navigate to the same page. It should load the same message.
![Packager on device](https://s3.amazonaws.com/corbt/blog/zerotier/remote_packager.jpg)
*Accessing our private packager securely while on LTE? Nice!*

10. You're all done! Now just follow the React Native on-device development guides for [iOS](https://facebook.github.io/react-native/docs/running-on-device-ios.html#accessing-development-server-from-device) or [Android](https://facebook.github.io/react-native/docs/running-on-device-android.html#configure-your-app-to-connect-to-the-local-dev-server-via-wi-fi) to tell the packager to load from your new static local IP!

If you've found a better solution for on-device development, please let me know in the comments. This approach definitely is working well for me though!
