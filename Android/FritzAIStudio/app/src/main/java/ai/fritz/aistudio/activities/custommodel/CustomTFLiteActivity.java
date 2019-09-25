package ai.fritz.aistudio.activities.custommodel;

import android.graphics.PointF;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import ai.fritz.aistudio.R;
import ai.fritz.aistudio.activities.custommodel.ml.MnistClassifier;
import ai.fritz.aistudio.ui.DrawModel;
import ai.fritz.aistudio.ui.DrawView;
import butterknife.BindView;
import butterknife.ButterKnife;


public class CustomTFLiteActivity extends AppCompatActivity {
    private final String TAG = this.getClass().getSimpleName();

    private static final int PIXEL_WIDTH = 28;

    private float lastX;
    private float lastY;

    private DrawModel drawModel;

    private PointF fPoint = new PointF();

    private MnistClassifier mnistClassifier;

    @BindView(R.id.view_draw)
    DrawView mDrawView;

    @BindView(R.id.button_detect)
    View detectButton;

    @BindView(R.id.button_clear)
    View clearButton;

    @BindView(R.id.text_result)
    TextView mResultText;

    @BindView(R.id.app_toolbar)
    Toolbar appBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mnist);
        setTitle(R.string.app_name);
        ButterKnife.bind(this);

        setSupportActionBar(appBar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        mnistClassifier = new MnistClassifier(this);

        drawModel = new DrawModel(PIXEL_WIDTH, PIXEL_WIDTH);

        mDrawView.setModel(drawModel);
        mDrawView.setOnTouchListener(new DrawOnTouchListener());

        detectButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onDetectClicked();
            }
        });

        clearButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClearClicked();
            }
        });
    }

    @Override
    protected void onResume() {
        mDrawView.onResume();
        super.onResume();
    }

    @Override
    protected void onPause() {
        mDrawView.onPause();
        super.onPause();
    }

    private void onDetectClicked() {
        int digit = mnistClassifier.classify(mDrawView.getDrawnBitmap());
        if (digit >= 0) {
            Log.d(TAG, "Found Digit = " + digit);
            mResultText.setText(getString(R.string.found_digits, String.valueOf(digit)));
        } else {
            mResultText.setText(getString(R.string.not_detected));
        }
    }

    private void onClearClicked() {
        drawModel.clear();
        mDrawView.reset();
        mDrawView.invalidate();
        mResultText.setText("");
    }

    /**
     * DrawOnTouchListener to handle drawing actions.
     */
    public class DrawOnTouchListener implements View.OnTouchListener {
        @Override
        public boolean onTouch(View v, MotionEvent event) {
            int action = event.getAction() & MotionEvent.ACTION_MASK;

            if (action == MotionEvent.ACTION_DOWN) {
                processTouchDown(event);
                return true;

            } else if (action == MotionEvent.ACTION_MOVE) {
                processTouchMove(event);
                return true;

            } else if (action == MotionEvent.ACTION_UP) {
                processTouchUp();
                return true;
            }
            return false;
        }

        private void processTouchDown(MotionEvent event) {
            lastX = event.getX();
            lastY = event.getY();
            mDrawView.calcPos(lastX, lastY, fPoint);
            float lastConvX = fPoint.x;
            float lastConvY = fPoint.y;
            drawModel.startLine(lastConvX, lastConvY);
        }

        private void processTouchMove(MotionEvent event) {
            float x = event.getX();
            float y = event.getY();

            mDrawView.calcPos(x, y, fPoint);
            float newConvX = fPoint.x;
            float newConvY = fPoint.y;
            drawModel.addLineElem(newConvX, newConvY);

            lastX = x;
            lastY = y;
            mDrawView.invalidate();
        }

        private void processTouchUp() {
            drawModel.endLine();
        }

    }
}


