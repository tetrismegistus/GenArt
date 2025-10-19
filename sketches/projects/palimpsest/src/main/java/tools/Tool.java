package tools;

import com.krab.lazy.LazyGui;
import processing.core.PGraphics;


public abstract class Tool {
    protected LazyGui gui;

    abstract void setupUI();
    abstract void drawPreview(PGraphics preview, float scale);
    abstract void bake(PGraphics canvas);
    abstract String getToolName();
}


