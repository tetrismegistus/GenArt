package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.opengl.PShader;

public class fourierEffect extends BaseEffect {

    private static final String SHADER_PATH = "shaders/fourier_inspired.glsl";

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

        float time = canvas.parent.millis() / 1000.0f;

        // ─────────────────────────────────────
        // Fourier controls (signal, not noise)
        // ─────────────────────────────────────

        float scale      = gui.slider("scale", 5.0f);
        float speed      = gui.slider("time speed", 0.5f);
        float phaseWarp  = gui.slider("phase warp", 0.8f);

        float band1Amp   = gui.slider("band1 amp", 0.45f);
        float band2Amp   = gui.slider("band2 amp", 0.30f);
        float band3Amp   = gui.slider("band3 amp", 0.18f);
        float band4Amp   = gui.slider("band4 amp", 0.07f);

        float brightMinR = gui.slider("min R", 0.2f);
        float brightMinG = gui.slider("min G", 0.2f);
        float brightMinB = gui.slider("min B", 0.2f);

        float[] bg = getBackgroundColorComponents(canvas);

        PShader shader = ShaderReloader.getShader(shaderPath());
        if (shader != null) {
            shader.set("u_baseColor", bg[0], bg[1], bg[2]);
            shader.set("u_resolution", (float) canvas.width, (float) canvas.height);
            shader.set("u_time", time);

            // Fourier uniforms
            shader.set("u_scale", scale);
            shader.set("u_time_speed", speed);
            shader.set("u_phase_warp", phaseWarp);

            shader.set("u_band1_amp", band1Amp);
            shader.set("u_band2_amp", band2Amp);
            shader.set("u_band3_amp", band3Amp);
            shader.set("u_band4_amp", band4Amp);

            shader.set("inputTexture", frozenInput);
            shader.set("u_fbm_bright_min", brightMinR, brightMinG, brightMinB);

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
        return "effects/fourier";
    }

    @Override
    public String shaderPath() {
        return SHADER_PATH;
    }
}
