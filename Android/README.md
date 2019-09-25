# Examples for Android

[ ![Codeship Status for fritzlabs/fritz-sdk-android](https://app.codeship.com/projects/c74152e0-65d1-0136-2d69-32e87736c6c6/status?branch=master)](https://app.codeship.com/projects/297281)
[![Twitter](https://img.shields.io/badge/twitter-@fritzlabs-blue.svg?style=flat)](http://twitter.com/fritzlabs)

Fritz is the machine learning platform for iOS and Android developers. [Sign up for a free account](https://app.fritz.ai/register) to see how you can include machine learning features in your app.

**Vision API: Prebuilt models that you can simply drop into your apps:**

- [Image Segmentation](https://www.fritz.ai/features/image-segmentation.html): Create pixel level masks of different objects in a scene. ([code](HeartbeatDemoApp/app/src/main/java/ai/fritz/heartbeat/activities/vision/ImageSegmentationActivity.java))
- [Image Labeling](https://www.fritz.ai/features/image-labeling.html): Classify different objects in an video or image.([code](HeartbeatDemoApp/app/src/main/java/ai/fritz/heartbeat/activities/vision/ImageLabelingActivity.java))
- [Pose Estimation](https://www.fritz.ai/features/pose-estimation.html): Identify and track a person's body position.([code](HeartbeatDemoApp/app/src/main/java/ai/fritz/heartbeat/activities/vision/PoseEstimationActivity.java))
- [Object Detection](https://www.fritz.ai/features/object-detection.html): Detect multiple objects and track their location.([code](HeartbeatDemoApp/app/src/main/java/ai/fritz/heartbeat/activities/vision/ObjectDetectionActivity.java))
- [Style Transfer](https://www.fritz.ai/features/style-transfer.html): Transform photos and videos into artistic masterpieces.([code](HeartbeatDemoApp/app/src/main/java/ai/fritz/heartbeat/activities/vision/StyleTransferActivity.java))

**Custom Models: Deploy, Monitor, and Update your own models:**

We currently support both TensorFlow Lite ([code](HeartbeatDemoApp/app/src/main/java/ai/fritz/heartbeat/activities/custommodel/CustomTFLiteActivity.java)) and TensorFlow Mobile ([code]([HeartbeatDemoApp/app/src/main/java/ai/fritz/heartbeat/activities/custommodel/CustomTFMobileActivity.java)) for Android.

- [Analytics and Monitoring](https://www.fritz.ai/features/analytics-monitoring.html): Monitor machine learning models running on-device with Fritz.
- [Model Management](https://www.fritz.ai/features/model-management.html): Iterate on your ML models over-the-air, without having to release your app.
- [Model Protection](https://www.fritz.ai/features/model-protection.html): Use model protection to keep models from being tampered-with or stolen.

## Example Apps

If you are new to Fritz, I'd recommend getting started with our Heartbeat Demo App. You can also install the latest version from the [Google Play Store](https://play.google.com/store/apps/details?id=ai.fritz.heartbeat&hl=en_US):

- Heartbeat Demo App - Our kitchen sink project showcases all on-device Vision APIs and Custom Model usage.
- Camera Boilerplate App - Our lightweight camera app to quickly get started implementing features with the camera.
- Background Replacement App [People Segmentation] - An example app to replace the background of portraits ([tutorial](https://heartbeat.fritz.ai/image-segmentation-for-android-smart-background-replacement-with-fritz-a09d8b0592a4)).
- Sky Animation App [Sky Segmentation] - A simple photo app that replaces the sky with an animation. (Tutorial coming soon)
- Hair Coloring App [Hair Segmentation] - An example app to replace a user's hair color ([tutorial](https://heartbeat.fritz.ai/embrace-your-new-look-with-hair-segmentation-by-fritz-now-available-for-android-developers-f20f5b4e9ae1)).
- Pet Monitoring App [Object Detection] - An example app to track dogs and cats with the camera ([tutorial](https://medium.freecodecamp.org/a-guide-to-object-detection-with-fritz-build-a-pet-monitoring-app-in-android-with-machine-learning-a8ed500978e5)).
- Pet Sticker App [Pose Estimation] - Create a sticker from photos of your pets. (Tutorial coming soon)
- Pose Estimation App [Pose Estimation] - Track body movements and position with Pose Estimation ([tutorial](https://heartbeat.fritz.ai/pose-estimation-on-android-with-fritz-474e646dfede)).

## Latest SDK version

- Fritz Android SDK 3.3.1

## Official Documentation

[SDK Documentation](https://docs.fritz.ai/)

[Android API Docs](https://docs.fritz.ai/android/latest/index.html)

## Help

For any questions or issues, you can:

- Submit an issue on this repo
- Go to our [Help Center](https://docs.fritz.ai/help-center/index.html)
- Message us directly in [Slack](https://join.slack.com/t/heartbeat-by-fritz/shared_invite/enQtNTY5NDM2MTQwMTgwLTAyODE3MmQzZjU2NWE5MDNmYTgwM2E1MjU5Y2Y2NmI2YTlkMTMwZTAwYTAwMzQ5NzQ2NDBhZjhmYjU2YWY3OGU)
