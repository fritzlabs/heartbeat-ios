package ai.fritz.aistudio.activities;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.View;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import ai.fritz.core.Fritz;
import ai.fritz.aistudio.PredictorType;
import ai.fritz.aistudio.R;
import ai.fritz.aistudio.adapters.DemoAdapter;
import ai.fritz.aistudio.adapters.DemoItem;
import ai.fritz.aistudio.ui.SeparatorDecoration;
import ai.fritz.aistudio.Navigation;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * The primary activity that shows the different model demos.
 */
public class MainActivity extends AppCompatActivity {

    private static final String FRITZ_URL = "https://fritz.ai";

    private Logger logger = Logger.getLogger(this.getClass().getName());

    @BindView(R.id.demo_list_view)
    RecyclerView recyclerView;

    @BindView(R.id.app_toolbar)
    Toolbar appBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        setTitle(R.string.demo_title);
        ButterKnife.bind(this);

        // customize the action bar
        setSupportActionBar(appBar);

        // Initialize Fritz
        Fritz.configure(this);

        // Setup the recycler view
        recyclerView.setHasFixedSize(true);
        LinearLayoutManager rvLinearLayoutMgr = new LinearLayoutManager(this);
        recyclerView.setLayoutManager(rvLinearLayoutMgr);

        // Add a divider
        SeparatorDecoration decoration = new SeparatorDecoration(this, Color.GRAY, 1);
        recyclerView.addItemDecoration(decoration);

        // Add the adapter
        DemoAdapter adapter = new DemoAdapter(getDemoItems());
        recyclerView.setAdapter(adapter);
        recyclerView.setClickable(true);
    }

    private List<DemoItem> getDemoItems() {
        // Add different demo items here
        List<DemoItem> demoItems = new ArrayList<>();
        demoItems.add(new DemoItem(
                getString(R.string.fritz_vision_title),
                getString(R.string.fritz_vision_description_live_video),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        logger.info("FRITZ VISION LIVE VIDEO");
                        Navigation.goToLabelingActivity(v.getContext());
                    }
                }));
        demoItems.add(new DemoItem(
                getString(R.string.fritz_object_detection_title),
                getString(R.string.fritz_object_detection_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Navigation.goToObjectDetection(v.getContext());
                    }
                }));
        demoItems.add(new DemoItem(
                getString(R.string.fritz_vision_style_transfer),
                getString(R.string.fritz_vision_style_transfer_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Navigation.goToStyleTransfer(v.getContext());
                    }
                }));
        demoItems.add(new DemoItem(
                getString(R.string.fritz_hair_color_title),
                getString(R.string.fritz_hair_color_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Navigation.goToHairSegmentation(v.getContext());
                    }
                }));
        demoItems.add(new DemoItem(
                getString(R.string.fritz_vision_img_seg_title),
                getString(R.string.fritz_vision_img_seg_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Navigation.goToImageSegmentation(v.getContext());
                    }
                }));
        demoItems.add(new DemoItem(
                getString(R.string.fritz_pose_estimation_title),
                getString(R.string.fritz_pose_estimation_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Navigation.goToPoseEstimation(v.getContext());
                    }
                }));
        demoItems.add(new DemoItem(
                getString(R.string.fritz_customtfmobile_title),
                getString(R.string.fritz_customtfmobile_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Navigation.goToTFMobile(v.getContext());
                    }
                }));
        demoItems.add(new DemoItem(
                getString(R.string.fritz_customtflite_title),
                getString(R.string.fritz_customtflite_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Navigation.goToTFLite(v.getContext());
                    }
                }));
        demoItems.add(new DemoItem(
                getString(R.string.fritz_info_title),
                getString(R.string.fritz_info_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent i = new Intent(Intent.ACTION_VIEW);
                        i.setData(Uri.parse(FRITZ_URL));
                        startActivity(i);
                    }
                }));
        return demoItems;
    }
}
