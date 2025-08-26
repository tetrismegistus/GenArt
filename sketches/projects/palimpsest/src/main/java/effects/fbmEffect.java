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
        shader.set("u_warp_offset_x", 0);
        shader.set("u_warp_offset_y", 0);
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
