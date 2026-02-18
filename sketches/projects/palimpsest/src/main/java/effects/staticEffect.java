package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.opengl.PShader;

/**
 * staticEffect (stackable, ping-pong compliant)
 *
 * Ping-pong contract:
 * - liveCanvas = src (input), set by app via setCanvas(src)
 * - apply(dst, gui) receives dst = output buffer for this stage
 *
 * This effect uses a frozen snapshot by default:
 * - onEnable/onResample capture snapshot from src into frozenInput
 * - shader samples frozenInput
 */
public class staticEffect extends BaseEffect {

    private static final String SHADER_PATH = "shaders/static.glsl";

    @Override
    public void apply(PGraphics dst, LazyGui gui) {
        if (!beginGui(gui)) {
            endGui(gui);
            return;
        }

        // Ensure snapshot exists before running
        if (frozenInput == null && liveCanvas != null) {
            captureSnapshotFromLiveCanvas();
        }

        final PImage srcTex = frozenInput;
        if (srcTex == null) {
            endGui(gui);
            return;
        }

        // Get background color as normalized floats
        float[] bg = getBackgroundColorComponents();

        // Load shader and skip if unavailable
        PShader shader = ShaderReloader.getShader(shaderPath());
        if (shader != null) {
            float time = 0f;
            if (dst != null && dst.parent != null) {
                time = dst.parent.millis() / 1000.0f;
            }

            shader.set("u_baseColor", bg[0], bg[1], bg[2]);
            shader.set("u_resolution", (float) dst.width, (float) dst.height);
            shader.set("u_time", time);

            shader.set("inputTexture", srcTex);
            shader.set("inputResolution", (float) srcTex.width, (float) srcTex.height);

            boolean invert = gui.toggle("invertMask", false);
            shader.set("invertMask", invert);

            // IMPORTANT: render into dst (output), not in-place filter
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
        return "effects/static";
    }

    @Override
    public String shaderPath() {
        return SHADER_PATH;
    }
}
