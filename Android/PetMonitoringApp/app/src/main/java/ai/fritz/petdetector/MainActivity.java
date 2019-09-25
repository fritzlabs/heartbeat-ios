package ai.fritz.petdetector;

import android.graphics.Canvas;
import android.media.Image;
import android.media.ImageReader;
import android.os.Bundle;
import android.util.Size;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

import ai.fritz.core.Fritz;
import ai.fritz.fritzvisionobjectmodel.ObjectDetectionOnDeviceModel;
import ai.fritz.vision.FritzVision;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.FritzVisionObject;
import ai.fritz.vision.FritzVisionOrientation;
import ai.fritz.vision.ImageRotation;
import ai.fritz.vision.objectdetection.FritzVisionObjectPredictor;
import ai.fritz.vision.objectdetection.FritzVisionObjectPredictorOptions;
import ai.fritz.vision.objectdetection.FritzVisionObjectResult;

public class MainActivity extends BaseCameraActivity implements ImageReader.OnImageAvailableListener {

    private static final String TAG = MainActivity.class.getSimpleName();

    private static final Size DESIRED_PREVIEW_SIZE = new Size(1280, 960);

    private AtomicBoolean computing = new AtomicBoolean(false);

    private Toast toast;

    // STEP 1:
    // TODO: Define the predictor variable
    private FritzVisionObjectPredictor predictor;
    // END STEP 1

    FritzVisionObjectResult result;
    FritzVisionImage visionImage;

    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize Fritz
        Fritz.configure(this);

        // STEP 1: Get the predictor and set the options.
        // ----------------------------------------------
        // TODO: Add the predictor snippet here
        FritzVisionObjectPredictorOptions options = new FritzVisionObjectPredictorOptions();
        options.confidenceThreshold = .4f;
        ObjectDetectionOnDeviceModel onDeviceModel = new ObjectDetectionOnDeviceModel();
        predictor = FritzVision.ObjectDetection.getPredictor(onDeviceModel, options);
        // ----------------------------------------------
        // END STEP 1

    }

    @Override
    protected int getLayoutId() {
        return R.layout.camera_connection_fragment_stylize;
    }

    @Override
    protected Size getDesiredPreviewFrameSize() {
        return DESIRED_PREVIEW_SIZE;
    }

    @Override
    public void onPreviewSizeChosen(final Size previewSize, final Size cameraViewSize, final int rotation) {
        final List<String> filteredObjects = new ArrayList<>();
        filteredObjects.add("cat");
        filteredObjects.add("dog");

        // Callback draws a canvas on the OverlayView
        addCallback(
                new OverlayView.DrawCallback() {
                    @Override
                    public void drawCallback(final Canvas canvas) {
                        // STEP 4: Draw the prediction result
                        // ----------------------------------
                        if (result == null) {
                            return;
                        }

                        boolean hasCat = false;
                        boolean hasDog = false;

                        // Go through all results
                        for (FritzVisionObject object : result.getObjects()) {
                            String labelText = object.getVisionLabel().getText();

                            // Only show results for dogs and cats
                            if (filteredObjects.contains(labelText)) {
                                object.draw(canvas);

                                if (labelText.equalsIgnoreCase("cat")) {
                                    hasCat = true;
                                }

                                if (labelText.equalsIgnoreCase("dog")) {
                                    hasDog = true;
                                }
                            }
                        }

                        if (toast == null || !toast.getView().isShown()) {
                            if (hasDog && hasCat) {
                                toast = Toast.makeText(getApplicationContext(), "Dogs and cats make good friends.", Toast.LENGTH_LONG);
                                toast.show();
                            } else if (hasDog) {
                                toast = Toast.makeText(getApplicationContext(), "Dogs are cool", Toast.LENGTH_LONG);
                                toast.show();
                                ;
                            } else if (hasCat) {
                                toast = Toast.makeText(getApplicationContext(), "Cats are cute", Toast.LENGTH_LONG);
                                toast.show();
                            }
                        }
                        // ----------------------------------
                        // END STEP 4
                    }
                });
    }

    @Override
    public void onImageAvailable(final ImageReader reader) {
        Image image = reader.acquireLatestImage();

        if (image == null) {
            return;
        }

        if (!computing.compareAndSet(false, true)) {
            image.close();
            return;
        }

        // STEP 2: Create the FritzVisionImage object from media.Image
        // ------------------------------------------------------------------------
        // TODO: Add code for creating FritzVisionImage from a media.Image object
        ImageRotation rotationFromCamera = FritzVisionOrientation.getImageRotationFromCamera(this, cameraId);
        visionImage = FritzVisionImage.fromMediaImage(image, rotationFromCamera);
        // ------------------------------------------------------------------------
        // END STEP 2

        image.close();

        runInBackground(
                new Runnable() {
                    @Override
                    public void run() {
                        // STEP 3: Run predict on the image
                        // ---------------------------------------------------
                        // TODO: Add code for running prediction on the image
                        // final long startTime = SystemClock.uptimeMillis();
                        result = predictor.predict(visionImage);
                        // ----------------------------------------------------
                        // END STEP 3


                        // Fire callback to change the OverlayView
                        requestRender();
                        computing.set(false);
                    }
                });
    }
}
