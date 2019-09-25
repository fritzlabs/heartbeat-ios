package ai.fritz.camera;

import android.graphics.Canvas;
import android.media.Image;
import android.util.Size;


public class MainActivity extends LiveCameraActivity {

    private static final String API_KEY = "ENTER YOUR API KEY HERE";

    @Override
    protected void initializeFritz() {
        // TODO: Uncomment this and modify your api key above.
        // Fritz.configure(this, API_KEY);
    }

    @Override
    protected void setupPredictor() {
        // STEP 1: Get the predictor and set the options.
        // ----------------------------------------------
        // A FritzOnDeviceModel object is available when a model has been
        // successfully downloaded and included with the app.
        // TODO: Create a predictor
        // ----------------------------------------------
        // END STEP 1
    }

    @Override
    protected void setupImageForPrediction(Image image) {
        // STEP 2: Create the FritzVisionImage object from media.Image
        // ------------------------------------------------------------------------
        // TODO: Add code for creating FritzVisionImage from a media.Image object
        // ------------------------------------------------------------------------
        // END STEP 2
    }

    @Override
    protected void runInference() {
        // STEP 3: Run predict on the image
        // ---------------------------------------------------
        // TODO: Add code for running prediction on the image
        // ----------------------------------------------------
        // END STEP 3
    }

    @Override
    protected void showResult(Canvas canvas, Size cameraSize) {
        // STEP 4: Draw the prediction result
        // ----------------------------------
        // TODO: Draw the result.
        // ----------------------------------
        // END STEP 4
    }
}
