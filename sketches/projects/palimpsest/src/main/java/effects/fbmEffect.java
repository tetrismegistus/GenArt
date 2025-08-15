package effects;

import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;
import processing.core.PGraphics;
import processing.opengl.PShader;

import static processing.core.PConstants.HSB;
import static processing.core.PConstants.RGB;


public class fbmEffect implements Effect {
    private final String shaderPath = "shaders/fbm_frag.glsl";
    private int bgColor;

    @Override
    public void apply(PGraphics canvas, LazyGui gui) {
        gui.pushFolder(label());

        boolean enabled = gui.toggle("enabled", false);
        if (!enabled) {
            gui.popFolder();
            return;
        }

        float time = canvas.parent.millis() / 1000.0f;

        // GUI-controlled noise parameters
        float scale = gui.slider("scale", 5f, 0.1f, 1000.0f);
        float gain = gui.slider("gain", 0.45f, 0.1f, 1.0f);
        float lacunarity = gui.slider("lacunarity", 1.7f, 1.0f, 3.0f);
        int octaves = gui.sliderInt("octaves", 4, 1, 16);
        float warpScale = gui.slider("warp scale", 100f, 0.1f, 500f);
        float warpFreqX = gui.slider("warp freq X", 0.01f, 0.0001f, 1f);
        float warpFreqY = gui.slider("warp freq Y", 0.01f, 0.0001f, 1f);
        float warpOffsetX = gui.slider("warp offset X", 1000f, 0f, 5000f);
        float warpOffsetY = gui.slider("warp offset Y", 1000f, 0f, 5000f);
        float warpFreqDX = gui.slider("warp freq DX", 0.001f, 0.01f, 0.9f);
        float warpFreqDY = gui.slider("warp freq DY", 0.001f, 0.01f, 0.9f);
        int warpIterations = gui.sliderInt("warp iterations", 4, 1, 10);

        // Per-channel brightness minimums
        float brightMinR = gui.slider("brightness min R", 0.2f, 0f, 1f);
        float brightMinG = gui.slider("brightness min G", 0.2f, 0f, 1f);
        float brightMinB = gui.slider("brightness min B", 0.2f, 0f, 1f);

        // RGB conversion of background color
        canvas.beginDraw();
        canvas.colorMode(RGB, 255, 255, 255, 100);
        float r = canvas.red(bgColor) / 255f;
        float g = canvas.green(bgColor) / 255f;
        float b = canvas.blue(bgColor) / 255f;
        canvas.endDraw();

        PShader shader = ShaderReloader.getShader(shaderPath);
        shader.set("u_baseColor", r, g, b);
        shader.set("u_resolution", (float) canvas.width, (float) canvas.height);
        shader.set("u_time", time);
        shader.set("u_fbm_scale", scale);
        shader.set("u_fbm_gain", gain);
        shader.set("u_fbm_lacunarity", lacunarity);
        shader.set("u_fbm_octaves", (float) octaves);

        shader.set("u_warp_scale", warpScale);
        shader.set("u_warp_freq_x", warpFreqX);
        shader.set("u_warp_freq_y", warpFreqY);
        shader.set("u_warp_offset_x", warpOffsetX);
        shader.set("u_warp_offset_y", warpOffsetY);
        shader.set("u_warp_freq_dx", warpFreqDX);
        shader.set("u_warp_freq_dy", warpFreqDY);
        shader.set("u_warp_iterations", warpIterations);

        // NEW: Per-channel brightness vector
        shader.set("u_fbm_bright_min", brightMinR, brightMinG, brightMinB);

        canvas.beginDraw();
        ShaderReloader.filter(shaderPath, canvas);
        canvas.endDraw();

        gui.popFolder();
    }

    public void setBackgroundColor(int bg) {
        this.bgColor = bg;
    }

    @Override
    public String label() {
        return "fbm";
    }
}
