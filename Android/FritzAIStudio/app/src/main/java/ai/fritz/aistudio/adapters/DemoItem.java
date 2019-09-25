package ai.fritz.aistudio.adapters;

import android.view.View;

/**
 * Helper class to show demo items for the DemoAdapter
 */
public class DemoItem {

    private String title;
    private String description;
    private View.OnClickListener onClickListener;

    public DemoItem(String title, String description, View.OnClickListener clickListener) {
        this.title = title;
        this.description = description;
        this.onClickListener = clickListener;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public View.OnClickListener getOnClickListener() {
        return onClickListener;
    }

    public void setOnClickListener(View.OnClickListener onClickListener) {
        this.onClickListener = onClickListener;
    }
}
