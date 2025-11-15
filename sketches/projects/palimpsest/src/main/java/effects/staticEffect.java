package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.opengl.PShader;

public class staticEffect extends BaseEffect {
    private final String shaderPath = "shaders/static.glsl";

    @Override
    public void apply(PGraphics canvas, LazyGui gui) {
        if (!beginGui(gui)) {
            endGui(gui);
            return;
        }

        // Ensure snapshot exists before running
        if (frozenInput == null && liveCanvas != null) {
            captureSnapshotFromLiveCanvas();
        }

        // Get background color as normalized floats
        float[] bg = getBackgroundColorComponents(canvas);

        // Load shader and skip if unavailable
        PShader shader = ShaderReloader.getShader(shaderPath);
        if (shader != null) {
            float time = canvas.parent.millis() / 1000.0f;
            shader.set("u_baseColor", bg[0], bg[1], bg[2]);
            shader.set("u_resolution", (float) canvas.width, (float) canvas.height);
            shader.set("u_time", time);
            shader.set("inputTexture", frozenInput);
            boolean invert = gui.toggle("invertMask", false);

            shader.set("invertMask", invert);

            canvas.beginDraw();
            ShaderReloader.filter(shaderPath, canvas);
            canvas.endDraw();
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
}
