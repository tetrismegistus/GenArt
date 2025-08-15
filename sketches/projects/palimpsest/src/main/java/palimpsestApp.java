package palimpsest;

import java.io.File;
import javax.swing.JFileChooser;
import java.util.ArrayList;
import java.util.Arrays;

import processing.core.PApplet;
import processing.core.PImage;
import processing.core.PGraphics;

import static parameters.Parameters.SEED;

import com.krab.lazy.LazyGui;

import effects.InvertEffect;
import effects.fbmEffect;
import effects.Effect;

import utils.LineUtils;
import utils.LineStyle;
import utils.MetatronUtil;
import utils.Board;
import utils.ColorPalette;
import utils.AsemicUtil;

import processing.core.PVector;
import java.util.HashMap;

public class palimpsestApp extends PApplet {
    public static void main(String[] args) { PApplet.main(palimpsestApp.class); }

    LazyGui gui;
    PImage img;
    PGraphics edited;
    ArrayList<Effect> effects = new ArrayList<>();

    fbmEffect fbm;
    LineUtils lines;
    MetatronUtil metatron;
    LineStyle asemicStyle;

    // styles
    LineStyle graphStyleV, graphStyleH;
    LineStyle metatronStyle;

    int bg;

    // --- Asemic test fields ---
    Board page = null;
    HashMap<Character, ArrayList<PVector>> asciiMap = new HashMap<>();
    ArrayList<String> asemicWords = new ArrayList<>();
    String newlineMarker = "<NEWLINE>";

    int cols = 182;
    int rows = 98;
    float tileSize = 10f;
    float gutterWidth = 80f;
    int gutterStartCol = 0, gutterEndCol = 0;

    final ColorPalette PAL_A = new ColorPalette(new int[] {0xD64045, 0x1D3354});
    final ColorPalette PAL_B = new ColorPalette(new int[] {0x9ED8DB, 0x467599});

    @Override
    public void settings() {
        size(1600, 2200, P2D);  // 8x11 @ 200DPI
        randomSeed(SEED);
        noiseSeed(floor(random(MAX_INT)));
    }

    @Override
    public void setup() {
        colorMode(HSB, 360, 100, 100);
        bg = color(0, 0, 100);
        gui = new LazyGui(this);

        effects.add(new InvertEffect());
        fbm = new fbmEffect();
        effects.add(fbm);

        lines = new LineUtils(this);
        metatron = new MetatronUtil(this, lines);
        asemicStyle = new LineStyle(color(228, 88, 75));
        asemicStyle.fixedWeight = 1.0f;

        // default styles
        int gpColor = color(228, 88, 75);
        graphStyleV = new LineStyle(gpColor);
        graphStyleH = new LineStyle(gpColor);
        metatronStyle = new LineStyle(color(228, 88, 75));
        metatronStyle.fixedWeight = 1.0f; // for simple lines when draftsman disabled

        img = null;
        edited = null;

        // --- Asemic assets: build glyph map + load words ---
        AsemicUtil.generateAsciiMap(asciiMap, this);

        String[] lines = loadStrings("data/input.txt");
        if (lines != null) {
            for (String line : lines) {
                String[] ws = splitTokens(line, " ,.!?");
                asemicWords.addAll(Arrays.asList(ws));
                asemicWords.add(newlineMarker);
            }
        }

    }

