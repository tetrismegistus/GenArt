package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.opengl.PShader;

public class ComplexEffect extends BaseEffect {
    private static final String SHADER_PATH = "shaders/z0.glsl";

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

        float[] bg = getBackgroundColorComponents(canvas);

        PShader shader = ShaderReloader.getShader(shaderPath());
        if (shader != null) {
            shader.set("resolution", (float) canvas.width, (float) canvas.height);
            shader.set("inputTexture", frozenInput);
            shader.set("inputResolution", (float) frozenInput.width, (float) frozenInput.height);

            shader.set("range", range);
            shader.set("aReal", aReal); shader.set("aImag", aImag);
            shader.set("bReal", bReal); shader.set("bImag", bImag);
            shader.set("cReal", cReal); shader.set("cImag", cImag);
            shader.set("dReal", dReal); shader.set("dImag", dImag);

            shader.set("bgColor", bg[0], bg[1], bg[2], 1.0f);

            canvas.beginDraw();
            ShaderReloader.filter(shaderPath(), canvas);
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
        return "effects/complex";
    }

    @Override
    public String shaderPath() {
        return SHADER_PATH;
    }
}
