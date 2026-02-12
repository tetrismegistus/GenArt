/*
SketchName: simplePost.pde
Credits: postfx, lazygui
Description: image editor with one Apply button that bakes (blend + filter + postfx),
             then resets all controls to defaults.
*/

import java.io.File;

import com.krab.lazy.*;

import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

String sketchName = "mySketch";
String saveFormat = ".png";

final String SAVE_DIR = "saves/";

int calls = 0;
long lastTime;

LazyGui gui;
PostFX fx;

PImage base = null;      // committed/baked image
PGraphics work = null;   // scratch buffer for preview + intermediate bakes
String imgPath = null;

final String[] BLEND_MODE_NAMES = {
  "BLEND",
  "ADD",
  "SUBTRACT",
  "DARKEST",
  "LIGHTEST",
  "DIFFERENCE",
  "EXCLUSION",
  "MULTIPLY",
  "SCREEN",
  "REPLACE"
};

final String[] FILTER_MODE_NAMES = {
  "NONE",
  "THRESHOLD",
  "GRAY",
  "OPAQUE",
  "INVERT",
  "POSTERIZE",
  "BLUR",
  "ERODE",
  "DILATE"
};

void settings() {
  size(800, 800, P2D);
}

void setup() {
  surface.setResizable(true);
  colorMode(HSB, 360, 100, 100, 1);

  gui = new LazyGui(this);
  fx  = new PostFX(this);

  ensureSaveDir();
  resetAllControlsToDefault();
}

void draw() {
  background(0);

  // ---------- UI ----------
  gui.pushFolder("image");
  if (gui.button("load")) {
    selectInput("Select an image", "fileSelected");
  }
  if (base != null && gui.button("save")) {
    base.save(sketchPath(SAVE_DIR + getTemporalName(sketchName, saveFormat)));
  }
  gui.popFolder();

  if (base == null) return;

  // Single apply button that bakes everything currently enabled,
  // then resets ALL settings to defaults.
  if (gui.button("apply")) {
    bakeAllAndReset();
  }

  // ---------- PREVIEW ----------
  // Preview is base + current blend + current filter (in work)
  ensureWorkBufferMatchesBase();
  renderBlendAndFilterPreviewIntoWork();

  // Draw preview to screen
  blendMode(BLEND);
  image(work, 0, 0);

  // Preview PostFX on screen
  applyPostFxToScreenFromGui();
}

/* =========================================================
   Preview: blend + filter into work (NO PostFX here)
   ========================================================= */

void renderBlendAndFilterPreviewIntoWork() {
  work.beginDraw();
  work.background(0);
  work.blendMode(BLEND);

  // start from committed base
  work.image(base, 0, 0);

  // preview blend mode as deterministic pixel change:
  // draw base again under selected blend mode
  int bm = getBlendModeFromGui();
  if (bm != BLEND) {
    work.blendMode(bm);
    work.image(base, 0, 0);
    work.blendMode(BLEND);
  }

  // preview filter on work
  applyFilterToGraphicsFromGui(work);

  work.endDraw();
}

/* =========================================================
   Apply: bake blend + filter + postfx, reset UI defaults
   ========================================================= */

void bakeAllAndReset() {
  // Step 1: bake blend + filter into work
  ensureWorkBufferMatchesBase();

  work.beginDraw();
  work.background(0);
  work.blendMode(BLEND);

  // base -> work
  work.image(base, 0, 0);

  // apply blend as a pixel operation (double-draw)
  int bm = getBlendModeFromGui();
  if (bm != BLEND) {
    work.blendMode(bm);
    work.image(base, 0, 0);
    work.blendMode(BLEND);
  }

  // apply filter directly to work
  applyFilterToGraphicsFromGui(work);

  work.endDraw();

  // Step 2: bake postfx (PostFX composes to SCREEN reliably)
  // draw the intermediate (work) to screen, apply postfx, capture -> base
  background(0);
  blendMode(BLEND);
  image(work, 0, 0);

  applyPostFxToScreenFromGui();

  // capture the result
  base = get();

  // Step 3: reset ALL UI controls to defaults
  resetAllControlsToDefault();

  // keep buffers aligned
  ensureWorkBufferMatchesBase();
}

/* =========================================================
   BlendMode UI
   ========================================================= */

int getBlendModeFromGui() {
  String mode = gui.radio("blendMode/mode", BLEND_MODE_NAMES, "BLEND");
  return blendModeConstant(mode);
}

int blendModeConstant(String modeName) {
  if (modeName == null) return BLEND;
  switch (modeName) {
    case "ADD":        return ADD;
    case "SUBTRACT":   return SUBTRACT;
    case "DARKEST":    return DARKEST;
    case "LIGHTEST":   return LIGHTEST;
    case "DIFFERENCE": return DIFFERENCE;
    case "EXCLUSION":  return EXCLUSION;
    case "MULTIPLY":   return MULTIPLY;
    case "SCREEN":     return SCREEN;
    case "REPLACE":    return REPLACE;
    case "BLEND":
    default:           return BLEND;
  }
}

