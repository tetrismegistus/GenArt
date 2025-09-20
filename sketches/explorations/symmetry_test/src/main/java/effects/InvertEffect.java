package effects;

import com.krab.lazy.LazyGui;
import processing.core.PGraphics;

public class InvertEffect implements Effect {
    @Override
    public void apply(PGraphics canvas, LazyGui gui) {
        gui.pushFolder(label());

        boolean enabled = gui.toggle("enabled", false);
        if (!enabled) {
            gui.popFolder();
            return; // early exit
        }

        canvas.loadPixels();
        for (int i = 0; i < canvas.pixels.length; i++) {
            int c = canvas.pixels[i];
            int r = 255 - (c >> 16 & 0xFF);
            int g = 255 - (c >> 8 & 0xFF);
            int b = 255 - (c & 0xFF);
            int a = (c >> 24) & 0xFF;
            canvas.pixels[i] = canvas.parent.color(r, g, b, a);
        }
        canvas.updatePixels();

        gui.popFolder();
    }

    @Override
    public String label() {
        return "invert";
    }
}
