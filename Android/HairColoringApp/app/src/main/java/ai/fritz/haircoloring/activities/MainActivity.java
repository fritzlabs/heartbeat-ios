package ai.fritz.haircoloring.activities;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;

import java.util.ArrayList;
import java.util.List;

import ai.fritz.core.Fritz;
import ai.fritz.haircoloring.R;
import ai.fritz.haircoloring.ui.DemoAdapter;
import ai.fritz.haircoloring.ui.DemoItem;
import ai.fritz.haircoloring.ui.SeparatorDecoration;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public class MainActivity extends AppCompatActivity {
    private static final String API_KEY = "bbe75c73f8b24e63bc05bf81ed9d2829";

    private RecyclerView recyclerView;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Fritz.configure(this, API_KEY);
        setContentView(R.layout.activity_main);

        recyclerView = findViewById(R.id.demo_list_view);
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
        List<DemoItem> demoItems = new ArrayList<>();

        demoItems.add(new DemoItem(
                getString(R.string.fritz_hair_color_title),
                getString(R.string.fritz_hair_color_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Context context = v.getContext();
                        Intent liveHair = new Intent(context, CameraActivity.class);
                        context.startActivity(liveHair);
                    }
                }));

        demoItems.add(new DemoItem(
                getString(R.string.fritz_video_hair_color_title),
                getString(R.string.fritz_video_hair_color_description),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Context context = v.getContext();
                        Intent selectVideo = new Intent(context, PickerActivity.class);
                        context.startActivity(selectVideo);
                    }
                }));

        return demoItems;
    }
}
