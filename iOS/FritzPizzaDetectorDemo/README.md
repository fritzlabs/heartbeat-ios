# Pizza Detector Demo with Image Labeling

[![Twitter](https://img.shields.io/badge/twitter-@fritzlabs-blue.svg?style=flat)](http://twitter.com/fritzlabs)

In this app, we use the Image Labeling API by Fritz in order to build a pizza identifier similar to Domino's Points for Pies feature.

For the full tutorial, visit [our post on Heartbeat](https://heartbeat.fritz.ai/recreate-dominos-points-for-pies-app-on-ios-with-fritz-image-labeling-2ed23398e1c2).

![](images/pizza.gif)

There are 2 projects to help you get started:

- Starter app - The bare bones app you should use to get started with the tutorial.
- Final app - The finished app displaying an animation when a pizza is detected.

Choose an app and run it in Xcode.

## Fritz AI

Fritz AI helps you teach your applications how to see, hear, feel, think, and sense. Create ML-powered features in your mobile apps for both Android and iOS. Start with our ready-to-use feature APIs or connect and deploy your own custom models.

## Requirements

- Xcode 10.2 or later.
- Xcode project targeting iOS 10 or above. You will only be able to use features in iOS 11+, but you still can include Fritz in apps that target iOS 10+ and selectively enable for users on 11+.
- Swift projects must use Swift 4.1 or later.
- CocoaPods 1.4.0 or later.

## Getting Started

**Step 1: Create a Fritz AI Account**

[Sign up](https://app.fritz.ai/register) for an account on Fritz AI in order to get started.

**Step 2: Clone / Fork the fritz-ios-tutorials repository and open FritzPizzaDetectorDemo (Starter or Final folder)**

```
git clone https://github.com/fritzlabs/fritz-ios-tutorials.git
```

**Step 3: Setup the project via Cocoapods**

Install dependencies via Cocoapods by running `pod install` from `fritz-ios-tutorials/FritzPizzaDetectorDemo/Starter`

```
cd fritz-ios-tutorials/FritzPizzaDetectorDemo/Starter
pod install
```

- Note you may need to run `pod update` if you already have Fritz installed locally.

**Step 4: Open up a new XCode project**

XCode > Open > FritzPizzaDetectorDemo.xcworkspace

**Step 5: Run the app**

Attach a device or use an emulator to run the app. If you get the error "Please download the Fritz-Info.plist", you'll need to register the app with Fritz (See Step 2).

## For questions on how to use the demos, contact us:

- [Slack](https://heartbeat-by-fritz.slack.com/join/shared_invite/enQtMzY5OTM1MzgyODIzLTZhNTFjYmRiODU0NjZjNjJlOGRjYzI2OTIwY2M4YTBiNjM1ODU1ZmU3Y2Q2MmMzMmI2ZTIzZjQ1ZWI3NzBkZGU)
- [Help Center](https://docs.fritz.ai/help-center/index.html)

## Documentation

[Fritz Docs Home](https://docs.fritz.ai/)

[iOS SDK Reference Docs](https://docs.fritz.ai/iOS/latest/index.html)

## Join the community

[Heartbeat](https://heartbeat.fritz.ai/?utm_source=github&utm_campaign=fritz-models) is a community of developers interested in the intersection of mobile and machine learning. [Chat with us in Slack](https://join.slack.com/t/heartbeat-by-fritz/shared_invite/enQtMzY5OTM1MzgyODIzLTZhNTFjYmRiODU0NjZjNjJlOGRjYzI2OTIwY2M4YTBiNjM1ODU1ZmU3Y2Q2MmMzMmI2ZTIzZjQ1ZWI3NzBkZGU) and stay up to date on the latest mobile ML news with our [Newsletter](https://mobileml.us16.list-manage.com/subscribe?u=de53bead690affb8e9a21de8f&id=68acb5c0fd).

## Help

For any questions or issues, you can:
- Submit an issue on this repo
- Go to our [Help Center](https://docs.fritz.ai/help-center/index.html)
- Message us directly in [Slack](https://heartbeat-by-fritz.slack.com/join/shared_invite/enQtNTY5NDM2MTQwMTgwLTAyODE3MmQzZjU2NWE5MDNmYTgwM2E1MjU5Y2Y2NmI2YTlkMTMwZTAwYTAwMzQ5NzQ2NDBhZjhmYjU2YWY3OGU)

