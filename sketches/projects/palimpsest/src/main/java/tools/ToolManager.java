package tools;

import processing.core.PGraphics;

import java.util.List;

public class ToolManager {
    private List<Tool> tools;

    void setupAllUI() {
        for (Tool t : tools) t.setupUI();
    }

    void drawAllPreviews(PGraphics canvas, float scale) {
        for (Tool t : tools) t.drawPreview(canvas, scale);
    }
}
