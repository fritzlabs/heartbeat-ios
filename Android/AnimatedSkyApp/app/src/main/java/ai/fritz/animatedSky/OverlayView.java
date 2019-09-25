package ai.fritz.animatedSky;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.view.View;

/**
 * A simple View providing a render callback to other classes.
 */
public class OverlayView extends View {
    private DrawCallback callback;

    public OverlayView(final Context context, final AttributeSet attrs) {
        super(context, attrs);
    }

    /**
     * Interface defining the callback for client classes.
     */
    public interface DrawCallback {
        public void drawCallback(final Canvas canvas);
    }

    public void setCallback(final DrawCallback callback) {
        this.callback = callback;
    }

    @Override
    public synchronized void draw(final Canvas canvas) {
        super.draw(canvas);
        if(callback != null) {
            callback.drawCallback(canvas);
        }
    }
}