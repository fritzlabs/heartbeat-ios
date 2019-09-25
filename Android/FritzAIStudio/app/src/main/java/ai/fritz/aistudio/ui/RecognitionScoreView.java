package ai.fritz.aistudio.ui;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;

import java.util.ArrayList;
import java.util.List;

import ai.fritz.aistudio.activities.custommodel.ml.Classifier.Recognition;
import ai.fritz.vision.FritzVisionLabel;

public class RecognitionScoreView extends View implements ResultsView {
    private static final float TEXT_SIZE_DIP = 24;
    private List<Recognition> results = new ArrayList<>();
    private List<FritzVisionLabel> labels = new ArrayList<>();
    private final float textSizePx;
    private final Paint fgPaint;
    private final Paint bgPaint;

    public RecognitionScoreView(final Context context, final AttributeSet set) {
        super(context, set);

        textSizePx =
                TypedValue.applyDimension(
                        TypedValue.COMPLEX_UNIT_DIP, TEXT_SIZE_DIP, getResources().getDisplayMetrics());
        fgPaint = new Paint();
        fgPaint.setTextSize(textSizePx);

        bgPaint = new Paint();
        bgPaint.setColor(0xcc4285f4);
    }

    @Override
    public void setResults(final List<Recognition> results) {
        this.results = results;
        postInvalidate();
    }

    @Override
    public void setResult(final List<FritzVisionLabel> labels) {
        this.labels = labels;
        postInvalidate();
    }

    @Override
    public void onDraw(final Canvas canvas) {
        final int x = 10;
        int y = (int) (fgPaint.getTextSize() * 1.5f);

        canvas.drawPaint(bgPaint);

        if (results.size() > 0) {
            for (final Recognition recog : results) {
                canvas.drawText(recog.getTitle() + ": " + recog.getConfidence(), x, y, fgPaint);
                y += fgPaint.getTextSize() * 1.5f;
            }
        }

        if (labels.size() > 0) {
            for (final FritzVisionLabel label : labels) {
                canvas.drawText(label.getText() + ": " + label.getConfidence(), x, y, fgPaint);
                y += fgPaint.getTextSize() * 1.5f;
            }
        }
    }
}