/* =========================================================
   Filter UI -> apply to a PGraphics
   ========================================================= */

void applyFilterToGraphicsFromGui(PGraphics pg) {
  String mode = gui.radio("filter/mode", FILTER_MODE_NAMES, "NONE");
  if (mode == null || mode.equals("NONE")) return;

  float thresholdLevel = gui.slider("filter/thresholdLevel", 0.5f, 0.0f, 1.0f);
  int posterizeLevels  = gui.sliderInt("filter/posterizeLevels", 6, 2, 255);
  float blurRadius     = gui.slider("filter/blurRadius", 1.0f, 0.0f, 20.0f);

  switch (mode) {
    case "THRESHOLD": pg.filter(THRESHOLD, thresholdLevel); break;
    case "GRAY":      pg.filter(GRAY); break;
    case "OPAQUE":    pg.filter(OPAQUE); break;
    case "INVERT":    pg.filter(INVERT); break;
    case "POSTERIZE": pg.filter(POSTERIZE, posterizeLevels); break;
    case "BLUR":      pg.filter(BLUR, blurRadius); break;
    case "ERODE":     pg.filter(ERODE); break;
    case "DILATE":    pg.filter(DILATE); break;
  }
}

/* =========================================================
   PostFX UI -> compose to SCREEN
   ========================================================= */

void applyPostFxToScreenFromGui() {
  gui.pushFolder("postfx");

  gui.pushFolder("rgbSplit");
  boolean rgbEnabled = gui.toggle("enabled");
  float rgbDelta = gui.slider("delta", 100.0f, 0.0f, 500.0f);
  gui.popFolder();

  gui.pushFolder("bloom");
  boolean bloomEnabled = gui.toggle("enabled");
  float bloomThreshold = gui.slider("threshold", 0.9f, 0.0f, 1.0f);
  int bloomBlurSize = gui.sliderInt("blurSize", 10, 0, 200);
  float bloomSigma = gui.slider("sigma", 200.0f, 0.0f, 500.0f);
  gui.popFolder();

  gui.pushFolder("sobel");
  boolean sobelEnabled = gui.toggle("enabled");
  gui.popFolder();

  gui.popFolder();

  if (!rgbEnabled && !bloomEnabled && !sobelEnabled) return;

  PostFXBuilder b = fx.render();
  if (rgbEnabled)   b = b.rgbSplit(rgbDelta);
  if (bloomEnabled) b = b.bloom(bloomThreshold, bloomBlurSize, bloomSigma);
  if (sobelEnabled) b = b.sobel();
  b.compose(); // screen
}

/* =========================================================
   Loading / sizing / PostFX rebuild
   ========================================================= */

void fileSelected(File selection) {
  if (selection == null) return;

  imgPath = selection.getAbsolutePath();
  PImage loaded = loadImage(imgPath);
  if (loaded == null) {
    println("Failed to load image: " + imgPath);
    return;
  }

  base = loaded;

  int w = max(64, base.width);
  int h = max(64, base.height);
  surface.setSize(w, h);

  ensureWorkBufferMatchesBase();

  // PostFX buffers must match sketch size
  rebuildPostFxForCurrentSize();

  resetAllControlsToDefault();
}

void windowResized() {
  if (base == null) return;
  rebuildPostFxForCurrentSize();
}

void rebuildPostFxForCurrentSize() {
  fx = new PostFX(this);
}

void ensureWorkBufferMatchesBase() {
  if (base == null) return;
  if (work == null || work.width != base.width || work.height != base.height) {
    work = createGraphics(base.width, base.height, P2D);
  }
}

/* =========================================================
   Control reset (LazyGui setters)
   ========================================================= */

void resetAllControlsToDefault() {
  // blend
  gui.radioSet("blendMode/mode", "BLEND");

  // postfx
  gui.toggleSet("postfx/rgbSplit/enabled", false);
  gui.sliderSet("postfx/rgbSplit/delta", 100.0f);

  gui.toggleSet("postfx/bloom/enabled", false);
  gui.sliderSet("postfx/bloom/threshold", 0.9f);
  gui.sliderIntSet("postfx/bloom/blurSize", 10);
  gui.sliderSet("postfx/bloom/sigma", 200.0f);

  gui.toggleSet("postfx/sobel/enabled", false);

  // filter
  gui.radioSet("filter/mode", "NONE");
  gui.sliderSet("filter/thresholdLevel", 0.5f);
  gui.sliderIntSet("filter/posterizeLevels", 6);
  gui.sliderSet("filter/blurRadius", 1.0f);
}

/* =========================================================
   Misc
   ========================================================= */

void ensureSaveDir() {
  File dir = new File(sketchPath(SAVE_DIR));
  if (!dir.exists()) dir.mkdirs();
}

void keyReleased() {
  if (key == 's' || key == 'S') {
    if (base != null) base.save(sketchPath(SAVE_DIR + getTemporalName(sketchName, saveFormat)));
  }
}

String getTemporalName(String prefix, String suffix) {
  long time = System.currentTimeMillis();
  if (lastTime == time) calls++;
  else { lastTime = time; calls = 0; }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}
