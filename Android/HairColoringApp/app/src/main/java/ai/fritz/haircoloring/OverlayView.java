package ai.fritz.haircoloring;
/* Copyright 2016 The TensorFlow Authors. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

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
        void drawCallback(final Canvas canvas);
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