    @Override
    public void draw() {
        // Background color + fbm base color
        bg = gui.colorPicker("init/background_color").hex;
        fbm.setBackgroundColor(bg);
        background(color(0, 0, 100));

        // init canvas
        if (img == null) initCanvas();

        // one-shots
        if (gui.button("save/export image")) { exportImage(); return; }
        if (gui.button("init/regenerate canvas")) { img = null; return; }

        // main pass
        if (img != null) {
            drawEditedBuffer();
            applyEffects();
            editGraphPaperStyleFromGUI();
            editMetatronStyleFromGUI();
            handleGraphPaperTool();
            handleMetatronTool();


            previewToScreen();

            // controls for bigger chars + spacing (independent of board.tileSize)
            gui.pushFolder("tools/asemic/params");
            float charTileSize = gui.slider("char tile size", max(8f, tileSize), 6f, 64f);
            float charGap      = gui.slider("char gap (tiles)", 1.0f, 0f, 4f);
            gui.popFolder();

            // metashape controls (always visible)
            gui.pushFolder("tools/asemic/metashape");
            int   mBlock = gui.sliderInt("block width", 250, 50, 800);
            int   mSides = gui.sliderInt("sides", 6, 3, 24);
            int   mCx    = gui.sliderInt("center x (px)", 300, 0, width);
            int   mCy    = gui.sliderInt("center y (px)", 300, 0, height);
            gui.popFolder();
            // --- Asemic test: build meta + fill words, bake to edited ---
            if (gui.button("tools/asemic/build+render (one shot)")) {
                // fresh board at (50,50)
                page = new Board(50, 50, rows, cols, charTileSize, PAL_A, PAL_B, 10, 10, this);

                // style / pen
                editAsemicStyleFromGUI();
                handleAsemicTool(page); // passes (lines, asemicStyle, toggle)


                // ---- insert ONE MetaShape first (so words avoid that area) ----

                // bake metashape graphic into a TileCircle on the board
                AsemicUtil.addMetaShape(this, page, mBlock, mCx, mCy, mSides);

                // ---- fill the board with as many words as fit (left->right, row by row) ----
                int wordIndex = 0;
                int startRow = 0;

                for (int row = startRow; row < rows; row++) {
                    int startCol = 0;
                    int endCol   = cols;

                    for (int col = startCol; col < endCol; ) {
                        if (wordIndex >= asemicWords.size()) break;

                        String currentWord = asemicWords.get(wordIndex);

                        // newline marker → jump to next row
                        if (currentWord.equals(newlineMarker)) {
                            row++;
                            col = startCol;
                            wordIndex++;
                            continue;
                        }

                        // place using the adjustable charTileSize + gap
                        boolean wasPlaced = AsemicUtil.placeAndDrawWord(currentWord, col, row, charTileSize, charGap, page);

                        if (wasPlaced) {
                            // advance by the actual tile-length at this charTileSize+gap so we don't overlap
                            int advance = page.calculateWordTileLength(currentWord, charTileSize, charGap);
                            col += Math.max(1, advance);
                            wordIndex++;
                        } else {
                            col++; // try next column
                        }
                    }
                    if (wordIndex >= asemicWords.size()) break;
                }

                // ---- bake onto edited (persistent) ----
                edited.beginDraw();
                page.renderTo(edited, this, 0, asciiMap);
                edited.endDraw();

                // skip preview redraw this frame
                return;
            }





        }
    }

    /* ----------------- helpers ----------------- */
    private void initCanvas() {
        int canvasW = width, canvasH = height;
        img = createImage(canvasW, canvasH, HSB);
        img.loadPixels(); Arrays.fill(img.pixels, bg); img.updatePixels();
        edited = createGraphics(canvasW, canvasH, P2D);
        gui.sliderSet("image/scale", 1.0f);
    }

    private void exportImage() {
        String filename = "out/duckforge_" + timestamp() + ".png";
        edited.save(filename);
        println("Saved image to: " + filename);
    }

    private void drawEditedBuffer() {
        float scale = gui.slider("image/scale", 1.0f, 0.1f, 5.0f);
        float x = gui.slider("image/x", 0, -img.width, img.width);
        float y = gui.slider("image/y", 0, -img.height, img.height);

        edited.beginDraw();
        edited.imageMode(CENTER);
        edited.pushMatrix();
        edited.translate(edited.width / 2f + x, edited.height / 2f + y);
        edited.scale(scale);
        edited.image(img, 0, 0);
        edited.popMatrix();
    }

    private void editAsemicStyleFromGUI() {
        gui.pushFolder("tools/asemic/style");
        // standard LineStyle knobs
        int sc = gui.colorPicker("stroke color", asemicStyle.strokeColor).hex;
        float a  = gui.slider("alpha",       asemicStyle.baseAlpha, 0, 1);
        float hs = gui.slider("hueScale",    asemicStyle.hueScale, 0.0001f, 0.1f);
        float ss = gui.slider("satScale",    asemicStyle.satScale, 0.0001f, 1.0f);
        float bs = gui.slider("brtScale",    asemicStyle.brtScale, 0.0001f, 1.0f);
        float ws = gui.slider("weightScale", asemicStyle.weightScale, 0.0001f, 1.0f);
        float bns= gui.slider("baseNoiseSigma", asemicStyle.baseNoiseSigma, 0, 50);
        float jit= gui.slider("jitterSigma",    asemicStyle.jitterSigma, 0, 2);
        int   rep= gui.sliderInt("repeats",     asemicStyle.repeats, 1, 12);
        float sm = gui.slider("stepMultiplier", asemicStyle.stepMultiplier, 0.1f, 4.0f);
        int   sMx= gui.sliderInt("stepsMax (0=none)", asemicStyle.stepsMax, 0, 10000);
        float fw = gui.slider("fixedWeight (non-draftsman)", asemicStyle.fixedWeight, 0.5f, 5f);
        gui.popFolder();

        asemicStyle.strokeColor   = sc;
        asemicStyle.baseAlpha     = a;
        asemicStyle.hueScale      = hs;
        asemicStyle.satScale      = ss;
        asemicStyle.brtScale      = bs;
        asemicStyle.weightScale   = ws;
        asemicStyle.baseNoiseSigma= bns;
        asemicStyle.jitterSigma   = jit;
        asemicStyle.repeats       = rep;
        asemicStyle.stepMultiplier= sm;
        asemicStyle.stepsMax      = sMx;
        asemicStyle.fixedWeight   = fw;
    }

