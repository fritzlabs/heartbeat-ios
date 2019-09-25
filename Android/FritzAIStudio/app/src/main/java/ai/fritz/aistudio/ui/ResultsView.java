package ai.fritz.aistudio.ui;

import java.util.List;

import ai.fritz.aistudio.activities.custommodel.ml.Classifier.Recognition;
import ai.fritz.vision.FritzVisionLabel;

public interface ResultsView {
    void setResults(final List<Recognition> results);

    void setResult(final List<FritzVisionLabel> labels);
}
