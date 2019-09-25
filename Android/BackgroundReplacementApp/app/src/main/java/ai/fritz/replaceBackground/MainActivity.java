package ai.fritz.replaceBackground;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.media.ExifInterface;
import android.media.Image;
import android.media.ImageReader;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.util.Size;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.Toast;

import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.atomic.AtomicBoolean;

import ai.fritz.core.Fritz;
import ai.fritz.core.utils.BitmapUtils;
import ai.fritz.fritzvisionpeoplesegmentationaccurate.PeopleSegmentationOnDeviceModelAccurate;
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
    private static final int SELECT_IMAGE = 1;

    private AtomicBoolean shouldSample = new AtomicBoolean(true);
    private FritzVisionSegmentationPredictor predictor;
    private ImageRotation imgRotation;

    private FritzVisionSegmentationResult segmentResult;
    private FritzVisionImage visionImage;

    Button snapshotButton;
    Button selectBackgroundBtn;
    RelativeLayout previewLayout;
    RelativeLayout snapshotLayout;
    OverlayView snapshotOverlay;
    ProgressBar snapshotProcessingSpinner;
    Button closeButton;

    private Bitmap backgroundBitmap;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Fritz.configure(getApplicationContext(), "bbe75c73f8b24e63bc05bf81ed9d2829");

        PeopleSegmentationOnDeviceModelAccurate onDeviceModel = new PeopleSegmentationOnDeviceModelAccurate();
        FritzVisionSegmentationPredictorOptions options = new FritzVisionSegmentationPredictorOptions();
        options.confidenceThreshold = .4f;
        predictor = FritzVision.ImageSegmentation.getPredictor(onDeviceModel, options);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);


        if (requestCode != SELECT_IMAGE) {
            return;
        }
        if (resultCode == Activity.RESULT_CANCELED) {
            Toast.makeText(this, "Canceled", Toast.LENGTH_SHORT).show();
            return;
        }

        if (resultCode == Activity.RESULT_OK) {
            if (data == null) {
                return;
            }
            try {
                Uri selectedPicture = data.getData();
                Log.d(TAG, "IMAGE CHOSEN: " + selectedPicture);

                InputStream inputStream = getContentResolver().openInputStream(selectedPicture);
                ExifInterface exif = new ExifInterface(inputStream);
                int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);

                backgroundBitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), selectedPicture);

                switch (orientation) {
                    case ExifInterface.ORIENTATION_ROTATE_90:
                        backgroundBitmap = BitmapUtils.rotate(backgroundBitmap, 0);
                    case ExifInterface.ORIENTATION_ROTATE_180:
                        backgroundBitmap = BitmapUtils.rotate(backgroundBitmap, 270);
                    case ExifInterface.ORIENTATION_ROTATE_270:
                        backgroundBitmap = BitmapUtils.rotate(backgroundBitmap, 180);
                }

            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    @Override
    protected int getLayoutId() {
        return R.layout.camera_connection_fragment_background_replace;
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
        selectBackgroundBtn = findViewById(R.id.selectBackgroundBtn);

        snapshotOverlay.setCallback(new OverlayView.DrawCallback() {
            @Override
            public void drawCallback(final Canvas canvas) {

                // If the prediction has not run
                if (segmentResult == null) {
                    return;
                }

                // Show the people segmentation result when the background hasn't been chosen.
                if (backgroundBitmap == null) {
                    Bitmap personMask = segmentResult.buildSingleClassMask(MaskClass.PERSON, 180, .5f, .5f);
                    Bitmap result = visionImage.overlay(personMask);
                    Bitmap scaledBitmap = BitmapUtils.resize(result, cameraSize.getWidth(), cameraSize.getHeight());
                    canvas.drawBitmap(scaledBitmap, new Matrix(), new Paint());
                    return;
                }

                // Show the background replacement
                Bitmap scaledBackgroundBitmap = BitmapUtils.resize(backgroundBitmap, cameraSize.getWidth(), cameraSize.getHeight());
                canvas.drawBitmap(scaledBackgroundBitmap, new Matrix(), new Paint());

                // Draw the masked bitmap
                long startTime = System.currentTimeMillis();
                // Use a max alpha of 255 so that there isn't any transparency in the mask.
                Bitmap maskedBitmap = segmentResult.buildSingleClassMask(MaskClass.PERSON, 255, .5f, .5f);
                Bitmap croppedMask = visionImage.mask(maskedBitmap, true);
                Log.d(TAG, "Masked bitmap took " + (System.currentTimeMillis() - startTime) + "ms to create.");

                if (croppedMask != null) {
                    // Scale the result
                    float scaleWidth = ((float) cameraSize.getWidth()) / croppedMask.getWidth();
                    float scaleHeight = ((float) cameraSize.getWidth()) / croppedMask.getHeight();

                    final Matrix matrix = new Matrix();
                    float scale = Math.min(scaleWidth, scaleHeight);
                    matrix.postScale(scale, scale);

                    Bitmap scaledMaskBitmap = Bitmap.createBitmap(croppedMask, 0, 0, croppedMask.getWidth(), croppedMask.getHeight(), matrix, false);
                    // Print the background bitmap with the masked bitmap
                    // Center the masked bitmap at the bottom of the image.
                    canvas.drawBitmap(scaledMaskBitmap, (cameraSize.getWidth() - scaledMaskBitmap.getWidth()) / 2, cameraSize.getHeight() - scaledMaskBitmap.getHeight(), new Paint());
                }
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


        selectBackgroundBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent();
                intent.setType("image/*");
                intent.setAction(Intent.ACTION_GET_CONTENT);
                startActivityForResult(Intent.createChooser(intent, "Select Picture"), SELECT_IMAGE);
            }
        });

        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showPreviewLayout();
                shouldSample.set(true);
                backgroundBitmap = null;
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