    private void handleAsemicTool(Board page) {
        gui.pushFolder("tools/asemic");
        boolean useDraftsman = gui.toggle("use draftsman for words", true);
        gui.popFolder();

        // tell the board what pen to give each TileRect
        page.setAsemicPen(lines, asemicStyle, useDraftsman);
    }


    private void applyEffects() {
        for (Effect fx : effects) fx.apply(edited, gui);
    }

    /* --------- GUI -> Style (Graph Paper) ---------- */
    private void editGraphPaperStyleFromGUI() {
        gui.pushFolder("tools/graphpaper/style");
        int col = gui.colorPicker("stroke color", graphStyleV.strokeColor).hex;

        float alpha      = gui.slider("alpha", graphStyleV.baseAlpha, 0, 1);
        float hueScale   = gui.slider("hueScale", graphStyleV.hueScale, 0.0001f, 0.1f);
        float satScale   = gui.slider("satScale", graphStyleV.satScale, 0.0001f, 1.0f);
        float brtScale   = gui.slider("brtScale", graphStyleV.brtScale, 0.0001f, 1.0f);
        float weightFreq = gui.slider("weightScale", graphStyleV.weightScale, 0.0001f, 1.0f);
        float baseSigma  = gui.slider("baseNoiseSigma", graphStyleV.baseNoiseSigma, 0, 50);
        float jitter     = gui.slider("jitterSigma", graphStyleV.jitterSigma, 0, 2);
        int   repeats    = gui.sliderInt("repeats", graphStyleV.repeats, 1, 12);
        float stepMul    = gui.slider("stepMultiplier", graphStyleV.stepMultiplier, 0.1f, 4.0f);
        int   stepsMax   = gui.sliderInt("stepsMax (0=none)", graphStyleV.stepsMax, 0, 10000);
        gui.popFolder();

        // apply to both V and H (you can split into two folders if you prefer different styles)
        for (LineStyle s : new LineStyle[]{graphStyleV, graphStyleH}) {
            s.strokeColor = col;
            s.baseAlpha = alpha;
            s.hueScale = hueScale;
            s.satScale = satScale;
            s.brtScale = brtScale;
            s.weightScale = weightFreq;
            s.baseNoiseSigma = baseSigma;
            s.jitterSigma = jitter;
            s.repeats = repeats;
            s.stepMultiplier = stepMul;
            s.stepsMax = stepsMax;
        }
    }

    /* --------- GUI -> Style (Metatron) ---------- */
    private void editMetatronStyleFromGUI() {
        gui.pushFolder("tools/metatron/style");
        metatronStyle.strokeColor   = gui.colorPicker("stroke color", metatronStyle.strokeColor).hex;
        metatronStyle.baseAlpha     = gui.slider("alpha", metatronStyle.baseAlpha, 0, 1);
        metatronStyle.hueScale      = gui.slider("hueScale", metatronStyle.hueScale, 0.0001f, 0.1f);
        metatronStyle.satScale      = gui.slider("satScale", metatronStyle.satScale, 0.0001f, 1.0f);
        metatronStyle.brtScale      = gui.slider("brtScale", metatronStyle.brtScale, 0.0001f, 1.0f);
        metatronStyle.weightScale   = gui.slider("weightScale", metatronStyle.weightScale, 0.0001f, 1.0f);
        metatronStyle.baseNoiseSigma= gui.slider("baseNoiseSigma", metatronStyle.baseNoiseSigma, 0, 50);
        metatronStyle.jitterSigma   = gui.slider("jitterSigma", metatronStyle.jitterSigma, 0, 2);
        metatronStyle.repeats       = gui.sliderInt("repeats", metatronStyle.repeats, 1, 12);
        metatronStyle.stepMultiplier= gui.slider("stepMultiplier", metatronStyle.stepMultiplier, 0.1f, 4.0f);
        metatronStyle.stepsMax      = gui.sliderInt("stepsMax (0=none)", metatronStyle.stepsMax, 0, 10000);
        metatronStyle.fixedWeight   = gui.slider("fixedWeight (non-draftsman)", metatronStyle.fixedWeight, 0.5f, 5f);
        gui.popFolder();
    }

