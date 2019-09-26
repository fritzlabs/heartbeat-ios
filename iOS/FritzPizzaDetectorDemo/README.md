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

Fritz AI is the machine learning platform for iOS and Android developers. Teach your mobile apps to see, hear, sense, and think. Start with our ready-to-use feature APIs or connect and deploy your own custom models.

## Requirements

- Xcode 10.2 or later.
- Xcode project targeting iOS 10 or above. You will only be able to use features in iOS 11+, but you still can include Fritz in apps that target iOS 10+ and selectively enable for users on 11+.
- Swift projects must use Swift 4.1 or later.
- CocoaPods 1.4.0 or later.

## Getting Started

**Step 1: Create a Fritz AI Account**

[Sign up](https://app.fritz.ai/register) for a free account on Fritz AI in order to get started.

**Step 2: Clone / Fork the fritz-examples repository and open FritzPizzaDetectorDemo (Starter or Final folder)**

```
git clone https://github.com/fritzlabs/fritz-examples.git
```

**Step 3: Setup the project via Cocoapods**

Install dependencies via Cocoapods by running `pod install` from `fritz-examples/iOS/FritzPizzaDetectorDemo/Starter`

```
cd fritz-examples/iOS/FritzPizzaDetectorDemo/Starter
pod install
```

- Note you may need to run `pod update` if you already have Fritz installed locally.

**Step 4: Open up a new XCode project**

XCode > Open > FritzPizzaDetectorDemo.xcworkspace

**Step 5: Run the app**

Attach a device or use an emulator to run the app. If you get the error "Please download the Fritz-Info.plist", you'll need to register the app with Fritz (See Step 2).

## Documentation

[Fritz Docs Home](https://docs.fritz.ai/)

[iOS SDK Reference Docs](https://docs.fritz.ai/iOS/latest/index.html)

## Join the community

[Heartbeat](https://heartbeat.fritz.ai/?utm_source=github&utm_campaign=fritz-models) is a community of developers interested in the intersection of mobile and machine learning. [Chat with us in Slack](https://www.fritz.ai/slack) and stay up to date on the latest mobile ML news with our [Newsletter](https://mobileml.us16.list-manage.com/subscribe?u=de53bead690affb8e9a21de8f&id=68acb5c0fd).

## Help

For any questions or issues, you can:
- Submit an issue on this repo
- Go to our [Help Center](https://docs.fritz.ai/help-center/index.html)
- Message us directly in [Slack](https://www.fritz.ai/slack)
