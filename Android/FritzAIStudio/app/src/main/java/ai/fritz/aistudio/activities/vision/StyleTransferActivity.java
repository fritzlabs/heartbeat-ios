package ai.fritz.aistudio.activities.vision;

import android.graphics.Bitmap;
import android.media.ImageReader.OnImageAvailableListener;
import android.os.Bundle;
import android.util.Size;

import ai.fritz.core.FritzOnDeviceModel;
import ai.fritz.fritzvisionstylepaintings.PaintingStyles;
import ai.fritz.aistudio.R;
import ai.fritz.aistudio.activities.BaseRecordingActivity;
import ai.fritz.vision.FritzVision;
import ai.fritz.vision.FritzVisionImage;
import ai.fritz.vision.styletransfer.FritzVisionStylePredictor;
import ai.fritz.vision.styletransfer.FritzVisionStylePredictorOptions;
import ai.fritz.vision.styletransfer.FritzVisionStyleResult;


public class StyleTransferActivity extends BaseRecordingActivity implements OnImageAvailableListener {
    private FritzVisionStylePredictor predictor;

    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected int getModelOptionsTextId() {
        return R.array.style_transfer_options;
    }

    @Override
    protected Bitmap runPrediction(FritzVisionImage visionImage, Size cameraViewSize) {
        FritzVisionStyleResult styleResult = predictor.predict(visionImage);
        return styleResult.toBitmap();
    }

    @Override
    protected void loadPredictor(int choice) {
        FritzOnDeviceModel onDeviceModel = getModel(choice);
        FritzVisionStylePredictorOptions options = new FritzVisionStylePredictorOptions();
        predictor = FritzVision.StyleTransfer.getPredictor(onDeviceModel, options);
    }

    private FritzOnDeviceModel getModel(int choice) {
        FritzOnDeviceModel[] styles = PaintingStyles.getAll();
        return styles[choice];
    }
}

