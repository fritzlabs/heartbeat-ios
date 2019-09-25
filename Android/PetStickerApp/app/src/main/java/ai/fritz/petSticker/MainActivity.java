package ai.fritz.petSticker;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.media.Image;
import android.media.ImageReader;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Size;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.Toast;

import java.util.UUID;
import java.util.concurrent.atomic.AtomicBoolean;

import ai.fritz.core.Fritz;
import ai.fritz.fritzvisionpetsegmentationmodel.PetSegmentationOnDeviceModelFast;
import ai.fritz.vision.FritzVision;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.FritzVisionOrientation;
import ai.fritz.vision.ImageRotation;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationPredictor;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationPredictorOptions;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationResult;
import ai.fritz.vision.imagesegmentation.MaskClass;


public class MainActivity extends BaseCameraActivity implements ImageReader.OnImageAvailableListener {
    private static final String TAG = MainActivity.class.getSimpleName();
    private static final String API_KEY = "bbe75c73f8b24e63bc05bf81ed9d2829";

    private AtomicBoolean shouldSample = new AtomicBoolean(true);
    private FritzVisionSegmentationPredictor predictor;
    private ImageRotation imgRotation;

    private FritzVisionSegmentationResult segmentResult;
    private FritzVisionImage visionImage;

    Button snapshotButton;
    Button saveStickerBtn;
    RelativeLayout previewLayout;
    RelativeLayout snapshotLayout;
    OverlayView snapshotOverlay;
    ProgressBar snapshotProcessingSpinner;
    Button closeButton;
    FritzVisionSegmentationPredictorOptions options;

    Bitmap petBitmapToSave;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Fritz.configure(this, API_KEY);

        PetSegmentationOnDeviceModelFast onDeviceModel = new PetSegmentationOnDeviceModelFast();
        options = new FritzVisionSegmentationPredictorOptions();
        options.confidenceThreshold = .4f;
        predictor = FritzVision.ImageSegmentation.getPredictor(onDeviceModel, options);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.camera_connection_fragment_pet_sticker;
    }

    @Override
    public void onPreviewSizeChosen(final Size size, final Size cameraSize, final int rotation) {
        imgRotation = FritzVisionOrientation.getImageRotationFromCamera(this, cameraId);

        snapshotButton = findViewById(R.id.take_picture_btn);
        previewLayout = findViewById(R.id.preview_frame);
        snapshotLayout = findViewById(R.id.snapshot_frame);
        snapshotOverlay = findViewById(R.id.snapshot_view);
        closeButton = findViewById(R.id.close_btn);
        snapshotProcessingSpinner = findViewById(R.id.snapshotProcessingSpinner);
        saveStickerBtn = findViewById(R.id.saveStickerBtn);

        snapshotOverlay.setCallback(new OverlayView.DrawCallback() {
            @Override
            public void drawCallback(final Canvas canvas) {

                if (segmentResult == null) {
                    return;
                }

                Bitmap maskBitmap = segmentResult.buildSingleClassMask(MaskClass.PET, 255, options.confidenceThreshold, options.confidenceThreshold);
                Bitmap petBitmap = visionImage.mask(maskBitmap, true);

                if (petBitmap == null) {
                    return;
                }
                // Scale the result
                float scaleWidth = ((float) cameraSize.getWidth()) / petBitmap.getWidth();
                float scaleHeight = ((float) cameraSize.getWidth()) / petBitmap.getHeight();

                final Matrix matrix = new Matrix();
                float scale = Math.min(scaleWidth, scaleHeight);
                matrix.postScale(scale, scale);

                petBitmapToSave = Bitmap.createBitmap(petBitmap, 0, 0, petBitmap.getWidth(), petBitmap.getHeight(), matrix, false);

                int leftOffset = (cameraSize.getWidth() - petBitmapToSave.getWidth()) / 2;
                int topOffset = (cameraSize.getHeight() - petBitmapToSave.getHeight()) / 2;

                // Draw pet mask
                canvas.drawBitmap(petBitmapToSave, leftOffset, topOffset, new Paint());
            }
        });

        snapshotButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!shouldSample.compareAndSet(true, false)) {
                    return;
                }

                snapshotOverlay.postInvalidate();

                runInBackground(
                        new Runnable() {
                            @Override
                            public void run() {
                                showSpinner();
                                segmentResult = predictor.predict(visionImage);
                                showSnapshotLayout();
                                hideSpinner();
                                snapshotOverlay.postInvalidate();
                            }
                        });
            }
        });

        final Activity activity = this;
        saveStickerBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (petBitmapToSave == null) {
                    Toast.makeText(activity, R.string.error_saving_sticker, Toast.LENGTH_LONG).show();
                    return;
                }

                // Save the sticker
                Toast.makeText(activity, R.string.saved_sticker, Toast.LENGTH_LONG).show();
                MediaStore.Images.Media.insertImage(
                        getContentResolver(), petBitmapToSave,
                        UUID.randomUUID().toString() + ".png",
                        "Pet Sticker");
                saveStickerBtn.setVisibility(View.GONE);
            }
        });

        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showPreviewLayout();
                shouldSample.set(true);
                petBitmapToSave = null;
            }
        });
    }

    private void showSpinner() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                snapshotProcessingSpinner.setVisibility(View.VISIBLE);
            }
        });
    }

    private void hideSpinner() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                snapshotProcessingSpinner.setVisibility(View.GONE);
            }
        });
    }

    private void showSnapshotLayout() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                previewLayout.setVisibility(View.GONE);
                snapshotLayout.setVisibility(View.VISIBLE);
                saveStickerBtn.setVisibility(View.VISIBLE);
            }
        });
    }

    private void showPreviewLayout() {
        previewLayout.setVisibility(View.VISIBLE);
        snapshotLayout.setVisibility(View.GONE);
    }

    @Override
    public void onImageAvailable(final ImageReader reader) {
        Image image = reader.acquireLatestImage();

        if (image == null) {
            return;
        }

        if (!shouldSample.get()) {
            image.close();
            return;
        }
        visionImage = FritzVisionImage.fromMediaImage(image, imgRotation);
        image.close();
    }
}