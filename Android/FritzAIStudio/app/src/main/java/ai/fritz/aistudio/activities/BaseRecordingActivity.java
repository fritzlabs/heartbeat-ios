package ai.fritz.aistudio.activities;

import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.media.Image;
import android.media.ImageReader;
import android.media.ImageReader.OnImageAvailableListener;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.util.Log;
import android.util.Size;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

import ai.fritz.core.FritzOnDeviceModel;
import ai.fritz.fritzvisionstylepaintings.PaintingStyles;
import ai.fritz.aistudio.R;
import ai.fritz.aistudio.ui.ChooseModelDialog;
import ai.fritz.aistudio.ui.OverlayView;
import ai.fritz.aistudio.utils.VideoProcessingQueue;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.FritzVisionOrientation;
import ai.fritz.vision.ImageRotation;


public abstract class BaseRecordingActivity extends BaseCameraActivity implements OnImageAvailableListener {
    private static final String TAG = BaseRecordingActivity.class.getSimpleName();
    private static final long TIME_BETWEEN_FRAMES_MS = 100;
    private static final long TIME_BUFFER_FRAMES_MS = 50;
    private static final long MAX_RECORDING_TIME_MS = TimeUnit.SECONDS.toMillis(5);
    private static final long TIME_BETWEEN_RECORDING_INTERVAL_MS = 50;
    private static final int NUM_PROGRESS_INTERVALS = (int) (MAX_RECORDING_TIME_MS / TIME_BETWEEN_RECORDING_INTERVAL_MS);

    private AtomicBoolean isRecording = new AtomicBoolean(false);

    private OverlayView overlayView;
    private ImageRotation imageRotationFromCamera;

    private ChooseModelDialog imageSegDialog;
    private Button takeVideoBtn;
    private Button closeBtn;
    private Button chooseModelBtn;
    private ProgressBar processingVideoProgress;
    private ProgressBar videoRecordingProgress;
    private ProgressBar loadingModelSpinner;

    private VideoProcessingQueue videoProcessingQueue;
    private LinkedBlockingQueue<Bitmap> processedBitmaps = new LinkedBlockingQueue<>();

    private AtomicLong lastRecordedFrameAt = new AtomicLong(0);
    private CountDownTimer mCountDownTimer;
    private Handler playBackHandler = new Handler();

    private int processingProgress = 0;

    protected abstract int getModelOptionsTextId();

    protected abstract Bitmap runPrediction(FritzVisionImage visionImage, Size cameraViewSize);

