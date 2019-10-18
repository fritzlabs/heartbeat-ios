package ai.fritz.haircoloring.activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.provider.MediaStore;

import ai.fritz.haircoloring.R;
import androidx.appcompat.app.AppCompatActivity;

public class PickerActivity extends AppCompatActivity {
    private static final int REQUEST_CODE = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent filePicker = new Intent(Intent.ACTION_PICK, MediaStore.Video.Media.EXTERNAL_CONTENT_URI);
        filePicker.putExtra(Intent.EXTRA_LOCAL_ONLY, true);
        startActivityForResult(filePicker, 1);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            String filePath = data.getData().toString();
            Intent player = new Intent(getApplicationContext(), MediaActivity.class);
            player.putExtra(getResources().getString(R.string.video_path_key), filePath);
            startActivity(player);
        }
        else {
            finish();
        }
    }
}