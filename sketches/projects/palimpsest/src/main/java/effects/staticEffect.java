package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.opengl.PShader;

import static processing.core.PConstants.RGB;

public class staticEffect implements Effect
{
    private final String shaderPath = "shaders/static.glsl";

    // Live canvas reference (the thing we draw into each frame)
    private PGraphics liveCanvas = null;

    // Immutable snapshot captured when the effect is enabled (real PImage copy)
    private PImage frozenInput = null;
    private int bgColor;
    // Track toggle state to detect rising edge
    private boolean wasEnabled = false;

    public void setCanvas(PGraphics canvas) {
        // store the live canvas reference — don't confuse with frozenInput
        this.liveCanvas = canvas;
    }

    @Override
    public void apply(PGraphics canvas, LazyGui gui) {
        gui.pushFolder(label());

        boolean enabled = gui.toggle("enabled", false);

        // Rising edge: enabled just turned true
        if (enabled && !wasEnabled) {
            captureSnapshotFromLiveCanvas();
        }

        // Manual re-snapshot button while enabled
        if (enabled && gui.button("resample now")) {
            captureSnapshotFromLiveCanvas();
        }

        if (!enabled) {
            // update wasEnabled before exiting so next rising edge is detected
            wasEnabled = enabled;
            gui.popFolder();
            return;
        }

        if (frozenInput == null) {
            // Can't run: no snapshot yet (show an informative placeholder)
            // optionally capture automatically if liveCanvas exists:
            if (liveCanvas != null) {
                captureSnapshotFromLiveCanvas();
            }
            // if still null, bail out while making sure wasEnabled is correct
            wasEnabled = enabled;
            gui.popFolder();
            return;
        }

        float time = canvas.parent.millis() / 1000.0f;

        // GUI-controlled noise parameters
        float scale = gui.slider("scale", 5f);
        float gain = gui.slider("gain", 0.45f);

        // Per-channel brightness minimums
        float brightMinR = gui.slider("min R", 0.2f);
        float brightMinG = gui.slider("min G", 0.2f);
        float brightMinB = gui.slider("min B", 0.2f);

        // RGB conversion of background color
        canvas.beginDraw();
        canvas.colorMode(RGB, 255, 255, 255, 100);
        float r = canvas.red(bgColor) / 255f;
        float g = canvas.green(bgColor) / 255f;
        float b = canvas.blue(bgColor) / 255f;
        canvas.endDraw();

        PShader shader = ShaderReloader.getShader(shaderPath);
        if (shader == null) {
            wasEnabled = enabled;
            gui.popFolder();
            return;
        }

        shader.set("u_baseColor", r, g, b);
        shader.set("u_resolution", (float) canvas.width, (float) canvas.height);


        canvas.beginDraw();
        ShaderReloader.filter(shaderPath, canvas);
        canvas.endDraw();

        // update wasEnabled at end for proper next-frame rising-edge detection
        wasEnabled = enabled;
        gui.popFolder();
    }

    public void setBackgroundColor(int bg) {
        this.bgColor = bg;
    }

    // Helper that actually takes a snapshot copy from the live canvas
    private void captureSnapshotFromLiveCanvas() {
        if (liveCanvas != null) {
            // PGraphics.get() returns a PImage copy — exactly what we want
            frozenInput = liveCanvas.get();
        } else {
            frozenInput = null;
        }
    }

    // Backwards-compatible capture if you want to force a PImage in
    private void captureSnapshot(PImage pi) {
        if (pi != null) {
            // Make a copy to be safe (avoid aliasing the caller's image)
            frozenInput = pi.get();
        } else {
            frozenInput = null;
        }
    }

    @Override
    public String label() {
        return "static";
    }
}
