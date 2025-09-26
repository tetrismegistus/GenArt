package palimpsest;

import java.io.File;
import javax.swing.JFileChooser;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.core.PVector;

import static parameters.Parameters.SEED;

import com.krab.lazy.LazyGui;

import effects.Effect;
import effects.InvertEffect;
import effects.fbmEffect;
import effects.ComplexEffect;

import noise.OpenSimplexNoise;
import utils.AsemicUtil;
import utils.Board;
import utils.ColorPalette;
import utils.ContourMap;
import utils.LineStyle;
import utils.LineUtils;
import utils.MetatronUtil;

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
    fbmEffect fbm;
    ComplexEffect complexEffect;

    // Lines & styles
    LineUtils lines;
    LineStyle graphStyleV, graphStyleH;
    LineStyle metatronStyle;
    LineStyle asemicStyle;
    MetatronUtil metatron;

    // Background color
    int bg;

    // Asemic
    Board page = null;
    HashMap<Character, ArrayList<PVector>> asciiMap = new HashMap<>();
    ArrayList<String> asemicWords = new ArrayList<>();
    String newlineMarker = "<NEWLINE>";
    int cols = 182, rows = 98;
    float tileSize = 10f;
    float gutterWidth = 80f;
    int gutterStartCol = 0, gutterEndCol = 0;
    final ColorPalette PAL_A = new ColorPalette(new int[]{0xD64045, 0x1D3354});
    final ColorPalette PAL_B = new ColorPalette(new int[]{0x9ED8DB, 0x467599});

    private boolean drawAllContours = true;
    private boolean drawAllGraphPaper = true;
    private boolean drawAllMetatron = true;
    private boolean drawAllAsemic = true;

    // Graph paper UI
    private boolean gpPreviewEnabled = true;
    private float gpX = 100, gpY = 100, gpW = 1000, gpH = 1000, gpSpacing = 10;
    private int gpPreviewColor;

    // Metatron UI
    private boolean mtPreviewEnabled = true;
    private PVector mtCenter = new PVector(400, 400);
    private float mtH = 500;
    private int   mtSides = 6;
    private int   mtRingColor = 0;
    private boolean mtDraftsman = true;
    private float mtRotDeg = 1.0f, mtDX = 0f, mtDY = 0f, mtEndpointJit = 2f, mtRadiusJit = 1f;
    private int mtPreviewColor;

    // Asemic preview
    private boolean asPreviewEnabled = true;
    private int asPreviewColor;
    private float asPreviewX = 50, asPreviewY = 50;  // top-left of text area
    private float asPreviewW = 1000, asPreviewH = 800; // text area dimensions

    // Contours UI
    private boolean ctPreviewEnabled = true;
    private PVector ctPos = new PVector(100, 100);
    private float ctW = 800, ctH = 800;
    private int ctPreviewColor;
    ContourMap contours;
    OpenSimplexNoise contourNoise;
    LineStyle contourStyle;

    /* ============================= Setup ============================= */

    @Override
    public void settings() {
        size(1527, 2000, P2D);  // 8x11 @ 200DPI
        randomSeed(SEED);
        noiseSeed(floor(random(MAX_INT)));
    }

    @Override
    public void setup() {
        colorMode(HSB, 360, 100, 100);
        bg = color(0, 0, 100);
        gui = new LazyGui(this);

        // Effects stack
        effects.add(new InvertEffect());
        fbm = new fbmEffect();
        effects.add(fbm);

        complexEffect = new ComplexEffect();   // snapshots edited on enable
        effects.add(complexEffect);

        // Utils & styles
        lines = new LineUtils(this);
        metatron = new MetatronUtil(this, lines);

        int defaultStroke = color(228, 88, 75);
        graphStyleV = new LineStyle(defaultStroke);
        graphStyleH = new LineStyle(defaultStroke);

        metatronStyle = new LineStyle(defaultStroke);
        metatronStyle.fixedWeight = 1.0f;

        asemicStyle = new LineStyle(defaultStroke);
        asemicStyle.fixedWeight = 1.0f;

        // Output buffer + blank base
        initCanvas();

        // Contours setup
        contourNoise = new OpenSimplexNoise((long) random(0, 2_000_000_000L));
        contourStyle = new LineStyle(color(228, 88, 10));
        contourStyle.fixedWeight = 1.2f;

        // Asemic assets
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

    /* ============================== Draw ============================== */

    @Override
    public void draw() {
        // UI background color (also used by fbm)
        bg = gui.colorPicker("init/background_color").hex;
        fbm.setBackgroundColor(bg);

        background(color(0, 0, 100));
        if (img == null || edited == null) initCanvas();

        // --- One-shots ---
        if (gui.button("export image")) { exportImage(); return; }
        if (gui.button("init/regenerate canvas")) { initCanvas(); }

        if (gui.button("layout/auto arrange tools")) {
            autoLayoutTools();
        }

        if (gui.button("layout/compact grid layout")) {
            autoLayoutToolsCompact();
        }

        if (gui.button("layout/text heavy")) {
            layoutTextHeavy();
        }

        if (gui.button("layout/geometric focus")) {
            layoutGeometricFocus();
        }


        // --- Image bake controls (base image -> edited) ---
        handleBaseImageBakeUI();

        // --- Styles for tools ---
        editGraphPaperStyleFromGUI();
        editMetatronStyleFromGUI();

        // --- Tools (bake-only when clicked) ---
        handleGraphPaperTool();
        handleMetatronTool();
        handleContourTool();

        handleDrawAllUI();

        // --- Asemic (bake when clicked) ---
        handleAsemicUIAndBake();

        // --- Post FX (ComplexEffect snapshots on enable inside itself) ---
        applyEffects();

        // --- Preview ---
        previewToScreen();
    }

    private void drawAllLayout() {
        println("Drawing complete layout...");

        // Clear canvas to background first
        edited.beginDraw();
        edited.background(bg);
        edited.endDraw();

        // Draw in optimal layering order (back to front):
        // 1. Contours (background texture)
        // 2. Graph paper (structural layer)
        // 3. Metatron (geometric focus)
        // 4. Asemic text (foreground content)

        if (drawAllContours) {
            drawContoursLayer();
        }

        if (drawAllGraphPaper) {
            drawGraphPaperLayer();
        }

        if (drawAllMetatron) {
            drawMetatronLayer();
        }

        if (drawAllAsemic) {
            drawAsemicLayer();
        }

        println("Layout drawing complete!");
    }

    private void drawContoursLayer() {
        println("  Drawing contours...");

        // Get current contour settings from GUI
        gui.pushFolder("tools/contours");
        boolean fbmEnabled = gui.toggle("fbm enabled", false);
        int oct = 4;
        float lac = gui.slider("lacunarity", 2.0f, 1.0f, 4.0f);
        float gain = 2.3f;
        float off = gui.slider("field scale (off)", 0.01f, 0.001f, 0.05f);
        float step = gui.slider("step length", 2.0f, 0.5f, 5.0f);
        gui.popFolder();

        // Draw contours using current settings
        ContourMap cm = new ContourMap(
                this,
                contourNoise,
                oct, lac, gain,
                false,
                off, step,
                lines
        );

        cm.buildMapLayer(edited, contourStyle, ctPos.x, ctPos.y, ctW, ctH);
        edited.endDraw();
    }

    private void drawGraphPaperLayer() {
        println("  Drawing graph paper...");

        // Get current graph paper spacing
        float spacing = gui.slider("tools/graphpaper/spacing", gpSpacing, 1, 200);

        edited.beginDraw();
        drawGraphPaperSketch(gpX, gpY, gpW, gpH, spacing);
        edited.endDraw();
    }

    private void drawMetatronLayer() {
        println("  Drawing metatron...");

        // Get current metatron settings
        int sides = gui.sliderInt("tools/metatron/sides", mtSides, 3, 24);
        int ringColor = gui.colorPicker("tools/metatron/ring color",
                (mtRingColor == 0 ? color(0, 0, 0) : mtRingColor)).hex;
        boolean draftsman = gui.toggle("tools/metatron/use draftsman", mtDraftsman);

        gui.pushFolder("tools/metatron/jitter");
        float rotDeg = gui.slider("angle (deg)", mtRotDeg, -5f, 5f);
        float dx = gui.slider("offset x", mtDX, -20f, 20f);
        float dy = gui.slider("offset y", mtDY, -20f, 20f);
        float endpointJit = gui.slider("endpoint σ (px)", mtEndpointJit, 0f, 10f);
        float radiusJit = gui.slider("radius σ (px)", mtRadiusJit, 0f, 10f);
        gui.popFolder();

        float x = mtCenter.x;
        float y = mtCenter.y - mtH * 0.5f; // util expects top-left Y

        edited.beginDraw();
        metatron.metaShape(
                edited,
                x, y, mtH,
                sides, ringColor,
                draftsman, metatronStyle,
                rotDeg, dx, dy,
                endpointJit, radiusJit
        );
        edited.endDraw();
    }

    private void drawAsemicLayer() {
        println("  Drawing asemic text...");

        // Get current asemic settings
        float charTileSize = gui.slider("tools/asemic/params/char tile size", max(8f, tileSize), 6f, 64f);
        float charGap = gui.slider("tools/asemic/params/char gap (tiles)", 1.0f, 0f, 4f);

        // Calculate board dimensions based on preview area
        int boardCols = (int)(asPreviewW / charTileSize);
        int boardRows = (int)(asPreviewH / charTileSize);

        // Create board with current layout
        Board tempPage = new Board(asPreviewX, asPreviewY, boardRows, boardCols,
                charTileSize, PAL_A, PAL_B, 10, 10, this);

        // Apply current style settings
        editAsemicStyleFromGUI();
        handleAsemicTool(tempPage);

        // Layout words
        int wordIndex = 0;
        for (int row = 0; row < boardRows; row++) {
            for (int col = 0; col < boardCols; ) {
                if (wordIndex >= asemicWords.size()) break;
                String currentWord = asemicWords.get(wordIndex);

                if (currentWord.equals(newlineMarker)) {
                    row++; col = 0; wordIndex++; continue;
                }

                boolean wasPlaced = AsemicUtil.placeWord(currentWord, col, row, charTileSize, charGap, tempPage);

                if (wasPlaced) {
                    int advance = tempPage.calculateWordTileLength(currentWord, charTileSize, charGap);
                    col += max(1, advance);
                    wordIndex++;
                } else {
                    col++;
                }
            }
            if (wordIndex >= asemicWords.size()) break;
        }

        edited.beginDraw();
        tempPage.renderTo(edited, this, 0, asciiMap);
        edited.endDraw();
    }

    // UI for the draw all feature
    private void handleDrawAllUI() {
        gui.pushFolder("layout/draw all");

        // Layer toggles
        drawAllContours = gui.toggle("include contours", drawAllContours);
        drawAllGraphPaper = gui.toggle("include graph paper", drawAllGraphPaper);
        drawAllMetatron = gui.toggle("include metatron", drawAllMetatron);
        drawAllAsemic = gui.toggle("include asemic text", drawAllAsemic);

        // Drawing order info (read-only display)
        gui.text("Draw order: Contours → Graph → Metatron → Asemic");

        // Main button
        if (gui.button("DRAW ALL LAYOUT")) {
            drawAllLayout();
        }

        // Convenience buttons for common combinations
        if (gui.button("quick: geometric only")) {
            drawAllContours = true;
            drawAllGraphPaper = true;
            drawAllMetatron = true;
            drawAllAsemic = false;
            drawAllLayout();
        }

        if (gui.button("quick: text + structure")) {
            drawAllContours = false;
            drawAllGraphPaper = true;
            drawAllMetatron = false;
            drawAllAsemic = true;
            drawAllLayout();
        }

        if (gui.button("quick: everything")) {
            drawAllContours = true;
            drawAllGraphPaper = true;
            drawAllMetatron = true;
            drawAllAsemic = true;
            drawAllLayout();
        }

        gui.popFolder();
    }


    /* ============================ Helpers ============================ */

    private void initCanvas() {
        // Create blank base image matching window
        int canvasW = width, canvasH = height;
        img = createImage(canvasW, canvasH, HSB);
        img.loadPixels();
        Arrays.fill(img.pixels, bg);
        img.updatePixels();

        // Create output buffer
        edited = createGraphics(canvasW, canvasH, P2D);

        // Clear edited to bg once so preview isn't transparent-looking
        edited.beginDraw();
        edited.background(bg);
        edited.endDraw();

        // Point ComplexEffect at the current output buffer
        if (complexEffect != null) {
            complexEffect.setCanvas(edited);
        }

        if (fbm != null) {
            fbm.setCanvas(edited);
        }

        // Reasonable default for base image scale
        gui.sliderSet("image/scale", 1.0f);
    }

    private void exportImage() {
        String filename = "out/duckforge_" + timestamp() + ".png";
        edited.save(filename);
        println("Saved image to: " + filename);
    }

    /* ---------- Base Image (bake-on-click) ---------- */
    private void handleBaseImageBakeUI() {
        gui.pushFolder("image");
        float scale = gui.slider("scale", 1.0f, 0.1f, 5.0f);
        float x     = gui.slider("x", 0, -width, width);
        float y     = gui.slider("y", 0, -height, height);

        if (gui.button("bake base image")) {
            edited.beginDraw();
            edited.imageMode(CENTER);
            edited.pushMatrix();
            edited.translate(edited.width / 2f + x, edited.height / 2f + y);
            edited.scale(scale);
            edited.image(img, 0, 0);
            edited.popMatrix();
            edited.endDraw();
        }

        if (gui.button("clear edited to bg")) {
            edited.beginDraw();
            edited.background(bg);
            edited.endDraw();
        }

        if (gui.button("select/load image")) {
            selectImage(); // re-creates edited; re-attach ComplexEffect inside
        }
        gui.popFolder();
    }

    /* ---------- Effects ---------- */
    private void applyEffects() {
        for (Effect fx : effects) fx.apply(edited, gui);
    }

    /* ---------- Graph Paper ---------- */
    private void handleGraphPaperTool() {
        // Position/size
        PVector pos = gui.plotXY("tools/graphpaper/position", gpX, gpY);
        gpX = pos.x; gpY = pos.y;
        gpW = gui.slider("tools/graphpaper/width",  gpW, 10, width);
        gpH = gui.slider("tools/graphpaper/height", gpH, 10, height);
        gpSpacing = gui.slider("tools/graphpaper/spacing", gpSpacing, 1, 200);

        // Preview outline
        gpPreviewEnabled = gui.toggle("tools/graphpaper/preview outline", gpPreviewEnabled);
        gpPreviewColor   = gui.colorPicker("tools/graphpaper/preview color",
                (gpPreviewColor == 0 ? color(200, 100, 100) : gpPreviewColor)).hex;

        // Bake on click
        if (gui.button("tools/graphpaper/draw graph paper")) {
            edited.beginDraw();
            drawGraphPaperSketch(gpX, gpY, gpW, gpH, gpSpacing);
            edited.endDraw();
        }
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

    private void editGraphPaperStyleFromGUI() {
        gui.pushFolder("tools/graphpaper/style");
        int col = gui.colorPicker("stroke color", graphStyleV.strokeColor).hex;

        float alpha = gui.slider("alpha", graphStyleV.baseAlpha, 0, 1);
        float hueScale = gui.slider("hueScale", graphStyleV.hueScale, 0.0001f, 0.1f);
        float satScale = gui.slider("satScale", graphStyleV.satScale, 0.0001f, 1.0f);
        float brtScale = gui.slider("brtScale", graphStyleV.brtScale, 0.0001f, 1.0f);
        float weightFreq = gui.slider("weightScale", graphStyleV.weightScale, 0.0001f, 1.0f);
        float baseSigma = gui.slider("baseNoiseSigma", graphStyleV.baseNoiseSigma, 0, 50);
        float jitter = gui.slider("jitterSigma", graphStyleV.jitterSigma, 0, 2);
        int repeats = gui.sliderInt("repeats", graphStyleV.repeats, 1, 12);
        float stepMul = gui.slider("stepMultiplier", graphStyleV.stepMultiplier, 0.1f, 4.0f);
        int stepsMax = gui.sliderInt("stepsMax", graphStyleV.stepsMax, 0, 10000);
        gui.popFolder();

        // Mirror into both styles (split later if desired)
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

    /* ---------- Metatron ---------- */
    private void handleMetatronTool() {
        PVector c = gui.plotXY("tools/metatron/center", mtCenter);
        mtCenter.set(c);

        mtH     = gui.slider("tools/metatron/height", mtH, 50, height);
        mtSides = gui.sliderInt("tools/metatron/sides", mtSides, 3, 24);
        mtRingColor = gui.colorPicker("tools/metatron/ring color",
                (mtRingColor == 0 ? color(0, 0, 0) : mtRingColor)).hex;
        mtDraftsman = gui.toggle("tools/metatron/use draftsman", mtDraftsman);

        gui.pushFolder("tools/metatron/jitter");
        mtRotDeg    = gui.slider("angle (deg)", mtRotDeg, -5f, 5f);
        mtDX        = gui.slider("offset x", mtDX, -20f, 20f);
        mtDY        = gui.slider("offset y", mtDY, -20f, 20f);
        mtEndpointJit = gui.slider("endpoint σ (px)", mtEndpointJit, 0f, 10f);
        mtRadiusJit   = gui.slider("radius σ (px)",   mtRadiusJit,   0f, 10f);
        gui.popFolder();

        mtPreviewEnabled = gui.toggle("tools/metatron/preview outline", mtPreviewEnabled);
        mtPreviewColor   = gui.colorPicker("tools/metatron/preview color",
                (mtPreviewColor == 0 ? color(200, 100, 100) : mtPreviewColor)).hex;

        if (gui.button("tools/metatron/draw metatron (bake)")) {
            float x = mtCenter.x;
            float y = mtCenter.y - mtH * 0.5f; // util expects top-left Y

            edited.beginDraw();
            metatron.metaShape(
                    edited,
                    x, y, mtH,
                    mtSides, mtRingColor,
                    mtDraftsman, metatronStyle,
                    mtRotDeg, mtDX, mtDY,
                    mtEndpointJit, mtRadiusJit
            );
            edited.endDraw();
        }
    }

    private void handleAsemicPreviewUI() {
        gui.pushFolder("tools/asemic/preview");

        // Position and size controls for preview
        PVector pos = gui.plotXY("text area/top-left", new PVector(asPreviewX, asPreviewY));
        asPreviewX = pos.x;
        asPreviewY = pos.y;
        asPreviewW = gui.slider("text area/width", asPreviewW, 100, width);
        asPreviewH = gui.slider("text area/height", asPreviewH, 100, height);

        // Preview controls
        asPreviewEnabled = gui.toggle("outline enabled", asPreviewEnabled);
        asPreviewColor = gui.colorPicker("outline color",
                (asPreviewColor == 0 ? color(200, 100, 100) : asPreviewColor)).hex;

        gui.popFolder();
    }


    private void editMetatronStyleFromGUI() {
        gui.pushFolder("tools/metatron/style");
        metatronStyle.strokeColor = gui.colorPicker("stroke color", metatronStyle.strokeColor).hex;
        metatronStyle.baseAlpha   = gui.slider("alpha", metatronStyle.baseAlpha, 0, 1);
        metatronStyle.hueScale    = gui.slider("hueScale", metatronStyle.hueScale, 0.0001f, 0.1f);
        metatronStyle.satScale    = gui.slider("satScale", metatronStyle.satScale, 0.0001f, 1.0f);
        metatronStyle.brtScale    = gui.slider("brtScale", metatronStyle.brtScale, 0.0001f, 1.0f);
        metatronStyle.weightScale = gui.slider("weightScale", metatronStyle.weightScale, 0.0001f, 1.0f);
        metatronStyle.baseNoiseSigma = gui.slider("baseNoiseSigma", metatronStyle.baseNoiseSigma, 0, 50);
        metatronStyle.jitterSigma    = gui.slider("jitterSigma", metatronStyle.jitterSigma, 0, 2);
        metatronStyle.repeats        = gui.sliderInt("repeats", metatronStyle.repeats, 1, 12);
        metatronStyle.stepMultiplier = gui.slider("stepMultiplier", metatronStyle.stepMultiplier, 0.1f, 4.0f);
        metatronStyle.stepsMax       = gui.sliderInt("stepsMax (0=none)", metatronStyle.stepsMax, 0, 10000);
        metatronStyle.fixedWeight    = gui.slider("fixedWeight (non-draftsman)", metatronStyle.fixedWeight, 0.5f, 5f);
        gui.popFolder();
    }

    /* ---------- Contours ---------- */
    private void handleContourTool() {
        gui.pushFolder("tools/contours");
        {
            PVector pos = gui.plotXY("region/top-left", ctPos);
            ctPos.set(pos);
            ctW = gui.slider("region/width",  ctW, 10, width);
            ctH = gui.slider("region/height", ctH, 10, height);

            boolean fbmEnabled = gui.toggle("fbm enabled", true);
            int     oct        = gui.sliderInt("octaves", 4, 1, 8);
            float   lac        = gui.slider("lacunarity", 2.0f, 1.0f, 4.0f);
            float   gain       = gui.slider("gain", 0.5f, 0.0f, 1.0f);
            float   off        = gui.slider("field scale (off)", 0.01f, 0.001f, 0.05f);
            float   step       = gui.slider("step length", 2.0f, 0.5f, 5.0f);

            ctPreviewEnabled = gui.toggle("preview/outline enabled", ctPreviewEnabled);
            ctPreviewColor   = gui.colorPicker("preview/color",
                    (ctPreviewColor == 0 ? color(200, 100, 100) : ctPreviewColor)).hex;

            if (gui.button("build contours (bake)")) {
                ContourMap cm = new ContourMap(
                        this,
                        contourNoise,
                        oct, lac, gain,
                        fbmEnabled,
                        off, step,
                        lines
                );
                // Preserve your working lifecycle: cm builds; then we end.
                cm.buildMapLayer(edited, contourStyle, ctPos.x, ctPos.y, ctW, ctH);
                edited.endDraw();
            }
        }
        gui.popFolder();
    }


    private void handleAsemicUIAndBake() {
        gui.pushFolder("tools/asemic/params");
        float charTileSize = gui.slider("char tile size", max(8f, tileSize), 6f, 64f);
        float charGap = gui.slider("char gap (tiles)", 1.0f, 0f, 4f);
        gui.popFolder();

        // Add the preview UI here
        handleAsemicPreviewUI();

        // add arm01
        if (gui.button("tools/asemic/build+render (one shot)")) {
            // Calculate board dimensions based on preview area and tile size
            int boardCols = (int)(asPreviewW / charTileSize);
            int boardRows = (int)(asPreviewH / charTileSize);

            page = new Board(asPreviewX, asPreviewY, boardRows, boardCols, charTileSize, PAL_A, PAL_B, 10, 10, this);

            editAsemicStyleFromGUI();
            handleAsemicTool(page);

            int wordIndex = 0;
            int startRow = 0;
            for (int row = startRow; row < boardRows; row++) {
                int startCol = 0;
                int endCol = boardCols;

                for (int col = startCol; col < endCol; ) {
                    if (wordIndex >= asemicWords.size()) break;
                    String currentWord = asemicWords.get(wordIndex);

                    if (currentWord.equals(newlineMarker)) {
                        row++; col = startCol; wordIndex++; continue;
                    }

                    boolean wasPlaced = AsemicUtil.placeWord(currentWord, col, row, charTileSize, charGap, page);

                    if (wasPlaced) {
                        int advance = page.calculateWordTileLength(currentWord, charTileSize, charGap);
                        col += max(1, advance);
                        wordIndex++;
                    } else {
                        col++;
                    }
                }
                if (wordIndex >= asemicWords.size()) break;
            }

            edited.beginDraw();
            page.renderTo(edited, this, 0, asciiMap);
            edited.endDraw();
        }
    }

    private void editAsemicStyleFromGUI() {
        gui.pushFolder("tools/asemic/style");
        int sc = gui.colorPicker("stroke color", asemicStyle.strokeColor).hex;
        float a  = gui.slider("alpha",      asemicStyle.baseAlpha, 0, 1);
        float hs = gui.slider("hueScale",   asemicStyle.hueScale,  0.0001f, 0.1f);
        float ss = gui.slider("satScale",   asemicStyle.satScale,  0.0001f, 1.0f);
        float bs = gui.slider("brtScale",   asemicStyle.brtScale,  0.0001f, 1.0f);
        float ws = gui.slider("weightScale",asemicStyle.weightScale,0.0001f,1.0f);
        float bns= gui.slider("baseNoiseSigma",  asemicStyle.baseNoiseSigma, 0, 50);
        float jit= gui.slider("jitterSigma",     asemicStyle.jitterSigma,    0, 2);
        int rep  = gui.sliderInt("repeats",      asemicStyle.repeats, 1, 12);
        float sm = gui.slider("stepMultiplier",  asemicStyle.stepMultiplier, 0.1f, 4.0f);
        int sMx  = gui.sliderInt("stepsMax (0=none)", asemicStyle.stepsMax, 0, 10000);
        float fw = gui.slider("fixedWeight (non-draftsman)", asemicStyle.fixedWeight, 0.5f, 5f);
        gui.popFolder();

        asemicStyle.strokeColor = sc;
        asemicStyle.baseAlpha   = a;
        asemicStyle.hueScale    = hs;
        asemicStyle.satScale    = ss;
        asemicStyle.brtScale    = bs;
        asemicStyle.weightScale = ws;
        asemicStyle.baseNoiseSigma = bns;
        asemicStyle.jitterSigma    = jit;
        asemicStyle.repeats        = rep;
        asemicStyle.stepMultiplier = sm;
        asemicStyle.stepsMax       = sMx;
        asemicStyle.fixedWeight    = fw;
    }

    private void handleAsemicTool(Board page) {
        gui.pushFolder("tools/asemic");

        boolean useDraftsman = gui.toggle("use draftsman for words", true);
        gui.popFolder();
        page.setAsemicPen(lines, asemicStyle, useDraftsman);
    }

    /* ---------- Preview ---------- */
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

        // Contours preview overlay (box)
        if (ctPreviewEnabled) {
            final int cell = 50;
            pushStyle(); pushMatrix();
            translate(-edited.width / 2f, -edited.height / 2f);

            float rx0 = constrain(ctPos.x, 0, edited.width);
            float ry0 = constrain(ctPos.y, 0, edited.height);
            float rx1 = constrain(ctPos.x + ctW, 0, edited.width);
            float ry1 = constrain(ctPos.y + ctH, 0, edited.height);

            int left   = (int)(ceil (rx0 / cell) * cell);
            int top    = (int)(ceil (ry0 / cell) * cell);
            int right  = (int)(floor(rx1 / cell) * cell);
            int bottom = (int)(floor(ry1 / cell) * cell);

            if (right - left >= cell && bottom - top >= cell) {
                noFill();
                stroke(ctPreviewColor == 0 ? color(200, 100, 100) : ctPreviewColor);
                strokeWeight(3);
                rectMode(CORNER);
                rect(left, top, right - left, bottom - top);
            }
            popMatrix(); popStyle();
        }

        // Metatron preview outline
        if (mtPreviewEnabled) {
            pushStyle(); pushMatrix();
            translate(-edited.width / 2f, -edited.height / 2f);

            noFill();
            stroke(mtPreviewColor == 0 ? color(200, 100, 100) : mtPreviewColor);
            strokeWeight(3);

            float cx = mtCenter.x, cy = mtCenter.y;
            float ringRadius = 0.125f * mtH;
            float jitterMargin = max(0f, (mtRadiusJit * 2f) + mtEndpointJit);
            float s = mtH + 2f * (ringRadius + jitterMargin);
            float tlx = cx - s * 0.5f, tly = cy - s * 0.5f;

            float ang = radians(mtRotDeg);
            float ca = cos(ang), sa = sin(ang);

            java.util.function.BiFunction<Float, Float, PVector> xf = (px, py) -> {
                float x0 = px - cx, y0 = py - cy;
                float x1 = x0 + mtDX, y1 = y0 + mtDY;
                float xr = x1 * ca - y1 * sa, yr = x1 * sa + y1 * ca;
                return new PVector(xr + cx, yr + cy);
            };

            PVector c0 = xf.apply(tlx,      tly);
            PVector c1 = xf.apply(tlx + s,  tly);
            PVector c2 = xf.apply(tlx + s,  tly + s);
            PVector c3 = xf.apply(tlx,      tly + s);

            beginShape();
            vertex(c0.x, c0.y); vertex(c1.x, c1.y);
            vertex(c2.x, c2.y); vertex(c3.x, c3.y);
            endShape(CLOSE);

            popMatrix(); popStyle();
        }

        // Graph paper preview outline
        if (gpPreviewEnabled) {
            pushStyle(); pushMatrix();
            translate(-edited.width / 2f, -edited.height / 2f);
            noFill();
            stroke(gpPreviewColor == 0 ? color(200, 100, 100) : gpPreviewColor);
            strokeWeight(3);

            float maxAngle = radians(1);
            float angle = map(noise(SEED), 0, 1, -maxAngle, maxAngle);
            float dx = map(noise(SEED + 1), 0, 1, -10, 10);
            float dy = map(noise(SEED + 2), 0, 1, -10, 10);

            float cx = gpX + gpW * 0.5f;
            float cy = gpY + gpH * 0.5f;
            float cosA = cos(angle), sinA = sin(angle);

            java.util.function.BiFunction<Float, Float, PVector> xf = (px, py) -> {
                float x1 = px - gpW * 0.5f, y1 = py - gpH * 0.5f;
                float x2 = x1 + dx,        y2 = y1 + dy;
                float xr = x2 * cosA - y2 * sinA, yr = x2 * sinA + y2 * cosA;
                return new PVector(xr + cx, yr + cy);
            };

            PVector c0 = xf.apply(gpX,          gpY);
            PVector c1 = xf.apply(gpX + gpW,    gpY);
            PVector c2 = xf.apply(gpX + gpW,    gpY + gpH);
            PVector c3 = xf.apply(gpX,          gpY + gpH);

            beginShape();
            vertex(c0.x, c0.y); vertex(c1.x, c1.y);
            vertex(c2.x, c2.y); vertex(c3.x, c3.y);
            endShape(CLOSE);

            popMatrix(); popStyle();
        }

        if (asPreviewEnabled) {
            pushStyle(); pushMatrix();
            translate(-edited.width / 2f, -edited.height / 2f);

            noFill();
            stroke(asPreviewColor == 0 ? color(200, 100, 100) : asPreviewColor);
            strokeWeight(3);
            rectMode(CORNER);

            // Draw the text area boundary
            rect(asPreviewX, asPreviewY, asPreviewW, asPreviewH);

            // Optionally, draw a grid to show character tile layout
            float charTileSize = gui.slider("tools/asemic/params/char tile size", max(8f, tileSize), 6f, 64f);
            if (charTileSize > 0) {
                stroke(asPreviewColor == 0 ? color(200, 100, 100, 0.3f) : color(red(asPreviewColor), green(asPreviewColor), blue(asPreviewColor), 0.3f));
                strokeWeight(1);

                // Vertical grid lines
                for (float x = asPreviewX; x <= asPreviewX + asPreviewW; x += charTileSize) {
                    if (x > asPreviewX && x < asPreviewX + asPreviewW) {
                        line(x, asPreviewY, x, asPreviewY + asPreviewH);
                    }
                }

                // Horizontal grid lines
                for (float y = asPreviewY; y <= asPreviewY + asPreviewH; y += charTileSize) {
                    if (y > asPreviewY && y < asPreviewY + asPreviewH) {
                        line(asPreviewX, y, asPreviewX + asPreviewW, y);
                    }
                }
            }

            popMatrix(); popStyle();
        }

        popMatrix();
    }

    /* ---------- Image selection ---------- */
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

                // Clear to bg so the new buffer has a defined background
                edited.beginDraw();
                edited.background(bg);
                edited.image(img, 0, 0);
                edited.endDraw();

                // FIX: Point ComplexEffect at the new output buffer
                if (complexEffect != null) {
                    complexEffect.setCanvas(edited);
                }

                float windowAspect = (float) width / height;
                float imgAspect = (float) img.width / img.height;
                float fitScale = (imgAspect > windowAspect)
                        ? (float) width / img.width
                        : (float) height / img.height;

                gui.sliderSet("image/scale", fitScale);
            }
        }
    }


    private void autoLayoutTools() {
        // Canvas dimensions with margins
        float margin = 50f;
        float workWidth = width - 2 * margin;
        float workHeight = height - 2 * margin;

        // Calculate optimal sizes based on canvas proportions
        float canvasAspect = workWidth / workHeight;

        // Define relative sizes (these can be tweaked)
        float asemicWidthRatio = 0.45f;   // Asemic takes about 45% width
        float asemicHeightRatio = 0.6f;   // and 60% height

        float metatronSizeRatio = 0.3f;   // Metatron is 30% of canvas height
        float contourSizeRatio = 0.35f;   // Contours are 35% of canvas dimensions
        float graphSizeRatio = 0.25f;     // Graph paper is 25% of canvas dimensions

        // Calculate actual sizes
        float asemicW = workWidth * asemicWidthRatio;
        float asemicH = workHeight * asemicHeightRatio;
        float metatronSize = workHeight * metatronSizeRatio;
        float contourW = workWidth * contourSizeRatio;
        float contourH = workHeight * contourSizeRatio;
        float graphW = workWidth * graphSizeRatio;
        float graphH = workHeight * graphSizeRatio;

        // Layout strategy:
        // - Asemic text in top-left (largest area)
        // - Metatron in top-right
        // - Contours in bottom-left
        // - Graph paper in bottom-right

        // Asemic (top-left corner)
        asPreviewX = margin;
        asPreviewY = margin;
        asPreviewW = asemicW;
        asPreviewH = asemicH;

        // Metatron (top-right, centered in available space)
        float metatronAreaX = margin + asemicW + 20; // 20px gap
        float metatronAreaW = workWidth - asemicW - 20;
        float metatronAreaY = margin;
        float metatronAreaH = asemicH; // Same height as asemic

        mtCenter.set(
                metatronAreaX + metatronAreaW * 0.5f,
                metatronAreaY + metatronAreaH * 0.5f
        );
        mtH = min(metatronSize, min(metatronAreaW * 0.8f, metatronAreaH * 0.8f));

        // Contours (bottom-left)
        float bottomAreaY = margin + asemicH + 20; // 20px gap
        float bottomAreaH = workHeight - asemicH - 20;

        ctPos.set(margin, bottomAreaY);
        ctW = contourW;
        ctH = min(contourH, bottomAreaH);

        // Graph paper (bottom-right, in remaining space)
        float graphAreaX = margin + contourW + 20; // 20px gap
        float graphAreaW = workWidth - contourW - 20;

        gpX = graphAreaX;
        gpY = bottomAreaY;
        gpW = min(graphW, graphAreaW);
        gpH = min(graphH, bottomAreaH);

        // Update GUI sliders to reflect new positions
        gui.plotSet("tools/asemic/preview/text area/top-left", asPreviewX, asPreviewY);
        gui.sliderSet("tools/asemic/preview/text area/width", asPreviewW);
        gui.sliderSet("tools/asemic/preview/text area/height", asPreviewH);

        gui.plotSet("tools/metatron/center", mtCenter.x, mtCenter.y);
        gui.sliderSet("tools/metatron/height", mtH);

        gui.plotSet("tools/contours/region/top-left", ctPos.x, ctPos.y);
        gui.sliderSet("tools/contours/region/width", ctW);
        gui.sliderSet("tools/contours/region/height", ctH);

        gui.plotSet("tools/graphpaper/position", gpX, gpY);
        gui.sliderSet("tools/graphpaper/width", gpW);
        gui.sliderSet("tools/graphpaper/height", gpH);
    }

    // Add this method for a more compact layout option
    private void autoLayoutToolsCompact() {
        float margin = 30f;
        float gap = 15f;
        float workWidth = width - 2 * margin;
        float workHeight = height - 2 * margin;

        // Divide canvas into a 2x2 grid with gaps
        float cellW = (workWidth - gap) * 0.5f;
        float cellH = (workHeight - gap) * 0.5f;

        // Asemic (top-left, takes most of its cell)
        asPreviewX = margin;
        asPreviewY = margin;
        asPreviewW = cellW * 0.9f;
        asPreviewH = cellH * 0.85f;

        // Metatron (top-right, centered in cell)
        float metatronCellX = margin + cellW + gap;
        float metatronCellY = margin;
        mtCenter.set(
                metatronCellX + cellW * 0.5f,
                metatronCellY + cellH * 0.5f
        );
        mtH = min(cellW, cellH) * 0.7f;

        // Contours (bottom-left)
        ctPos.set(margin, margin + cellH + gap);
        ctW = cellW * 0.8f;
        ctH = cellH * 0.8f;

        // Graph paper (bottom-right)
        gpX = metatronCellX;
        gpY = margin + cellH + gap;
        gpW = cellW * 0.75f;
        gpH = cellH * 0.75f;

        // Update GUI
        updateGUIFromLayout();
    }

    // Helper method to update GUI sliders after layout changes
    private void updateGUIFromLayout() {
        // Check if GUI elements exist before trying to update them
        try {
            gui.plotSet("tools/asemic/preview/text area/top-left", asPreviewX, asPreviewY);
            gui.sliderSet("tools/asemic/preview/text area/width", asPreviewW);
            gui.sliderSet("tools/asemic/preview/text area/height", asPreviewH);

            gui.plotSet("tools/metatron/center", mtCenter.x, mtCenter.y);
            gui.sliderSet("tools/metatron/height", mtH);

            gui.plotSet("tools/contours/region/top-left", ctPos.x, ctPos.y);
            gui.sliderSet("tools/contours/region/width", ctW);
            gui.sliderSet("tools/contours/region/height", ctH);

            gui.plotSet("tools/graphpaper/position", gpX, gpY);
            gui.sliderSet("tools/graphpaper/width", gpW);
            gui.sliderSet("tools/graphpaper/height", gpH);
        } catch (Exception e) {
            // GUI elements might not exist yet, ignore silently
        }
    }

    private void layoutTextHeavy() {
        float margin = 40f;
        // Asemic gets 70% of width, full height minus margin for other tools
        asPreviewX = margin;
        asPreviewY = margin;
        asPreviewW = width * 0.7f;
        asPreviewH = height - 200;

        // Other tools arranged vertically on the right
        float rightX = asPreviewX + asPreviewW + 20;
        float rightW = width - rightX - margin;
        float toolHeight = 150f;

        // Metatron at top right
        mtCenter.set(rightX + rightW * 0.5f, margin + toolHeight * 0.5f);
        mtH = min(rightW, toolHeight) * 0.8f;

        // Contours middle right
        ctPos.set(rightX, margin + toolHeight + 20);
        ctW = rightW;
        ctH = toolHeight;

        // Graph paper bottom right
        gpX = rightX;
        gpY = margin + toolHeight * 2 + 40;
        gpW = rightW;
        gpH = toolHeight;

        updateGUIFromLayout();
    }

    private void layoutGeometricFocus() {
        float margin = 50f;
        float centerX = width * 0.5f;
        float centerY = height * 0.5f;

        // Large metatron in center
        mtCenter.set(centerX, centerY);
        mtH = min(width, height) * 0.4f;

        // Contours as background layer (full canvas minus margins)
        ctPos.set(margin, margin);
        ctW = width - 2 * margin;
        ctH = height - 2 * margin;

        // Graph paper in corners
        float cornerSize = 200f;
        gpX = margin;
        gpY = margin;
        gpW = cornerSize;
        gpH = cornerSize;

        // Asemic as side panel
        asPreviewX = width - margin - 300;
        asPreviewY = margin;
        asPreviewW = 250;
        asPreviewH = height - 2 * margin;

        updateGUIFromLayout();
    }

    private String timestamp() {
        return year() + nf(month(), 2) + nf(day(), 2) + "_"
                + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    }
}
