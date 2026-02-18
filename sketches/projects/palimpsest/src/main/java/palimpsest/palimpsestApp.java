package palimpsest;

import com.krab.lazy.LazyGui;
import effects.*;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;

import javax.swing.JFileChooser;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;

import static parameters.Parameters.SEED;

/**
 * palimpsestApp
 *
 * Non-destructive preview + stackable effects via ping-pong buffers.
 *
 * IMPORTANT CONTRACT (single Effect type, no extra interfaces):
 * - For stacking, each Effect must follow this convention:
 *     - The app calls: fx.setCanvas(src) where src is the current stack state.
 *     - The app then calls: fx.apply(dst, gui) where dst is the output buffer for this stage.
 *     - Inside apply(dst, gui), the effect should READ from liveCanvas (src) and WRITE into dst.
 * - Effects should be safe when disabled (beginGui returns false → no-op).
 *
 * This avoids in-place shader sampling hazards (reading/writing same surface).
 */
public class palimpsestApp extends PApplet {

    public static void main(String[] args) {
        PApplet.main(palimpsestApp.class);
    }

    // UI + IO
    private LazyGui gui;

    // Baked base image (committed state)
    private PImage base;

    // Ping-pong preview buffers
    private PGraphics pingA;
    private PGraphics pingB;

    // Points to the final preview buffer for this frame (either pingA or pingB)
    private PGraphics edited;

    // Effects stack (order matters)
    private final ArrayList<Effect> effects = new ArrayList<>();

    // Background color (packed ARGB int)
    private int bg;

    @Override
    public void settings() {
        size(1500, 1500, P2D);

        // Deterministic seeds per run given SEED
        randomSeed(SEED);
        noiseSeed((int) random(Integer.MAX_VALUE));
    }

    @Override
    public void setup() {
        colorMode(HSB, 360, 100, 100);
        bg = color(0, 0, 100) | 0xFF000000;

        gui = new LazyGui(this);

        // Register effects (order matters)
        effects.add(new InvertEffect());
        effects.add(new fbmEffect());
        effects.add(new ComplexEffect());
        effects.add(new staticEffect());
        effects.add(new InvertEffect());
        effects.add(new fourierEffect());

        initCanvas();
    }

    @Override
    public void draw() {
        // UI-driven background (force opaque)
        bg = gui.colorPicker("canvas/background_color").hex | 0xFF000000;

        if (base == null) initCanvas();

        // One-shots / commands
        if (gui.button("io/save image")) {
            exportImage();
            return;
        }
        if (gui.button("io/load image")) {
            selectImage();
            return;
        }

        boolean regen = gui.button("canvas/regenerate canvas") || gui.button("canvas/regenerate");
        if (regen) {
            initCanvas();
            // fall through to preview
        }

        if (gui.button("apply/bake")) {
            bake();
            // fall through to preview post-bake
        }

        // --- NON-DESTRUCTIVE + STACKED PREVIEW ---
        rebuildPreviewStacked();

        background(bg);
        previewToScreen();
    }

    /* ============================== Canvas ============================== */

    private void initCanvas() {
        int w = width;
        int h = height;

        base = createImage(w, h, ARGB);
        base.loadPixels();
        Arrays.fill(base.pixels, bg);
        base.updatePixels();

        ensurePingPongBuffers(base.width, base.height);

        // Seed a reasonable default
        edited = pingA;
    }

    private void ensurePingPongBuffers(int w, int h) {
        if (pingA == null || pingA.width != w || pingA.height != h) {
            pingA = createGraphics(w, h, P2D);
            pingB = createGraphics(w, h, P2D);
        }
    }

    /**
     * Seed dst with the current base (clearing with bg first).
     */
    private void seedFromBase(PGraphics dst) {
        dst.beginDraw();
        dst.colorMode(HSB, 360, 100, 100);
        dst.background(bg);
        dst.imageMode(CORNER);
        dst.image(base, 0, 0);
        dst.endDraw();
    }

    /**
     * Copy src to dst 1:1.
     * Used so "disabled effects" preserve the pipeline output.
     */
    private void blit(PGraphics src, PGraphics dst) {
        dst.beginDraw();
        dst.colorMode(HSB, 360, 100, 100);
        dst.background(bg);
        dst.imageMode(CORNER);
        dst.image(src, 0, 0);
        dst.endDraw();
    }

    /**
     * Full stacked preview using ping-pong buffers.
     *
     * Stage rule:
     * - src is current stack state
     * - dst is the output buffer for this effect stage
     * - we pre-blit src->dst so "disabled" effects naturally keep the image
     * - effect reads from fx.liveCanvas (=src) and writes to dst passed into apply()
     */
    private void rebuildPreviewStacked() {
        ensurePingPongBuffers(base.width, base.height);

        // Start chain: base -> pingA
        seedFromBase(pingA);

        PGraphics src = pingA;
        PGraphics dst = pingB;

        for (Effect fx : effects) {
            // Context propagation
            fx.setBackgroundColor(bg);
            fx.setCanvas(src);

            // Preserve src if effect is disabled (or is a partial overlay)
            blit(src, dst);

            // Effect writes into dst (reading from its liveCanvas/src)
            fx.apply(dst, gui);

            // Next stage
            PGraphics tmp = src;
            src = dst;
            dst = tmp;
        }

        edited = src;
    }

    /* ============================== Bake / Export ============================== */

    private void bake() {
        // Render stacked preview for current toggles
        rebuildPreviewStacked();

        // Commit preview -> base
        base = edited.get();

        // Reset all effect toggles OFF + clear effect state (snapshots, etc.)
        resetAllEffectToggles();

        // Rebuild preview from baked base with all effects off
        rebuildPreviewStacked();
    }

    private void resetAllEffectToggles() {
        for (Effect fx : effects) {
            gui.toggleSet(fx.label() + "/enabled", false);
            fx.onDisable(); // clear snapshots, state, etc.
        }
    }

    private void exportImage() {
        // Deterministic export: render current stacked preview first
        rebuildPreviewStacked();

        File outDir = new File("out");
        if (!outDir.exists()) outDir.mkdirs();

        String filename = "out/duckforge_" + timestamp() + ".png";
        edited.save(filename);
        println("Saved image to: " + filename);
    }

    /* ============================== Preview ============================== */

    private void previewToScreen() {
        int previewMargin = 50;

        float previewScale = min(
                (float) (width - 2 * previewMargin) / edited.width,
                (float) (height - 2 * previewMargin) / edited.height
        );

        pushMatrix();
        translate(width / 2f, height / 2f);
        scale(previewScale);
        imageMode(CENTER);
        image(edited, 0, 0);
        popMatrix();
    }

    /* ============================== Load Image ============================== */

    private void selectImage() {
        JFileChooser chooser = new JFileChooser();
        chooser.setDialogTitle("Select an image");
        int result = chooser.showOpenDialog(null);

        if (result != JFileChooser.APPROVE_OPTION) return;

        File f = chooser.getSelectedFile();
        PImage loaded = loadImage(f.getAbsolutePath());

        if (loaded == null) {
            println("Failed to load image: " + f.getAbsolutePath());
            return;
        }

        base = loaded;
        ensurePingPongBuffers(base.width, base.height);

        float windowAspect = (float) width / height;
        float imgAspect = (float) base.width / base.height;
        float fitScale = (imgAspect > windowAspect)
                ? (float) width / base.width
                : (float) height / base.height;

        gui.sliderSet("image/scale", fitScale);
    }

    /* ============================== Utility ============================== */

    private String timestamp() {
        return year() + nf(month(), 2) + nf(day(), 2) + "_"
                + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    }
}
