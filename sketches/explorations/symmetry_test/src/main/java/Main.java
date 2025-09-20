import com.krab.lazy.LazyGui;
import com.krab.lazy.ShaderReloader;

import processing.core.PApplet;
import processing.core.PImage;
import processing.core.PGraphics;
import processing.opengl.PShader;

import javax.swing.JFileChooser;
import java.io.File;

public class Main extends PApplet {

    // UI
    LazyGui gui;

    // Image & output buffer
    PImage texture;   // original loaded image
    PGraphics outPG;  // scaled, shader-processed buffer (fits inside MaxW/MaxH)

    // Shader
    String shaderPath = "shader.glsl";

    // Params
    float range = 30.0f;
    float aReal = 2.0f, aImag = -0.2f;
    float bReal = 0.0f, bImag = -0.7f;
    float cReal = 2.0f, cImag = -0.2f;
    float dReal = 0.0f, dImag = -0.7f;

    // Preview window sizing
    final int DEFAULT_W = 1700, DEFAULT_H = 1100;
    final int THRESH_W  = 2000, THRESH_H  = 1500;
    int lastSurfaceW = -1, lastSurfaceH = -1;

    public static void main(String[] args) {
        PApplet.main(java.lang.invoke.MethodHandles.lookup().lookupClass());
    }

    @Override
    public void settings() {
        size(DEFAULT_W, DEFAULT_H, P2D); // window is just a preview surface
    }

    @Override
    public void setup() {
        gui = new LazyGui(this);
        colorMode(HSB, 360, 100, 100, 1);
        background(0);
    }

    @Override
    public void draw() {
        background(0);

        // --- File ops
        if (gui.button("file/load image")) {
            selectImage();
        }
        if (gui.button("file/save scaled output")) {
            saveScaledOutput();
        }

        // --- Output sizing controls (fit-box, not stretch)
        gui.pushFolder("output");
        int maxW = gui.sliderInt("max width", 1200, 200, 8000);
        int maxH = gui.sliderInt("max height", 1200, 200, 8000);
        boolean allowUpscale = gui.toggle("allow upscale", false);
        boolean autoResizePreview = gui.toggle("auto resize preview when > 2000x1500", true);
        gui.popFolder();

        // --- Shader params (unchanged)
        gui.pushFolder("params");
        range = gui.slider("range", 30.0f, 0.0f, 30.0f);
        aReal = gui.slider("aReal", 2.0f, -30, 30);
        aImag = gui.slider("aImag", -0.2f, -30, 30);
        bReal = gui.slider("bReal", 0.0f, -30, 30);
        bImag = gui.slider("bImag", -0.7f, -30, 30);
        cReal = gui.slider("cReal", 2.0f, -30, 30);
        cImag = gui.slider("cImag", -0.2f, -30, 30);
        dReal = gui.slider("dReal", 0.0f, -30, 30);
        dImag = gui.slider("dImag", -0.7f, -30, 30);
        gui.popFolder();

        if (texture == null) {
            fill(255);
            textAlign(CENTER, CENTER);
            text("No image loaded. Click 'file/load image'.", width/2f, height/2f);
            return;
        }

        // --- Compute fit scale (preserve aspect)
        float sW = (float) maxW / texture.width;
        float sH = (float) maxH / texture.height;
        float fitScale = min(sW, sH);
        if (!allowUpscale) fitScale = min(fitScale, 1.0f); // never enlarge beyond native

        int outW = max(1, round(texture.width * fitScale));
        int outH = max(1, round(texture.height * fitScale));

        // (Re)allocate output buffer if size changed
        ensureOutBuffer(outW, outH);

        // --- Render shader into outPG at fitted size
        outPG.beginDraw();
        outPG.background(0, 0); // or opaque if you prefer: outPG.background(0);

        PShader sh = ShaderReloader.getShader(shaderPath);
        sh.set("inputTexture", texture);
        sh.set("resolution", (float) outW, (float) outH);

        sh.set("range", range);
        sh.set("aReal", aReal); sh.set("aImag", aImag);
        sh.set("bReal", bReal); sh.set("bImag", bImag);
        sh.set("cReal", cReal); sh.set("cImag", cImag);
        sh.set("dReal", dReal); sh.set("dImag", dImag);

        outPG.noStroke();
        outPG.rectMode(CORNER);
        outPG.fill(255);
        outPG.rect(0, 0, outW, outH);
        outPG.filter(sh);
        outPG.endDraw();

        // --- Auto-resize preview window if the *fitted output* is larger than threshold
        if (autoResizePreview) updatePreviewWindow(outW, outH);

        // --- Center preview in current window (no stretch beyond preview scale)
        int margin = 50;
        float prevScale = min((float) (width - 2*margin) / outW,
                (float) (height - 2*margin) / outH);
        pushMatrix();
        translate(width/2f, height/2f);
        scale(prevScale);
        imageMode(CENTER);
        image(outPG, 0, 0);
        popMatrix();
    }

    // ---- helpers ----

    private void saveScaledOutput() {
        if (outPG == null) {
            println("Nothing to save yet.");
            return;
        }
        String fn = "frames/scaled_" + timestamp() + ".png";
        outPG.save(fn);
        println("Saved: " + fn);
    }

    private void updatePreviewWindow(int outW, int outH) {
        // If fitted output exceeds threshold, resize preview window proportionally to fit inside 2000x1500.
        // Otherwise use the default preview size.
        int targetW = DEFAULT_W;
        int targetH = DEFAULT_H;

        if (outW > THRESH_W || outH > THRESH_H) {
            float kW = (float) THRESH_W / outW;
            float kH = (float) THRESH_H / outH;
            float k  = min(kW, kH); // scale factor to fit inside threshold
            targetW = max(400, round(outW * k));
            targetH = max(300, round(outH * k));
        }

        if (targetW != lastSurfaceW || targetH != lastSurfaceH) {
            surface.setSize(targetW, targetH);
            lastSurfaceW = targetW;
            lastSurfaceH = targetH;
            // after resize, background will be cleared next frame anyway
        }
    }

    private void ensureOutBuffer(int w, int h) {
        if (outPG == null || outPG.width != w || outPG.height != h) {
            if (outPG != null) outPG.dispose();
            outPG = createGraphics(w, h, P2D);
        }
    }

    private void selectImage() {
        JFileChooser chooser = new JFileChooser();
        chooser.setDialogTitle("Select an image");
        int result = chooser.showOpenDialog(null);
        if (result == JFileChooser.APPROVE_OPTION) {
            File f = chooser.getSelectedFile();
            PImage loaded = loadImage(f.getAbsolutePath());
            if (loaded != null) {
                texture = loaded;
                println("Loaded: " + f.getAbsolutePath() + " (" + texture.width + "x" + texture.height + ")");
            } else {
                println("Failed to load image.");
            }
        }
    }

    private String timestamp() {
        return year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    }
}
