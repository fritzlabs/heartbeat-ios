package ai.fritz.haircoloring;

import android.media.Image;
import android.media.ImageReader;
import android.os.Bundle;
import android.util.Size;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;

import java.util.concurrent.atomic.AtomicBoolean;

import ai.fritz.vision.FritzSurfaceView;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.FritzVisionOrientation;
import ai.fritz.vision.ImageRotation;

public abstract class BaseLiveGPUActivity extends BaseCameraActivity implements ImageReader.OnImageAvailableListener {

    private static final String TAG = BaseLiveGPUActivity.class.getSimpleName();
    private AtomicBoolean computing = new AtomicBoolean(false);

    private ImageRotation imageRotation;
    protected Button chooseModelBtn;
    protected ImageButton cameraSwitchBtn;
    protected FritzVisionImage fritzVisionImage;
    protected FritzSurfaceView fritzSurfaceView;

    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onPreviewSizeChosen(final Size size, final Size cameraSize, final int rotation) {
        imageRotation = FritzVisionOrientation.getImageRotationFromCamera(this, cameraId);
        chooseModelBtn = findViewById(R.id.chose_model_btn);
        cameraSwitchBtn = findViewById(R.id.camera_switch_btn);
        fritzSurfaceView = findViewById(R.id.gpuimageview);

        cameraSwitchBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toggleCameraFacingDirection();
            }
        });

    }

    @Override
    public void onImageAvailable(final ImageReader reader) {
        final Image image = reader.acquireLatestImage();

        if (image == null) {
            return;
        }

        if (!computing.compareAndSet(false, true)) {
            image.close();
            return;
        }
        fritzVisionImage = FritzVisionImage.fromMediaImage(image, imageRotation);
        runInference(fritzVisionImage);
        image.close();
        computing.set(false);
    }

    protected abstract int getLayoutId();

    @Override
    public void onSetDebug(final boolean debug) {

    }

    protected abstract void runInference(FritzVisionImage fritzVisionImage);
}
