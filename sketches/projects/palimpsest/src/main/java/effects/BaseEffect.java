package effects;

import com.krab.lazy.LazyGui;
import processing.core.PGraphics;
import processing.core.PImage;

/**
 * BaseEffect
 *
 * Stacking model (ping-pong):
 * - The app calls setCanvas(src) before apply(dst, gui).
 * - src is the INPUT for this stage (read-only).
 * - The PGraphics passed to apply(...) is the OUTPUT (dst) for this stage.
 *
 * Responsibilities:
 * - Enforce label() naming convention: "effects/..."
 * - Provide consistent GUI scaffold:
 *     effects/<name>/enabled
 *     effects/<name>/resample now
 * - Edge-trigger lifecycle hooks:
 *     onEnable() on rising edge of enabled toggle
 *     onDisable() on falling edge of enabled toggle
 * - Provide snapshot support (frozenInput) for effects that want stable input.
 * - Store background color and provide normalized RGB components (0..1).
 */
public abstract class BaseEffect implements Effect {

    /**
     * Stage input (src). Set by the app before apply(dst, gui).
     * Treat as read-only.
     */
    protected PGraphics liveCanvas;

    /**
     * Optional snapshot of stage input (src). Common for shader effects that want stable input.
     * By default cleared on disable.
     */
    protected PImage frozenInput;

    /**
     * Background color as packed ARGB int (forced opaque).
     */
    protected int bgColor = 0xFFFFFFFF;

    /**
     * Tracks previous enabled state for edge-trigger lifecycle.
     */
    protected boolean wasEnabled = false;

    protected BaseEffect() {
        final String lbl = label();
        if (lbl == null || !lbl.startsWith("effects/")) {
            throw new IllegalArgumentException("Effect label must start with 'effects/': " + lbl);
        }
    }

    /* ============================== Context wiring ============================== */

    @Override
    public void setCanvas(PGraphics canvas) {
        // canvas here is src (input) under the ping-pong contract
        this.liveCanvas = canvas;
    }

    @Override
    public void setBackgroundColor(int bgColor) {
        this.bgColor = (bgColor | 0xFF000000);
    }

    /* ============================== Lifecycle ============================== */

    /**
     * Default behavior: clear snapshots when disabled.
     * Most "frozen input" effects want this.
     */
    @Override
    public void onDisable() {
        frozenInput = null;
    }

    @Override public void onEnable()  {}
    @Override public void onResample() {}

    /* ============================== GUI scaffold ============================== */

    @Override
    public boolean beginGui(LazyGui gui) {
        gui.pushFolder(label());

        final boolean enabled = gui.toggle("enabled", false);

        if (enabled && !wasEnabled) {
            onEnable();
        } else if (!enabled && wasEnabled) {
            onDisable();
        }
        wasEnabled = enabled;

        if (enabled && gui.button("resample now")) {
            onResample();
        }

        return enabled;
    }

    @Override
    public void endGui(LazyGui gui) {
        gui.popFolder();
    }

    /* ============================== Snapshot helpers ============================== */

    /**
     * Capture a frozen snapshot of the current stage input (src).
     * Under ping-pong, this snapshots liveCanvas (the input), not the output dst.
     */
    protected final void captureSnapshotFromLiveCanvas() {
        frozenInput = (liveCanvas != null) ? liveCanvas.get() : null;
    }

    /* ============================== Color helpers ============================== */

    /**
     * Background RGB components normalized to 0..1 from packed ARGB.
     * Independent of Processing colorMode.
     */
    protected final float[] getBackgroundColorComponents() {
        float r = ((bgColor >> 16) & 0xFF) / 255f;
        float g = ((bgColor >> 8)  & 0xFF) / 255f;
        float b = ( bgColor        & 0xFF) / 255f;
        return new float[]{ r, g, b };
    }

    /**
     * Compatibility overload for older call sites.
     */
    protected final float[] getBackgroundColorComponents(PGraphics ignored) {
        return getBackgroundColorComponents();
    }

    /* ============================== Optional conveniences ============================== */

    protected final boolean hasLiveCanvas() {
        return liveCanvas != null;
    }

    protected final boolean hasFrozenInput() {
        return frozenInput != null;
    }
}
