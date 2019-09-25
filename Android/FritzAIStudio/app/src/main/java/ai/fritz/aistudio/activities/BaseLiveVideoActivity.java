package ai.fritz.aistudio.activities;

import android.graphics.Canvas;
import android.media.Image;
import android.media.ImageReader;
import android.os.Bundle;
import android.util.Size;
import android.widget.Button;

import java.util.concurrent.atomic.AtomicBoolean;

import ai.fritz.aistudio.R;
import ai.fritz.aistudio.ui.OverlayView;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.FritzVisionOrientation;
import ai.fritz.vision.ImageRotation;

public abstract class BaseLiveVideoActivity extends BaseCameraActivity implements ImageReader.OnImageAvailableListener {

    private static final String TAG = BaseLiveVideoActivity.class.getSimpleName();
    private AtomicBoolean computing = new AtomicBoolean(false);
    protected FritzVisionImage fritzVisionImage;

    private ImageRotation imageRotation;
    protected Button chooseModelBtn;

    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onPreviewSizeChosen(final Size size, final Size cameraSize, final int rotation) {
        imageRotation = FritzVisionOrientation.getImageRotationFromCamera(this, cameraId);
        chooseModelBtn = findViewById(R.id.chose_model_btn);

        setCallback(
                new OverlayView.DrawCallback() {
                    @Override
                    public void drawCallback(final Canvas canvas) {
                        handleDrawingResult(canvas, cameraSize);
                    }
                });

        onCameraSetup(cameraSize);
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
        fritzVisionImage = FritzVisionImage.fromMediaImage(image, imageRotation);
        image.close();

        runInBackground(
                new Runnable() {
                    @Override
                    public void run() {
                        runInference(fritzVisionImage);
                        requestRender();
                        computing.set(false);
                    }
                });
    }

    @Override
    protected int getLayoutId() {
        return R.layout.camera_connection_fragment_tracking;
    }

    @Override
    public void onSetDebug(final boolean debug) {

    }

    protected abstract void onCameraSetup(Size cameraSize);

    protected abstract void handleDrawingResult(Canvas canvas, Size cameraSize);

    protected abstract void runInference(FritzVisionImage fritzVisionImage);
}
