package ai.fritz.aistudio.ui;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;

import ai.fritz.aistudio.R;

public class ChooseModelDialog extends DialogFragment {

    public static final String TAG = ChooseModelDialog.class.getSimpleName();

    private int choice = 0;
    private int itemsResourceId;
    private DialogInterface.OnClickListener listener;

    public ChooseModelDialog(int itemsResourceId, DialogInterface.OnClickListener listener) {
        this.itemsResourceId = itemsResourceId;
        this.listener = listener;
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        // Use the Builder class for convenient dialog construction
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity(), R.style.CustomDialog);
        builder.setTitle(R.string.available_models)
                .setItems(itemsResourceId, listener);
        // Create the AlertDialog object and return it
        return builder.create();
    }

    public int getChoice() {
        return choice;
    }
}
