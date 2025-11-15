package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.opengl.PShader;

public class InvertEffect extends BaseEffect {
    private static final String SHADER_PATH = "shaders/invert.glsl";

    @Override
    public void apply(PGraphics canvas, LazyGui gui) {
        if (!beginGui(gui)) {
            endGui(gui);
            return;
        }

        if (frozenInput == null && liveCanvas != null) {
            captureSnapshotFromLiveCanvas();
        }

        if (frozenInput == null) {
            endGui(gui);
            return;
        }

        PShader shader = ShaderReloader.getShader(shaderPath());
        if (shader != null) {
            shader.set("resolution", (float) canvas.width, (float) canvas.height);
            shader.set("inputTexture", frozenInput);


            canvas.beginDraw();
            ShaderReloader.shader(shaderPath(), canvas);
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
        return "effects/invert";
    }

    @Override
    public String shaderPath() {
        return SHADER_PATH;
    }
}
