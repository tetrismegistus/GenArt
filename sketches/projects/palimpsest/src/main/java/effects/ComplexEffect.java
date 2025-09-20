package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.opengl.PShader;

public class ComplexEffect implements Effect {
    private static final String SHADER_PATH = "shaders/z0.glsl";

    // Output buffer to draw into (your 'edited' PG)
    private PGraphics target;

    // Immutable snapshot captured when the effect is enabled
    private PImage frozenInput;

    // Track toggle state to detect rising edge
    private boolean wasEnabled = false;

    // Params/state
    private int bgColor = 0xFF000000; // opaque black

    /** Attach the output canvas this effect renders to. */
    public void setCanvas(PGraphics canvas) {
        this.target = canvas;
    }

    /** Optional background color (if your shader uses it). */
    public void setBackgroundColor(int bg) {
        this.bgColor = bg;
    }

    @Override
    public void apply(PGraphics ignoredCanvas, LazyGui gui) {
        gui.pushFolder(label());
        boolean enabled = gui.toggle("enabled", false);

        // Rising edge: capture a one-time snapshot of the current target
        if (enabled && !wasEnabled) {
            captureSnapshot();
        }

        // Manual re-snapshot button while enabled
        if (enabled && gui.button("resample now")) {
            captureSnapshot();
        }



        // Early outs
        if (!enabled) {
            wasEnabled = false;
            gui.popFolder();
            return;
        }
        if (target == null || frozenInput == null) {
            // Can't run: no output or no snapshot yet
            wasEnabled = true;
            gui.popFolder();
            return;
        }

        // UI params
        gui.pushFolder("complex");
        float range = gui.slider("range", 30.0f, 0.0f, 30.0f);
        float aReal = gui.slider("aReal", 2.0f, -30f, 30f);
        float aImag = gui.slider("aImag", -0.2f, -30f, 30f);
        float bReal = gui.slider("bReal", 0.0f, -30f, 30f);
        float bImag = gui.slider("bImag", -0.7f, -30f, 30f);
        float cReal = gui.slider("cReal", 2.0f, -30f, 30f);
        float cImag = gui.slider("cImag", -0.2f, -30f, 30f);
        float dReal = gui.slider("dReal", 0.0f, -30f, 30f);
        float dImag = gui.slider("dImag", -0.7f, -30f, 30f);
        gui.popFolder();

        // Extract RGB without touching colorMode
        float r = ((bgColor >> 16) & 0xFF) / 255f;
        float g = ((bgColor >>  8) & 0xFF) / 255f;
        float b = ((bgColor      ) & 0xFF) / 255f;

        PShader shader = ShaderReloader.getShader(SHADER_PATH);
        if (shader == null) {
            wasEnabled = true;
            gui.popFolder();
            return;
        }

        // Output resolution
        shader.set("resolution", (float) target.width, (float) target.height);

        // Immutable input + its own resolution (in case it differs)
        shader.set("inputTexture", frozenInput);
        shader.set("inputResolution", (float) frozenInput.width, (float) frozenInput.height);

        // Params
        shader.set("range", range);
        shader.set("aReal", aReal); shader.set("aImag", aImag);
        shader.set("bReal", bReal); shader.set("bImag", bImag);
        shader.set("cReal", cReal); shader.set("cImag", cImag);
        shader.set("dReal", dReal); shader.set("dImag", dImag);

        // Optional bg color
        shader.set("bgColor", r, g, b, 1.0f);

        // Run the shader on the output only (sampling the frozen input)
        target.beginDraw();
        ShaderReloader.filter(SHADER_PATH, target);
        target.endDraw();

        wasEnabled = true;
        gui.popFolder();
    }

    /** Take a one-time snapshot of the current target to use as immutable input. */
    private void captureSnapshot() {
        if (target != null) {
            // PGraphics.get() → PImage snapshot
            frozenInput = target.get();
        } else {
            frozenInput = null;
        }
    }

    @Override
    public String label() { return "complex"; }
}
