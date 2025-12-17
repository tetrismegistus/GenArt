package palimpsest;

import java.io.File;
import javax.swing.JFileChooser;
import java.util.ArrayList;
import java.util.Arrays;

import effects.*;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;

import static parameters.Parameters.SEED;

import com.krab.lazy.LazyGui;

public class palimpsestApp extends PApplet {
    public static void main(String[] args) {
        PApplet.main(palimpsestApp.class);
    }

    // UI + IO
    LazyGui gui;

    // Base input (for baking) + main output buffer
    PImage img;
    PGraphics edited;

    // Effects stack
    ArrayList<Effect> effects = new ArrayList<>();
    // Background color
    int bg;

    @Override
    public void settings() {
        size(1500, 1500, P2D);  // 8x11 @ 200DPI
        randomSeed(SEED);
        noiseSeed(floor(random(MAX_INT)));
    }

    @Override
    public void setup() {
        colorMode(HSB, 360, 100, 100);
        bg = color(0, 0, 100);
        gui = new LazyGui(this);

        effects.add(new InvertEffect());
        effects.add(new fbmEffect());
        effects.add(new ComplexEffect());
        effects.add(new staticEffect());
        effects.add(new InvertEffect());
        effects.add(new fourierEffect());
    }

    /* ============================== Draw ============================== */

    @Override
    public void draw() {

        bg = gui.colorPicker("canvas/background_color").hex;

        background(bg);
        if (img == null || edited == null) initCanvas();

        // --- One-shots ---
        if (gui.button("save image")) { exportImage(); return; }
        if (gui.button("canvas/regenerate canvas")) { initCanvas(); }


        if (gui.button("load image")) {
            selectImage();
        }
        applyEffects();
        previewToScreen();
    }

    private void initCanvas() {
        // Create blank base image matching window
        int canvasW = width, canvasH = height;
        img = createImage(canvasW, canvasH, HSB);
        img.loadPixels();
        Arrays.fill(img.pixels, bg);
        img.updatePixels();
        resetCanvas(img, true);
    }

    private void resetCanvas(PImage baseImage, boolean clearToBg) {
        int w = (baseImage != null) ? baseImage.width : width;
        int h = (baseImage != null) ? baseImage.height : height;

        edited = createGraphics(w, h, P2D);
        edited.beginDraw();
        if (clearToBg) edited.background(bg);
        if (baseImage != null) edited.image(baseImage, 0, 0);
        edited.endDraw();
        setFxCanvi();
    }

    private void setFxCanvi() {
        for (Effect fx : effects) {
            fx.setCanvas(edited);
        }
    }

    private void exportImage() {
        File outDir = new File("out");
        if (!outDir.exists()) outDir.mkdirs();

        String filename = "out/duckforge_" + timestamp() + ".png";
        edited.save(filename);
        println("Saved image to: " + filename);
    }


    private void applyEffects() {
        for (Effect fx : effects) fx.apply(edited, gui);
    }

    private void previewToScreen() {
        imageMode(CENTER);
        int previewMargin = 50;
        float previewScale = min(
                (float)(width  - 2 * previewMargin) / edited.width,
                (float)(height - 2 * previewMargin) / edited.height
        );

        pushMatrix();
        translate(width / 2f, height / 2f);
        scale(previewScale);
        imageMode(CENTER);
        image(edited, 0, 0);
        popMatrix();
    }

    private void selectImage() {
        JFileChooser chooser = new JFileChooser();
        chooser.setDialogTitle("Select an image");
        int result = chooser.showOpenDialog(null);
        if (result == JFileChooser.APPROVE_OPTION) {
            File f = chooser.getSelectedFile();
            PImage loaded = loadImage(f.getAbsolutePath());
            if (loaded != null) {
                img = loaded;
                resetCanvas(img, true);

                float windowAspect = (float) width / height;
                float imgAspect = (float) img.width / img.height;
                float fitScale = (imgAspect > windowAspect)
                        ? (float) width / img.width
                        : (float) height / img.height;

                gui.sliderSet("image/scale", fitScale);
            } else {
                println("Failed to load image: " + f.getAbsolutePath());
            }
        }
    }

    private String timestamp() {
        return year() + nf(month(), 2) + nf(day(), 2) + "_"
                + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    }
}
