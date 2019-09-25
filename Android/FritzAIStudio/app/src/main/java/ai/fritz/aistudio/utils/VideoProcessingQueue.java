package ai.fritz.aistudio.utils;

import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;

import ai.fritz.vision.FritzVisionImage;

public class VideoProcessingQueue {
    private static final String TAG = VideoProcessingQueue.class.getSimpleName();

    public interface Listener {
        void processVisionImage(FritzVisionImage visionImage);

        void finishedProcessing();
    }

    private AtomicBoolean isProcessingQueue = new AtomicBoolean(false);

    private LinkedBlockingQueue<FritzVisionImage> recordedImages;
    private Listener listener;
    private Handler handler;


    public VideoProcessingQueue(Listener listener) {
        recordedImages = new LinkedBlockingQueue<>();
        this.listener = listener;
        HandlerThread handlerThread = new HandlerThread("Video Processing Thread");
        handlerThread.start();
        this.handler = new Handler(handlerThread.getLooper());
    }

    public void addVisionImage(FritzVisionImage visionImage) {
        recordedImages.add(visionImage);
        if (isProcessingQueue.compareAndSet(false, true)) {
            runQueueProcessor();
        }
    }

    public int getNumFramesToProcess() {
        return recordedImages.size();
    }

    private void runQueueProcessor() {
        handler.post(new Runnable() {
            @Override
            public void run() {
                while (!recordedImages.isEmpty()) {
                    FritzVisionImage visionImage = recordedImages.poll();
                    Log.d(TAG, "Processing Image");
                    listener.processVisionImage(visionImage);
                }
                listener.finishedProcessing();
                isProcessingQueue.set(false);
            }
        });
    }
}
