package ai.fritz.aistudio.activities.custommodel.ml;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.SystemClock;
import android.util.Log;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import ai.fritz.aistudio.R;
import ai.fritz.core.FritzManagedModel;
import ai.fritz.core.FritzOnDeviceModel;
import ai.fritz.core.ModelReadyListener;
import ai.fritz.core.utils.FritzModelManager;
import ai.fritz.customtflite.FritzTFLiteInterpreter;


public class MnistClassifier {
    private final String TAG = this.getClass().getSimpleName();

    // The tensorflow lite file
    private FritzTFLiteInterpreter tflite;

    // Input byte buffer
    private ByteBuffer imgData = null;

    // Output array [batch_size, 10]
    private float[][] mnistOutput = null;

    // Name of the file in the assets folder

    // Specify the output size
    private static final int NUMBER_LENGTH = 10;

    // Specify the input size
    private static final int DIM_BATCH_SIZE = 1;
    private static final int DIM_IMG_SIZE_X = 28;
    private static final int DIM_IMG_SIZE_Y = 28;
    private static final int DIM_PIXEL_SIZE = 1;

    // Number of bytes to hold a float (32 bits / float) / (8 bits / byte) = 4 bytes / float
    private static final int BYTE_SIZE_OF_FLOAT = 4;

    public MnistClassifier(Activity activity) {

        /**
         * This MNIST model provided is used to demonstrate custom models with TensorFlow Lite
         * and should not be used in production.
         */
        FritzManagedModel managedModel = new FritzManagedModel(activity.getString(R.string.tflite_model_id));
        FritzModelManager modelManager = new FritzModelManager(managedModel);
        modelManager.loadModel(new ModelReadyListener() {
            @Override
            public void onModelReady(FritzOnDeviceModel onDeviceModel) {
                tflite = new FritzTFLiteInterpreter(onDeviceModel);
                Log.d(TAG, "Interpreter is now ready to use");
            }
        });
        imgData =
                ByteBuffer.allocateDirect(
                        BYTE_SIZE_OF_FLOAT * DIM_BATCH_SIZE * DIM_IMG_SIZE_X * DIM_IMG_SIZE_Y * DIM_PIXEL_SIZE);
        imgData.order(ByteOrder.nativeOrder());
        mnistOutput = new float[DIM_BATCH_SIZE][NUMBER_LENGTH];
        Log.d(TAG, "Created a Tensorflow Lite MNIST Classifier.");
    }

    /**
     * Run the TFLite model
     */
    protected void runInference() {
        long startTime = SystemClock.uptimeMillis();
        tflite.run(imgData, mnistOutput);
        long endTime = SystemClock.uptimeMillis();
        Log.d(TAG, "Timecost to run model inference: " + Long.toString(endTime - startTime));
    }

    /**
     * Classifies the number with the mnist model.
     *
     * @param bitmap
     * @return the identified number
     */
    public int classify(Bitmap bitmap) {
        if (tflite == null) {
            Log.e(TAG, "Image classifier has not been initialized; Skipped.");
            return -1;
        }
        convertBitmapToByteBuffer(bitmap);
        runInference();

        return getResult();
    }

    /**
     * Go through the output and find the number that was identified.
     *
     * @return the number that was identified (returns -1 if one wasn't found)
     */
    private int getResult() {
        for (int i = 0; i < mnistOutput[0].length; i++) {
            float value = mnistOutput[0][i];
            Log.d(TAG, "Output for " + Integer.toString(i) + ": " + Float.toString(value));
            if (value == 1f) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Converts it into the Byte Buffer to feed into the model
     *
     * @param bitmap
     */
    private void convertBitmapToByteBuffer(Bitmap bitmap) {
        if (bitmap == null || imgData == null) {
            return;
        }

        // Reset the image data
        imgData.rewind();

        int width = bitmap.getWidth();
        int height = bitmap.getHeight();

        long startTime = SystemClock.uptimeMillis();

        // The bitmap shape should be 28 x 28
        int[] pixels = new int[width * height];
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height);

        for (int i = 0; i < pixels.length; ++i) {
            // Set 0 for white and 255 for black pixels
            int pixel = pixels[i];
            int b = pixel & 0xff;
            imgData.putFloat(0xff - b);
        }
        long endTime = SystemClock.uptimeMillis();
        Log.d(TAG, "Time cost to put values into ByteBuffer: " + Long.toString(endTime - startTime));
    }
}
