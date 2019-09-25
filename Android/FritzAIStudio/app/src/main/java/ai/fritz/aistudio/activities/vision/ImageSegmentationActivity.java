package ai.fritz.aistudio.activities.vision;

import android.graphics.Bitmap;
import android.media.ImageReader.OnImageAvailableListener;
import android.os.Bundle;
import android.util.Log;
import android.util.Size;

import ai.fritz.core.FritzOnDeviceModel;
import ai.fritz.core.utils.FritzModelManager;
import ai.fritz.core.utils.FritzOptional;
import ai.fritz.aistudio.activities.BaseRecordingActivity;
import ai.fritz.aistudio.R;
import ai.fritz.vision.FritzVision;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.PredictorStatusListener;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationPredictor;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationResult;
import ai.fritz.vision.imagesegmentation.livingroomsegmentation.LivingRoomSegmentationManagedModelFast;
import ai.fritz.vision.imagesegmentation.outdoorsegmentation.OutdoorSegmentationManagedModelFast;
import ai.fritz.vision.imagesegmentation.peoplesegmentation.PeopleSegmentationManagedModelFast;
import ai.fritz.vision.imagesegmentation.SegmentationManagedModel;
import ai.fritz.vision.imagesegmentation.SegmentationOnDeviceModel;


public class ImageSegmentationActivity extends BaseRecordingActivity implements OnImageAvailableListener {

    private static final String TAG = ImageSegmentationActivity.class.getSimpleName();
    private FritzVisionSegmentationPredictor predictor;

    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected int getModelOptionsTextId() {
        return R.array.img_seg_model_options;
    }

    @Override
    protected Bitmap runPrediction(FritzVisionImage visionImage, Size cameraViewSize) {
        FritzVisionSegmentationResult segmentResult = predictor.predict(visionImage);
        Bitmap bitmap = segmentResult.buildMultiClassMask();
        return visionImage.overlay(bitmap);
    }

    @Override
    protected void loadPredictor(int choice) {
        SegmentationManagedModel managedModel = getManagedModel(choice);
        FritzOptional<FritzOnDeviceModel> onDeviceModelOpt = FritzModelManager.getActiveOnDeviceModel(managedModel.getModelId());
        if (onDeviceModelOpt.isPresent()) {
            showPredictorReadyViews();
            FritzOnDeviceModel onDeviceModel = onDeviceModelOpt.get();
            SegmentationOnDeviceModel segmentOnDeviceModel = SegmentationOnDeviceModel.mergeFromManagedModel(
                    onDeviceModel,
                    managedModel);
            predictor = FritzVision.ImageSegmentation.getPredictor(segmentOnDeviceModel);
        } else {
            showPredictorNotReadyViews();
            FritzVision.ImageSegmentation.loadPredictor(managedModel, new PredictorStatusListener<FritzVisionSegmentationPredictor>() {
                @Override
                public void onPredictorReady(FritzVisionSegmentationPredictor segmentPredictor) {
                    Log.d(TAG, "Segmentation predictor is ready");
                    predictor = segmentPredictor;
                    showPredictorReadyViews();
                }
            });
        }
    }

    private SegmentationManagedModel getManagedModel(int choice) {

        switch (choice) {
            case (1):
                return new LivingRoomSegmentationManagedModelFast();
            case (2):
                return new OutdoorSegmentationManagedModelFast();
            default:
                return new PeopleSegmentationManagedModelFast();
        }
    }
}

