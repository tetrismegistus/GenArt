package effects;

import com.krab.lazy.LazyGui;
import processing.core.PGraphics;
import processing.core.PImage;

public abstract class BaseEffect implements Effect {
    protected PGraphics liveCanvas;
    protected PImage frozenInput;
    protected int bgColor;
    protected boolean wasEnabled;

    protected BaseEffect() {
        // enforce naming convention
        String lbl = label();
        if (lbl == null || !lbl.startsWith("effects/")) {
            throw new IllegalArgumentException(
                    "Effect label must start with 'effects/': " + lbl
            );
        }
    }

    @Override
    public void setCanvas(PGraphics canvas) {
        this.liveCanvas = canvas;
    }

    @Override
    public void setBackgroundColor(int bgColor) {
        this.bgColor = bgColor;
    }

    /**
     * Default implementation of beginGui that handles the common enable toggle and resample button.
     * Child effects can override this if they need custom GUI behavior but should generally call super.
     */
    @Override
    public boolean beginGui(LazyGui gui) {
        gui.pushFolder(label());
        boolean enabled = gui.toggle("enabled", false);

        if (enabled && !wasEnabled) {
            onEnable();
        } else if (!enabled && wasEnabled) {
            onDisable();
        }

        if (enabled && gui.button("resample now")) {
            onResample();
        }

        wasEnabled = enabled;
        return enabled;
    }

    @Override
    public void endGui(LazyGui gui) {
        gui.popFolder();
    }

    /**
     * Helper: capture a frozen snapshot of the live canvas.
     * Common pattern used by most effects.
     */
    protected void captureSnapshotFromLiveCanvas() {
        frozenInput = (liveCanvas != null) ? liveCanvas.get() : null;
    }

    /**
     * Default lifecycle stubs — subclasses can override.
     */
    @Override public void onEnable() {}
    @Override public void onDisable() {}
    @Override public void onResample() {}

    /**
     * Optional: convenience method for normalized background color values.
     */
    protected float[] getBackgroundColorComponents(PGraphics canvas) {
        canvas.beginDraw();
        canvas.colorMode(PGraphics.RGB, 255, 255, 255, 100);
        float r = canvas.red(bgColor) / 255f;
        float g = canvas.green(bgColor) / 255f;
        float b = canvas.blue(bgColor) / 255f;
        canvas.endDraw();
        return new float[]{r, g, b};
    }
}
