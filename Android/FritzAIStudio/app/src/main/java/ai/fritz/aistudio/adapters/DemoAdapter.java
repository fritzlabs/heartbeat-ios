package ai.fritz.aistudio.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;


import java.util.ArrayList;
import java.util.List;

import ai.fritz.aistudio.R;

/**
 * Demo items adapter to manage the list of models.
 */
public class DemoAdapter extends RecyclerView.Adapter<DemoAdapter.ViewHolder> {
    private List<DemoItem> demoItems = new ArrayList<>();

    /**
     * View holder for each demo item to display in the list.
     */
    public static class ViewHolder extends RecyclerView.ViewHolder {
        public LinearLayout linearLayout;
        public TextView titleView;
        public TextView descriptionView;

        public ViewHolder(LinearLayout v) {
            super(v);
            linearLayout = v;
            titleView = linearLayout.findViewById(R.id.title);
            descriptionView = linearLayout.findViewById(R.id.description);
        }
    }

    /**
     * Initialize the adapter with a list of demo items.
     *
     * @param demoItems
     */
    public DemoAdapter(List<DemoItem> demoItems) {
        this.demoItems = demoItems;
    }

    /**
     * Get the DemoItem and binds it to the recycled view.
     * <p>
     * Also sets the click actions here.
     *
     * @param holder
     * @param position
     */
    @Override
    public void onBindViewHolder(DemoAdapter.ViewHolder holder, int position) {
        DemoItem demoItem = demoItems.get(position);
        holder.titleView.setText(demoItem.getTitle());
        holder.descriptionView.setText(demoItem.getDescription());
        holder.linearLayout.setOnClickListener(demoItem.getOnClickListener());
    }

    /**
     * Get number of demo items.
     *
     * @return number of items in the list
     */
    @Override
    public int getItemCount() {
        return demoItems.size();
    }

    /**
     * Create a view holder for the DemoItems
     *
     * @param parent
     * @param viewType
     * @return
     */
    @Override
    public DemoAdapter.ViewHolder onCreateViewHolder(ViewGroup parent,
                                                     int viewType) {
        LinearLayout v = (LinearLayout) LayoutInflater.from(parent.getContext())
                .inflate(R.layout.list_item_demo, parent, false);
        ViewHolder holder = new ViewHolder(v);
        return holder;
    }
}