    protected abstract void loadPredictor(int choice);


    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.camera_connection_fragment_recording;
    }

    @Override
    public void onPreviewSizeChosen(final Size previewSize, final Size cameraViewSize, final int rotation) {
        overlayView = findViewById(R.id.debug_overlay);
        takeVideoBtn = findViewById(R.id.take_video_btn);
        processingVideoProgress = findViewById(R.id.processingVideoProgress);
        videoRecordingProgress = findViewById(R.id.videoRecordingProgress);
        closeBtn = findViewById(R.id.close_btn);
        chooseModelBtn = findViewById(R.id.choose_model_btn);
        loadingModelSpinner = findViewById(R.id.loadingModelSpinner);

        showCameraViews();

        // Create a predictor

        loadPredictor(0);
        chooseModelBtn.setText(getModelText(0));

        videoProcessingQueue = new VideoProcessingQueue(new VideoProcessingQueue.Listener() {
            @Override
            public void processVisionImage(FritzVisionImage visionImage) {
                Bitmap result = runPrediction(visionImage, cameraViewSize);
                processedBitmaps.add(result);
                Log.d(TAG, "Processed Frame #: " + processedBitmaps.size());

                if (!isRecording.get()) {
                    processingVideoProgress.setProgress(++processingProgress);
                }
            }

            @Override
            public void finishedProcessing() {
                Log.d(TAG, "Finished processing video clips");
                finishProcessing();
            }
        });

        imageRotationFromCamera = FritzVisionOrientation.getImageRotationFromCamera(this, cameraId);

        // Dialog for image seg choice;
        imageSegDialog = new ChooseModelDialog(getModelOptionsTextId(), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                // The 'which' argument contains the index position
                // of the selected item.
                loadPredictor(which);

                chooseModelBtn.setText(getModelText(which));
            }
        });


        closeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showCameraViews();
            }
        });
        final Paint paint = new Paint();
        setCallback(
                new OverlayView.DrawCallback() {
                    @Override
                    public void drawCallback(final Canvas canvas) {
                        if (!processedBitmaps.isEmpty()) {
                            Bitmap bitmap = processedBitmaps.poll();
                            canvas.drawBitmap(bitmap, null, new RectF(0, 0, cameraViewSize.getWidth(), cameraViewSize.getHeight()), null);

                        }
                    }
                });
        takeVideoBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    isRecording.compareAndSet(false, true);
                    lastRecordedFrameAt.set(0);
                    showStartRecordingViews();
                    return true;
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    isRecording.compareAndSet(true, false);
                    showFinishRecordingViews();
                    return true;
                }

                return false;
            }
        });

        chooseModelBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                imageSegDialog.show(getSupportFragmentManager(), ChooseModelDialog.TAG);
            }
        });
    }

    protected void showPredictorReadyViews() {
        takeVideoBtn.setVisibility(View.VISIBLE);
        chooseModelBtn.setVisibility(View.VISIBLE);
        loadingModelSpinner.setVisibility(View.GONE);
    }

    protected void showPredictorNotReadyViews() {
        takeVideoBtn.setVisibility(View.GONE);
        chooseModelBtn.setVisibility(View.GONE);
        loadingModelSpinner.setVisibility(View.VISIBLE);
    }

    private void showStartRecordingViews() {
        videoRecordingProgress.setVisibility(View.VISIBLE);
        videoRecordingProgress.setMax(NUM_PROGRESS_INTERVALS);
        videoRecordingProgress.setProgress(0);

        chooseModelBtn.setVisibility(View.GONE);
        mCountDownTimer = new CountDownTimer(MAX_RECORDING_TIME_MS, TIME_BETWEEN_RECORDING_INTERVAL_MS) {

            @Override
            public void onTick(long millisUntilFinished) {
                int progress = (int) (NUM_PROGRESS_INTERVALS - millisUntilFinished / TIME_BETWEEN_RECORDING_INTERVAL_MS);
                videoRecordingProgress.setProgress(progress);
            }

            @Override
            public void onFinish() {
                // finish recording when MAX_RECORDING_TIME_MS is met
                if (isRecording.compareAndSet(true, false)) {
                    videoRecordingProgress.setProgress(NUM_PROGRESS_INTERVALS);
                    showFinishRecordingViews();
                }
            }
        };
        mCountDownTimer.start();
    }

    private void showCameraViews() {
        overlayView.setVisibility(View.GONE);
        closeBtn.setVisibility(View.GONE);
        takeVideoBtn.setVisibility(View.VISIBLE);
        chooseModelBtn.setVisibility(View.VISIBLE);
        videoRecordingProgress.setProgress(0);
        videoRecordingProgress.setVisibility(View.GONE);
    }

    private void showFinishRecordingViews() {
        videoRecordingProgress.setProgress(0);
        takeVideoBtn.setVisibility(View.GONE);
        overlayView.setVisibility(View.VISIBLE);
        videoRecordingProgress.setVisibility(View.INVISIBLE);
        processingVideoProgress.setVisibility(View.VISIBLE);
        processingVideoProgress.setMax(videoProcessingQueue.getNumFramesToProcess());
        processingVideoProgress.setProgress(0);
    }

    private void showStyleResults() {
        processingVideoProgress.setVisibility(View.GONE);
        closeBtn.setVisibility(View.VISIBLE);
        overlayView.setVisibility(View.VISIBLE);
    }

    private void finishProcessing() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showStyleResults();
            }
        });
        processingProgress = 0;
        // Redraw the overlay view
        overlayView.postInvalidate();

        // This is a bit hacky but re-render the
        // overlay view with a new bitmap result after
        // a certain amount of time until all the bitmaps are shown.
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                if (processedBitmaps.isEmpty()) {
                    return;
                }
                overlayView.postInvalidate();
                playBackHandler.postDelayed(this, TIME_BETWEEN_FRAMES_MS + TIME_BUFFER_FRAMES_MS);
            }
        };
        runnable.run();
    }

    private FritzOnDeviceModel getStyleModel(int choice) {
        FritzOnDeviceModel[] styles = PaintingStyles.getAll();
        FritzOnDeviceModel onDeviceModel = styles[choice];
        return onDeviceModel;
    }

    public String getModelText(int choice) {
        String[] options = getResources().getStringArray(getModelOptionsTextId());
        return options[choice];
    }

    @Override
    public void onImageAvailable(final ImageReader reader) {
        Image image = reader.acquireLatestImage();

        if (image == null) {
            return;
        }

        // Save Images when we're recording
        if (!isRecording.get()) {
            image.close();
            return;
        }

        // Only grab a frame every 100ms
        if (System.currentTimeMillis() - lastRecordedFrameAt.get() < TIME_BETWEEN_FRAMES_MS) {
            image.close();
            return;
        }

        // Add the frame to a queue to process
        lastRecordedFrameAt.set(System.currentTimeMillis());
        final FritzVisionImage fritzImage = FritzVisionImage.fromMediaImage(image, imageRotationFromCamera);
        videoProcessingQueue.addVisionImage(fritzImage);
        image.close();
    }
}

