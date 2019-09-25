package ai.fritz.aistudio.activities.custommodel;

import android.graphics.Bitmap;
import android.media.Image;
import android.media.ImageReader;
import android.media.ImageReader.OnImageAvailableListener;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;
import android.util.Size;

import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

import ai.fritz.aistudio.activities.BaseCameraActivity;
import ai.fritz.aistudio.R;
import ai.fritz.aistudio.activities.custommodel.ml.Classifier;
import ai.fritz.aistudio.activities.custommodel.ml.TensorFlowImageClassifier;
import ai.fritz.aistudio.ui.ResultsView;
import ai.fritz.core.utils.BitmapUtils;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.FritzVisionOrientation;
import ai.fritz.vision.ImageRotation;


public class CustomTFMobileActivity extends BaseCameraActivity implements OnImageAvailableListener {

    private static final String TAG = CustomTFMobileActivity.class.getSimpleName();

    private ResultsView resultsView;

    private static final int INPUT_SIZE = 224;
    private static final int IMAGE_MEAN = 117;
    private static final float IMAGE_STD = 1;
    private static final String INPUT_NAME = "input";
    private static final String OUTPUT_NAME = "output";

    private static final Size MODEL_SIZE = new Size(INPUT_SIZE, INPUT_SIZE);


    private static final String LABEL_FILE =
            "file:///android_asset/imagenet_comp_graph_label_strings.txt";

    private static final Size DESIRED_PREVIEW_SIZE = new Size(640, 480);

    private Classifier classifier;

    private AtomicBoolean computing = new AtomicBoolean(false);

    private ImageRotation imageRotation;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.camera_connection_fragment;
    }

    @Override
    protected Size getDesiredPreviewFrameSize() {
        return DESIRED_PREVIEW_SIZE;
    }


    @Override
    public void onPreviewSizeChosen(final Size size, final Size cameraSize, final int rotation) {
        imageRotation = FritzVisionOrientation.getImageRotationFromCamera(this, cameraId);

        classifier =
                TensorFlowImageClassifier.create(
                        this,
                        getAssets(),
                        LABEL_FILE,
                        INPUT_SIZE,
                        IMAGE_MEAN,
                        IMAGE_STD,
                        INPUT_NAME,
                        OUTPUT_NAME);
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

        final FritzVisionImage fritzImage = FritzVisionImage.fromMediaImage(image, imageRotation);
        image.close();

        runInBackground(
                new Runnable() {
                    @Override
                    public void run() {
                        final long startTime = SystemClock.uptimeMillis();
                        Bitmap resizedBitmap = fritzImage.prepare(MODEL_SIZE);
                        final List<Classifier.Recognition> results = classifier.recognizeImage(resizedBitmap);
                        Log.d(TAG, "Detect: " + results);
                        if (resultsView == null) {
                            resultsView = findViewById(R.id.results);
                        }
                        resultsView.setResults(results);
                        Log.d(TAG, "INFERENCE TIME:" + (SystemClock.uptimeMillis() - startTime));

                        requestRender();
                        computing.set(false);
                    }
                });
    }
}
