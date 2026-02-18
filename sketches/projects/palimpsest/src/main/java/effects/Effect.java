package effects;

import com.krab.lazy.LazyGui;
import processing.core.PGraphics;

/**
 * Effect
 *
 * STACKING CONTRACT (ping-pong):
 *
 * The app will build a stacked preview by ping-ponging between two buffers:
 *
 *   for each effect stage:
 *     fx.setCanvas(src);          // src = current stack state (read-only input)
 *     blit(src, dst);             // dst starts as a copy of src (so disabled effects no-op)
 *     fx.apply(dst, gui);         // effect writes output into dst (may overwrite or layer)
 *
 * Therefore:
 * - The canvas argument to apply(...) is the OUTPUT buffer (dst) for this stage.
 * - The input to the effect is the PGraphics passed via setCanvas(...), typically stored as "liveCanvas".
 * - Effects must NOT assume apply(...) is an in-place transform of the argument.
 * - For shader effects: do not sample from the same surface you render into; sample from src (liveCanvas),
 *   render into dst (the apply(...) argument).
 *
 * GUI:
 * - label() is the folder root key (recommended: "effects/<name>").
 * - beginGui/endGui provide a consistent enable toggle and optional resample button.
 * - BaseEffect may override beginGui(...) to fire edge-trigger lifecycle events (onEnable/onDisable).
 */
public interface Effect {

    /**
     * Apply the effect for this stage.
     *
     * @param canvas Output buffer (dst) to render into for this stage.
     *               Input is provided separately via setCanvas(src).
     */
    void apply(PGraphics canvas, LazyGui gui);

    /**
     * Stable GUI folder root key. Recommended: "effects/<name>".
     * Must remain stable across runs to preserve UI state.
     */
    String label();

    /* ============================== Context wiring ============================== */

    /**
     * Input buffer for this stage (src). The app sets this before apply(...).
     * Effects should treat this as read-only and use it as the source texture/image.
     */
    default void setCanvas(PGraphics canvas) {}

    /**
     * Current background color (packed ARGB int, usually forced opaque).
     * Effects that need background in shaders can unpack this into 0..1 RGB.
     */
    default void setBackgroundColor(int bgColor) {}

    /* ============================== Lifecycle (optional) ============================== */

    /** Rising-edge hook when enabled becomes true (if implemented by BaseEffect). */
    default void onEnable() {}

    /** Falling-edge hook when enabled becomes false (if implemented by BaseEffect). */
    default void onDisable() {}

    /** Called when user requests resampling (e.g., refresh frozen input). */
    default void onResample() {}

    /* ============================== Shader (optional) ============================== */

    /** Optional shader path for shader-driven effects; may be null. */
    default String shaderPath() { return null; }

    /* ============================== GUI scaffold ============================== */

    /**
     * Standard GUI scaffold.
     * Typical usage inside apply(...):
     *   if (!beginGui(gui)) { endGui(gui); return; }
     *   ... draw ...
     *   endGui(gui);
     */
    default boolean beginGui(LazyGui gui) {
        gui.pushFolder(label());
        boolean enabled = gui.toggle("enabled", false);
        if (enabled && gui.button("resample now")) onResample();
        return enabled;
    }

    /** Must be paired with beginGui(gui) on all exits. */
    default void endGui(LazyGui gui) {
        gui.popFolder();
    }
}