    private void handleGraphPaperTool() {
        float gx = gui.slider("tools/graphpaper/x", 100, 0, width);
        float gy = gui.slider("tools/graphpaper/y", 100, 0, height);
        float gw = gui.slider("tools/graphpaper/width", 1000, 10, width);
        float gh = gui.slider("tools/graphpaper/height", 1000, 10, height);
        float spacing = gui.slider("tools/graphpaper/spacing", 10, 1, 200);

        if (gui.button("tools/draw graph paper")) {
            drawGraphPaperSketch(gx, gy, gw, gh, spacing);
        }
        edited.endDraw();
    }

    private void handleMetatronTool() {
        float mx     = gui.slider("tools/metatron/x",      400, 0, width);
        float my     = gui.slider("tools/metatron/y",      400, 0, height);
        float mh     = gui.slider("tools/metatron/height", 500, 50, height);
        int   msides = gui.sliderInt("tools/metatron/sides", 6, 3, 24);
        int   mref   = gui.colorPicker("tools/metatron/ring color", color(0, 0, 0)).hex;
        boolean draftsman = gui.toggle("tools/metatron/use draftsman", true);

        // Jitter controls (mirroring your graph paper vibe)
        gui.pushFolder("tools/metatron/jitter");
        float rotDeg   = gui.slider("angle (deg)", 1.0f, -5f, 5f);   // small rotation around center
        float jdx      = gui.slider("offset x", 0f, -20f, 20f);      // block offset X
        float jdy      = gui.slider("offset y", 0f, -20f, 20f);      // block offset Y
        float endpoint = gui.slider("endpoint σ (px)", 2.0f, 0f, 10f); // per-endpoint jitter
        float rSigma   = gui.slider("radius σ (px)", 1.0f, 0f, 10f);   // per-ring radius jitter
        gui.popFolder();

        if (gui.button("tools/draw metatron (bake)")) {
            metatron.metaShape(
                    edited,
                    mx, my, mh,
                    msides, mref,
                    draftsman, metatronStyle,
                    rotDeg, jdx, jdy,
                    endpoint, rSigma
            );
        }
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

    private void drawGraphPaperSketch(float x, float y, float w, float h, float spacing) {
        if (edited == null) return;

        edited.colorMode(HSB, 360, 100, 100, 1);

        float gaussScale  = 5f;
        float noiseScale  = 0.05f;
        float noiseXOff   = random(Float.MAX_VALUE);
        float noiseYOff   = random(Float.MAX_VALUE);

        edited.pushMatrix();
        edited.translate(x + w / 2f, y + h / 2f);

        float maxAngle = radians(1);
        float angle = map(noise(SEED), 0, 1, -maxAngle, maxAngle);
        edited.rotate(angle);

        float dx = map(noise(SEED + 1), 0, 1, -10, 10);
        float dy = map(noise(SEED + 2), 0, 1, -10, 10);
        edited.translate(dx, dy);

        edited.translate(-w / 2f, -h / 2f);

        // verticals
        for (float px = 0; px <= w; ) {
            float noiseVal = noise(px * noiseScale + noiseXOff);
            float step = spacing + spacing * (noiseVal - 0.5f);
            float xPos = x + px;
            lines.draftsmanLine(
                    edited,
                    xPos, y + randomGaussian() * gaussScale,
                    xPos, y + h - randomGaussian() * gaussScale,
                    graphStyleV
            );
            px += step;
        }

        // horizontals
        for (float py = 0; py <= h; ) {
            float noiseVal = noise(py * noiseScale + noiseYOff);
            float step = spacing + spacing * 2 * (noiseVal - 0.5f);
            float yPos = y + py;
            lines.draftsmanLine(
                    edited,
                    x + randomGaussian() * gaussScale, yPos,
                    x + w - randomGaussian() * gaussScale, yPos,
                    graphStyleH
            );
            py += step;
        }

        edited.popMatrix();
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
                edited = createGraphics(img.width, img.height, P2D);
                float windowAspect = (float) width / height;
                float imgAspect = (float) img.width / img.height;
                float fitScale = (imgAspect > windowAspect) ? (float) width / img.width
                        : (float) height / img.height;
                gui.sliderSet("image/scale", fitScale);
            }
        }
    }

    private String timestamp() {
        return year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    }
}
