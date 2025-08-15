package effects;

import com.krab.lazy.LazyGui;
import processing.core.PGraphics;

public interface Effect {
    void apply(PGraphics canvas, LazyGui gui);
    String label();
}
