package effects;

import com.krab.lazy.LazyGui;
import processing.core.PGraphics;

public interface Effect {
    void apply(PGraphics canvas, LazyGui gui);
    String label();

    default void setCanvas(PGraphics canvas) {}
    default void setBackgroundColor(int bgColor) {}

    // Optional lifecycle hooks
    default void onEnable() {}
    default void onDisable() {}
    default void onResample() {}

    default String shaderPath() { return null; }

    // GUI scaffolding
    default boolean beginGui(LazyGui gui) {
        gui.pushFolder(label());
        boolean enabled = gui.toggle("enabled", false);
        if (enabled && gui.button("resample now")) onResample();
        return enabled;
    }

    default void endGui(LazyGui gui) {
        gui.popFolder();
    }
}
