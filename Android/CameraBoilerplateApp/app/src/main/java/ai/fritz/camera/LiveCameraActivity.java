package ai.fritz.camera;

import android.graphics.Canvas;
import android.media.Image;
import android.media.ImageReader;
import android.os.Bundle;
import android.util.Size;

import java.util.concurrent.atomic.AtomicBoolean;


public abstract class LiveCameraActivity extends BaseCameraActivity implements ImageReader.OnImageAvailableListener {

    private static final String TAG = MainActivity.class.getSimpleName();

    private static final Size DESIRED_PREVIEW_SIZE = new Size(1280, 960);

    private AtomicBoolean computing = new AtomicBoolean(false);

    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initializeFritz();
        setupPredictor();
    }

    protected abstract void initializeFritz();

    protected abstract void setupPredictor();

    protected abstract void setupImageForPrediction(Image image);

    protected abstract void runInference();

    protected abstract void showResult(Canvas canvas, Size cameraViewSize);


    @Override
    protected int getLayoutId() {
        return R.layout.camera_connection_fragment;
    }

    @Override
    protected Size getDesiredPreviewFrameSize() {
        return DESIRED_PREVIEW_SIZE;
    }

    @Override
    public void onPreviewSizeChosen(final Size previewSize, final Size cameraViewSize, final int rotation) {

        // Callback draws a canvas on the OverlayView
        setCallback(
                new OverlayView.DrawCallback() {
                    @Override
                    public void drawCallback(final Canvas canvas) {
                        showResult(canvas, cameraViewSize);
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

        setupImageForPrediction(image);

        image.close();

        runInBackground(
                new Runnable() {
                    @Override
                    public void run() {

                        runInference();
                        // Fire callback to change the OverlayView
                        requestRender();
                        computing.set(false);
                    }
                });
    }
}
