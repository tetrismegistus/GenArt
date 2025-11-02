package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.opengl.PShader;

public class fbmEffect extends BaseEffect {
    private static final String SHADER_PATH = "shaders/foreground_noise.glsl";

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

        // GUI parameters
        float scale = gui.slider("scale", 5f);
        float gain = gui.slider("gain", 0.45f);
        float lacunarity = gui.slider("lacunarity", 1.7f);
        int octaves = gui.sliderInt("octaves", 4);
        float warpScale = gui.slider("warp scale", 100f, 0.1f, 2000);
        float warpFreqX = gui.slider("freq X", 0.01f);
        float warpFreqY = gui.slider("freq Y", 0.01f);
        float warpFreqDX = gui.slider("freq DX", 0.001f);
        float warpFreqDY = gui.slider("freq DY", 0.001f);
        int warpIterations = gui.sliderInt("warp iterations", 4);
        float brightMinR = gui.slider("min R", 0.2f);
        float brightMinG = gui.slider("min G", 0.2f);
        float brightMinB = gui.slider("min B", 0.2f);

        float[] bg = getBackgroundColorComponents(canvas);

        PShader shader = ShaderReloader.getShader(shaderPath());
        if (shader != null) {
            shader.set("u_baseColor", bg[0], bg[1], bg[2]);
            shader.set("u_resolution", (float) canvas.width, (float) canvas.height);
            shader.set("u_time", time);

            shader.set("u_fbm_scale", scale);
            shader.set("u_fbm_gain", gain);
            shader.set("u_fbm_lacunarity", lacunarity);
            shader.set("u_fbm_octaves", (float) octaves);

            shader.set("u_warp_scale", warpScale);
            shader.set("u_warp_freq_x", warpFreqX);
            shader.set("u_warp_freq_y", warpFreqY);
            shader.set("u_warp_freq_dx", warpFreqDX);
            shader.set("u_warp_freq_dy", warpFreqDY);
            shader.set("u_warp_iterations", warpIterations);

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
        return "effects/fbm";
    }

    @Override
    public String shaderPath() {
        return SHADER_PATH;
    }
}