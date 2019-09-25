package ai.fritz.aistudio.activities.vision;

import android.graphics.Canvas;
import android.util.Size;

import java.util.List;

import ai.fritz.core.FritzOnDeviceModel;
import ai.fritz.aistudio.activities.BaseLiveVideoActivity;
import ai.fritz.poseestimationmodel.PoseEstimationOnDeviceModel;
import ai.fritz.vision.FritzVision;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.poseestimation.FritzVisionPosePredictor;
import ai.fritz.vision.poseestimation.FritzVisionPoseResult;
import ai.fritz.vision.poseestimation.Pose;

public class PoseEstimationActivity extends BaseLiveVideoActivity {

    private FritzVisionPosePredictor posePredictor;
    private FritzVisionPoseResult poseResult;

    @Override
    protected void onCameraSetup(final Size cameraSize) {
        FritzOnDeviceModel onDeviceModel = new PoseEstimationOnDeviceModel();
        posePredictor = FritzVision.PoseEstimation.getPredictor(onDeviceModel);
    }

    @Override
    protected void handleDrawingResult(Canvas canvas, Size cameraSize) {
        if (poseResult != null) {
            List<Pose> poseList = poseResult.getPoses();
            for (Pose pose : poseList) {
                pose.draw(canvas);
            }
        }
    }

    @Override
    protected void runInference(FritzVisionImage fritzVisionImage) {
        poseResult = posePredictor.predict(fritzVisionImage);
    }
}
