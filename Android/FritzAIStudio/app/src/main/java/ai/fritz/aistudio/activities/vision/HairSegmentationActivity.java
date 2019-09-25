package ai.fritz.aistudio.activities.vision;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.RectF;
import android.util.Size;

import ai.fritz.fritzvisionhairsegmentationmodel.HairSegmentationOnDeviceModelFast;
import ai.fritz.aistudio.activities.BaseLiveVideoActivity;
import ai.fritz.vision.FritzVision;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.imagesegmentation.BlendMode;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationPredictor;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationPredictorOptions;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationResult;
import ai.fritz.vision.imagesegmentation.MaskClass;


public class HairSegmentationActivity extends BaseLiveVideoActivity {
    private static final int maskColor = Color.RED;
    private static final BlendMode blendMode = BlendMode.SOFT_LIGHT;
    private static final float HAIR_CONFIDENCE_THRESHOLD = .5f;
    private static final int HAIR_ALPHA = 180;

    private FritzVisionSegmentationPredictor hairPredictor;
    private FritzVisionSegmentationResult hairResult;

    private FritzVisionSegmentationPredictorOptions options;

    @Override
    protected void onCameraSetup(final Size cameraSize) {
        HairSegmentationOnDeviceModelFast onDeviceModel = new HairSegmentationOnDeviceModelFast();
        options = new FritzVisionSegmentationPredictorOptions();
        options.confidenceThreshold = HAIR_CONFIDENCE_THRESHOLD;

        hairPredictor = FritzVision.ImageSegmentation.getPredictor(onDeviceModel, options);
    }

    @Override
    protected void handleDrawingResult(Canvas canvas, Size cameraSize) {
        if (hairResult != null) {
            Bitmap maskBitmap = hairResult.buildSingleClassMask(MaskClass.HAIR, HAIR_ALPHA, .8f, options.confidenceThreshold, maskColor);
            Bitmap blendedBitmap = fritzVisionImage.blend(maskBitmap, blendMode);
            canvas.drawBitmap(blendedBitmap, null, new RectF(0, 0, cameraSize.getWidth(), cameraSize.getHeight()), null);
        }
    }

    @Override
    protected void runInference(FritzVisionImage fritzVisionImage) {
        hairResult = hairPredictor.predict(fritzVisionImage);
    }
}
