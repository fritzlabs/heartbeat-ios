package ai.fritz.aistudio;

import android.content.Context;
import android.content.Intent;

import ai.fritz.aistudio.activities.custommodel.CustomTFLiteActivity;
import ai.fritz.aistudio.activities.custommodel.CustomTFMobileActivity;
import ai.fritz.aistudio.activities.vision.HairSegmentationActivity;
import ai.fritz.aistudio.activities.vision.ImageLabelingActivity;
import ai.fritz.aistudio.activities.vision.ImageSegmentationActivity;
import ai.fritz.aistudio.activities.vision.ObjectDetectionActivity;
import ai.fritz.aistudio.activities.vision.PoseEstimationActivity;
import ai.fritz.aistudio.activities.vision.StyleTransferActivity;

/**
 * Navigation is a helper class for common links throughout the app.
 */
public class Navigation {

    public static void goToTFMobile(Context context) {
        Intent tfMobile = new Intent(context, CustomTFMobileActivity.class);
        context.startActivity(tfMobile);
    }

    public static void goToTFLite(Context context) {
        Intent tflite = new Intent(context, CustomTFLiteActivity.class);
        context.startActivity(tflite);
    }

    public static void goToLabelingActivity(Context context) {
        Intent labelActivity = new Intent(context, ImageLabelingActivity.class);
        context.startActivity(labelActivity);
    }

    public static void goToStyleTransfer(Context context) {
        Intent styleActivity = new Intent(context, StyleTransferActivity.class);
        context.startActivity(styleActivity);
    }

    public static void goToImageSegmentation(Context context) {
        Intent imgSegActivity = new Intent(context, ImageSegmentationActivity.class);
        context.startActivity(imgSegActivity);
    }

    public static void goToObjectDetection(Context context) {
        Intent objectDetection = new Intent(context, ObjectDetectionActivity.class);
        context.startActivity(objectDetection);
    }

    public static void goToPoseEstimation(Context context) {
        Intent poseEstimation = new Intent(context, PoseEstimationActivity.class);
        context.startActivity(poseEstimation);
    }

    public static void goToHairSegmentation(Context context) {
        Intent poseEstimation = new Intent(context, HairSegmentationActivity.class);
        context.startActivity(poseEstimation);
    }
}
