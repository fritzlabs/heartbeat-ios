package ai.fritz.animatedSky;

import android.animation.ValueAnimator;
import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.RectF;
import android.media.Image;
import android.media.ImageReader;
import android.os.Bundle;
import android.util.Size;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;

import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.atomic.AtomicBoolean;

import ai.fritz.core.Fritz;
import ai.fritz.fritzvisionskysegmentationmodel.SkySegmentationOnDeviceModelFast;
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

    private static final int DURATION = 5000;

    private ValueAnimator mCurrentAnimator;
    private Matrix mMatrix = new Matrix();
    private ImageView mImageView;
    private float mScaleFactor;
    private RectF mDisplayRect = new RectF();

    private FritzVisionSegmentationResult segmentResult;
    private FritzVisionImage visionImage;

    Button snapshotButton;
    RelativeLayout previewLayout;
    RelativeLayout snapshotLayout;
    OverlayView snapshotOverlay;
    ProgressBar snapshotProcessingSpinner;
    Button closeButton;
    FritzVisionSegmentationPredictorOptions options;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Fritz.configure(getApplicationContext(), API_KEY);

        SkySegmentationOnDeviceModelFast onDeviceModel = new SkySegmentationOnDeviceModelFast();
        options = new FritzVisionSegmentationPredictorOptions();
        options.confidenceThreshold = .6f;
        predictor = FritzVision.ImageSegmentation.getPredictor(onDeviceModel, options);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.sky_fragment;
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
        mImageView = findViewById(R.id.backgroundImgView);

        snapshotOverlay.setCallback(new OverlayView.DrawCallback() {
            @Override
            public void drawCallback(final Canvas canvas) {

                // If there's no result, just return
                if (segmentResult == null) {
                    return;
                }

                // Create a bitmap for undetected items. Scale it up for the camera.
                Bitmap notSkyMask = segmentResult.buildSingleClassMask(MaskClass.NONE);
                Bitmap notSkyBitmap = visionImage.mask(notSkyMask);

                // Scale the non-sky bitmap (scale up from preview size (size of the original image)
                // to fill the view (cameraSize)).
                float scaleWidth = ((float) cameraSize.getWidth()) / notSkyBitmap.getWidth();
                float scaleHeight = ((float) cameraSize.getHeight()) / notSkyBitmap.getHeight();
                final Matrix matrix = new Matrix();
                float scale = Math.min(scaleWidth, scaleHeight);
                matrix.postScale(scale, scale);
                Bitmap scaledNonSkyBitmap = Bitmap.createBitmap(notSkyBitmap, 0, 0, notSkyBitmap.getWidth(), notSkyBitmap.getHeight(), matrix, false);

                // Start the animation
                mImageView.post(new Runnable() {
                    @Override
                    public void run() {
                        mScaleFactor = (float) mImageView.getHeight() / (float) mImageView.getDrawable().getIntrinsicHeight();
                        mMatrix.postScale(mScaleFactor, mScaleFactor);
                        mImageView.setImageMatrix(mMatrix);
                        startAnimation();
                    }
                });

                // Draw the non-sky bitmap on the bottom center.
                canvas.drawBitmap(scaledNonSkyBitmap, (cameraSize.getWidth() - scaledNonSkyBitmap.getWidth()) / 2, cameraSize.getHeight() - scaledNonSkyBitmap.getHeight(), new Paint());
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

        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showPreviewLayout();
                shouldSample.set(true);
                mCurrentAnimator.end();
                mMatrix = new Matrix();
                mImageView.setImageMatrix(mMatrix);
                mDisplayRect = new RectF();
            }
        });
    }

    // For more information on how this animation works:
    // http://old.flavienlaurent.com/blog/2013/08/05/make-your-background-moving-like-on-play-music-app/
    // In short, use displayRect to maintain the real size and position of the bg.
    // Animate the background by applying a translation.
    private void startAnimation() {
        int width = mImageView.getDrawable().getIntrinsicWidth();
        int height = mImageView.getDrawable().getIntrinsicHeight();
        mDisplayRect.set(0, 0, width, height);
        mMatrix.mapRect(mDisplayRect);
        animate(mDisplayRect.left, mDisplayRect.left - (mDisplayRect.right - mImageView.getWidth()));
    }

    private void animate(float from, float to) {
        mCurrentAnimator = ValueAnimator.ofFloat(from, to);
        mCurrentAnimator.setRepeatCount(ValueAnimator.INFINITE);
        mCurrentAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                float value = (Float) animation.getAnimatedValue();

                mMatrix.reset();
                mMatrix.postScale(mScaleFactor, mScaleFactor);
                mMatrix.postTranslate(value, 0);

                mImageView.setImageMatrix(mMatrix);
            }
        });
        mCurrentAnimator.setDuration(DURATION);
        mCurrentAnimator.start();
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
        // Feel free to uncomment if you'd like to try it out with a static image
//         Bitmap testImage = getBitmapForAsset(this, "climbing.png");
//         visionImage = FritzVisionImage.fromBitmap(testImage, ImageRotation.ROTATE_0);

        // Using the image from the camera
        visionImage = FritzVisionImage.fromMediaImage(image, imgRotation);
        image.close();
    }

    public static Bitmap getBitmapForAsset(Context context, String path) {
        AssetManager assetManager = context.getAssets();
        InputStream inputStream;
        Bitmap bitmap = null;
        try {
            inputStream = assetManager.open(path);
            bitmap = BitmapFactory.decodeStream(inputStream);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return bitmap;
    }
}