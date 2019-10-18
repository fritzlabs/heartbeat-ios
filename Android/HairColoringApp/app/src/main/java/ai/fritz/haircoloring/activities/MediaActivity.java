package ai.fritz.haircoloring.activities;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.SurfaceTexture;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;

import com.github.veritas1.verticalslidecolorpicker.VerticalSlideColorPicker;

import java.io.IOException;

import ai.fritz.fritzvisionhairsegmentationmodel.HairSegmentationOnDeviceModelFast;
import ai.fritz.haircoloring.R;
import ai.fritz.haircoloring.views.AutoFitTextureView;
import ai.fritz.vision.FritzSurfaceView;
import ai.fritz.vision.FritzVision;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.imagesegmentation.BlendMode;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationPredictor;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationPredictorOptions;
import ai.fritz.vision.imagesegmentation.FritzVisionSegmentationResult;
import ai.fritz.vision.imagesegmentation.MaskClass;
import ai.fritz.vision.imagesegmentation.SegmentationOnDeviceModel;
import androidx.appcompat.app.AppCompatActivity;

public class MediaActivity extends AppCompatActivity implements TextureView.SurfaceTextureListener {
    private static final String TAG = MediaActivity.class.getSimpleName();

    private static final BlendMode BLEND_MODE = BlendMode.SOFT_LIGHT;
    private int maskColor = Color.RED;
    private int hairAlpha = 180;
    private float hairConfidenceThreshold = .5f;

    private FritzSurfaceView surfaceView;
    private AutoFitTextureView textureView;
    private MediaPlayer mediaPlayer;

    private SegmentationOnDeviceModel onDeviceModel;
    private FritzVisionSegmentationPredictor hairPredictor;
    private FritzVisionSegmentationPredictorOptions options;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video);

        onDeviceModel = new HairSegmentationOnDeviceModelFast();
        options = new FritzVisionSegmentationPredictorOptions();
        hairPredictor = FritzVision.ImageSegmentation.getPredictor(onDeviceModel, options);

        // View for overlaying a mask on the video
        surfaceView = findViewById(R.id.surface_view);

        // View for displaying the video
        // Each frame of the video will trigger onSurfaceTextureUpdated()
        textureView = findViewById(R.id.texture_view);
        textureView.setSurfaceTextureListener(this);

        // Loads video from a file path
        mediaPlayer = new MediaPlayer();
        try {
            mediaPlayer.setDataSource(getApplicationContext(),
                    Uri.parse(getIntent().getStringExtra(getResources().getString(R.string.video_path_key))));
        } catch (IOException e) {
            Log.d(TAG, e.getMessage());
        }

        VerticalSlideColorPicker colorPicker = findViewById(R.id.color_picker);
        // Change the mask color upon using the slider
        colorPicker.setOnColorChangeListener(new VerticalSlideColorPicker.OnColorChangeListener() {
            @Override
            public void onColorChange(int selectedColor) {
                if (selectedColor != Color.TRANSPARENT) {
                    maskColor = selectedColor;
                }
            }
        });
    }

    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int width, int height) {
        Surface surface = new Surface(surfaceTexture);
        // Give the video a view to display on
        mediaPlayer.setSurface(surface);
        // Allow the video to loop
        mediaPlayer.setLooping(true);
        // Prepare the video without blocking threads
        mediaPlayer.prepareAsync();
        // Start the video when loaded
        mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                mediaPlayer.start();
            }
        });
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surfaceTexture) {
        // Overlay the video with the blended hair mask on every update
        FritzVisionImage screenCapture = FritzVisionImage.fromBitmap(getBitmap());
        runPrediction(screenCapture);
    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surfaceTexture) {
        mediaPlayer.stop();
        mediaPlayer.release();
        hairPredictor.close();
        return true;
    }

    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surfaceTexture, int i, int i1) {
    }

    /**
     * Captures the current frame of the video.
     *
     * @return the current frame as a Bitmap.
     */
    private Bitmap getBitmap(){
        return textureView.getBitmap();
    }

    /**
     * Draws a blended mask on the view.
     *
     * @param visionImage the image to predict on.
     */
    private void runPrediction(FritzVisionImage visionImage) {
        FritzVisionSegmentationResult result = hairPredictor.predict(visionImage);
        Bitmap alphaMask = result.buildSingleClassMask(MaskClass.HAIR,
                hairAlpha, hairConfidenceThreshold, options.confidenceThreshold, maskColor);
        surfaceView.drawBlendedMask(visionImage, alphaMask, BLEND_MODE);
    }

    @Override
    public void onBackPressed() {
        Intent mainIntent = new Intent(this, MainActivity.class);
        startActivity(mainIntent);
    }
}
