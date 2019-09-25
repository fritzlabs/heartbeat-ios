package ai.fritz.haircoloring;

import android.graphics.Bitmap;
import android.graphics.Color;
import android.hardware.camera2.CameraCharacteristics;
import android.os.Bundle;
import android.util.Size;

import com.github.veritas1.verticalslidecolorpicker.VerticalSlideColorPicker;

import ai.fritz.core.Fritz;
import ai.fritz.fritzvisionhairsegmentationmodel.HairSegmentationOnDeviceModelFast;
import ai.fritz.vision.FritzVision;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.imagesegmentation.BlendMode;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationPredictor;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationPredictorOptions;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationResult;
import ai.fritz.vision.imagesegmentation.MaskClass;
import ai.fritz.vision.imagesegmentation.SegmentationOnDeviceModel;


public class MainActivity extends BaseLiveGPUActivity {
    private static final String API_KEY = "bbe75c73f8b24e63bc05bf81ed9d2829";

    private int maskColor = Color.RED;
    private static final float HAIR_CONFIDENCE_THRESHOLD = .5f;
    private static final int HAIR_ALPHA = 180;
    private static final BlendMode BLEND_MODE = BlendMode.SOFT_LIGHT;
    private static final boolean RUN_ON_GPU = true;

    private FritzVisionSegmentationPredictor hairPredictor;
    private FritzVisionSegmentationResult hairResult;
    private FritzVisionSegmentationPredictorOptions options;

    private SegmentationOnDeviceModel onDeviceModel;

    public void onCreate(final Bundle savedInstanceState) {
        setCameraFacingDirection(CameraCharacteristics.LENS_FACING_FRONT);
        super.onCreate(savedInstanceState);
        Fritz.configure(this, API_KEY);

        // Create the segmentation options.
        options = new FritzVisionSegmentationPredictorOptions();
        options.confidenceThreshold = HAIR_CONFIDENCE_THRESHOLD;
        options.useGPU = RUN_ON_GPU;

        // Set the on device model
        onDeviceModel = new HairSegmentationOnDeviceModelFast();

        // Load the predictor when the activity is created (iff not running on the GPU)
        if (!RUN_ON_GPU) {
            hairPredictor = FritzVision.ImageSegmentation.getPredictor(onDeviceModel, options);
        }
    }

    @Override
    public void onPreviewSizeChosen(final Size size, final Size cameraSize, final int rotation) {
        super.onPreviewSizeChosen(size, cameraSize, rotation);

        VerticalSlideColorPicker colorPicker = findViewById(R.id.color_picker);

        // Change the mask color upon using the slider
        colorPicker.setOnColorChangeListener(new VerticalSlideColorPicker.OnColorChangeListener() {
            @Override
            public void onColorChange(int selectedColor) {
                if (selectedColor != Color.TRANSPARENT) {
                    maskColor = selectedColor;
                }
            }
        });
    }

    @Override
    protected int getLayoutId() {
        return R.layout.camera_color_slider;
    }

    @Override
    protected void runInference(FritzVisionImage fritzVisionImage) {
        // If you're using the GPU, it MUST run on the same thread
        if (RUN_ON_GPU && hairPredictor == null) {
            hairPredictor = FritzVision.ImageSegmentation.getPredictor(onDeviceModel, options);
        }
        hairResult = hairPredictor.predict(fritzVisionImage);
        Bitmap alphaMask = hairResult.buildSingleClassMask(MaskClass.HAIR, HAIR_ALPHA, .8f, options.confidenceThreshold, maskColor);
        fritzSurfaceView.drawBlendedMask(fritzVisionImage, alphaMask, BLEND_MODE, getCameraFacingDirection() == CameraCharacteristics.LENS_FACING_FRONT);
    }
}
