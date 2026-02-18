package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.opengl.PShader;

/**
 * ComplexEffect (stackable, ping-pong compliant)
 *
 * Contract under ping-pong:
 * - liveCanvas = src (input), set via setCanvas(src) by the app
 * - apply(canvas, gui) receives canvas = dst (output) for this stage
 *
 * This effect uses a "frozen input" snapshot by default:
 * - When enabled, captureSnapshotFromLiveCanvas() freezes the current src.
 * - Resample refreshes frozenInput from current src.
 * - The shader samples frozenInput (not liveCanvas) intentionally.
 *
 * If you want this effect to sample the current stack state instead,
 * replace frozenInput with liveCanvas.get() (but keep dst rendering).
 */
public class ComplexEffect extends BaseEffect {

    private static final String SHADER_PATH = "shaders/z0.glsl";

    @Override
    public void apply(PGraphics dst, LazyGui gui) {
        if (!beginGui(gui)) {
            endGui(gui);
            return;
        }

        // Ensure we have a snapshot to sample.
        // (onEnable already captures, but this covers load/regenerate/order changes.)
        if (frozenInput == null && liveCanvas != null) {
            captureSnapshotFromLiveCanvas();
        }

        final PImage srcTex = frozenInput;
        if (srcTex == null) {
            endGui(gui);
            return;
        }

        gui.pushFolder("complex");
        float range = gui.slider("range", 30.0f);
        float aReal = gui.slider("aReal", 2.0f);
        float aImag = gui.slider("aImag", -0.2f);
        float bReal = gui.slider("bReal", 0.0f);
        float bImag = gui.slider("bImag", -0.7f);
        float cReal = gui.slider("cReal", 2.0f);
        float cImag = gui.slider("cImag", -0.2f);
        float dReal = gui.slider("dReal", 0.0f);
        float dImag = gui.slider("dImag", -0.7f);
        gui.popFolder();

        float[] bg = getBackgroundColorComponents();

        // Build shader and render into dst from srcTex
        PShader shader = ShaderReloader.getShader(shaderPath());
        if (shader != null) {
            shader.set("resolution", (float) dst.width, (float) dst.height);

            // Sample frozen snapshot (intentional "frozen input" behavior)
            shader.set("inputTexture", srcTex);
            shader.set("inputResolution", (float) srcTex.width, (float) srcTex.height);

            shader.set("range", range);

            shader.set("aReal", aReal);
            shader.set("aImag", aImag);
            shader.set("bReal", bReal);
            shader.set("bImag", bImag);
            shader.set("cReal", cReal);
            shader.set("cImag", cImag);
            shader.set("dReal", dReal);
            shader.set("dImag", dImag);

            shader.set("bgColor", bg[0], bg[1], bg[2], 1.0f);

            // IMPORTANT: render shader into dst (output), do not in-place filter.
            dst.beginDraw();
            dst.shader(shader);
            dst.noStroke();
            dst.rect(0, 0, dst.width, dst.height);
            dst.resetShader();
            dst.endDraw();
        }

        endGui(gui);
    }

    @Override
    public void onEnable() {
        captureSnapshotFromLiveCanvas();
    }

    @Override
    public void onResample() {
        captureSnapshotFromLiveCanvas();
    }

    @Override
    public String label() {
        return "effects/complex";
    }

    @Override
    public String shaderPath() {
        return SHADER_PATH;
    }
}
