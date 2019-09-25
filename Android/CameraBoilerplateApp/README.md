# Camera Boilerplate

[ ![Codeship Status for fritzlabs/fritz-sdk-android](https://app.codeship.com/projects/c74152e0-65d1-0136-2d69-32e87736c6c6/status?branch=master)](https://app.codeship.com/projects/297281)
[![Twitter](https://img.shields.io/badge/twitter-@fritzlabs-blue.svg?style=flat)](http://twitter.com/fritzlabs)

Fritz is the machine learning platform for iOS and Android developers. In order to run computer vision models or tasks, you have to dive into the Camera 2 API. In order to make it easier for developers to try out ML models, we've created a simple camera app to get started.

For a full list tutorials, please visit our [examples and tutorials page](https://www.fritz.ai/resources/tutorials.html).

## Requirements

- Android Studio 3.2 or above
- Android device in developer model (USB debugging enabled)

## Getting Started

**Step 1: Create a Fritz Account**

In order to use Fritz, please [register for a free account](https://app.fritz.ai/register).

**Step 2: Clone / Fork the fritz-examples repository and open the camera app in Android Studio**

```
git clone https://github.com/fritzlabs/fritz-examples.git
```

In Android Studio, choose "Open an existing Android Studio project" and select `skeleton-live-video-app`.

**Step 3: Build the Android Studio Project**

Select "Build > Make Project" from the top nav. Download any missing libraries if applicable. This should sync the gradle dependencies so give the build a second to complete.

**Step 4: Install the app onto your device**

With your Android device connected, select `Run > Run App` from the top nav. You should see a simple camera app for you to play around with.

In future tutorials, we'll use this as a starting point in order to run the model on each camera frame and show the result.

## Official Documentation

[SDK Documentation](https://docs.fritz.ai/)

[Android API Docs](https://docs.fritz.ai/android/latest/index.html)

## Help

For any questions or issues, you can:

- Submit an issue on this repo
- Go to our [Help Center](https://docs.fritz.ai/help-center/index.html)
- Message us directly in [Slack](https://join.slack.com/t/heartbeat-by-fritz/shared_invite/enQtNTY5NDM2MTQwMTgwLTAyODE3MmQzZjU2NWE5MDNmYTgwM2E1MjU5Y2Y2NmI2YTlkMTMwZTAwYTAwMzQ5NzQ2NDBhZjhmYjU2YWY3OGU)
