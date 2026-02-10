/*
SketchName: simplePost.pde
Credits: postfx, lazygui
Description: a simple application of postfx using lazygui
*/


import com.krab.lazy.*;

import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;


String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

PostFX fx;
LazyGui gui;
PImage img;
PGraphics edited;
String imgPath = null;

final String SAVE_DIR = "saves/";

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
  fx = new PostFX(this);
}


void draw() {
  background(0);

  if (gui.button("load image")) {
    selectInput("Select an image", "fileSelected");
  }
  
  if (gui.button("save image")) {
    saveFrame(SAVE_DIR + getTemporalName(sketchName, saveFormat));
  }


  if (img == null) return;

  int bm = getBlendModeFromGui();
  float scale = gui.slider("image/scale", 1.0f, 0.01f, 10.0f);

  blendMode(bm);
  pushMatrix();
  scale(scale);
  image(img, 0, 0);
  popMatrix();
  postProcessFromGui();
  blendMode(BLEND);

  applyFilterFromGui();
}


void postProcessFromGui() {
  gui.pushFolder("postfx");

  // --- rgbSplit ---
  gui.pushFolder("rgbSplit");
  boolean rgbEnabled = gui.toggle("enabled");
  float rgbDelta     = gui.slider("delta", 100.0f, 0.0f, 500.0f);
  gui.popFolder();

  // --- bloom ---
  gui.pushFolder("bloom");
  boolean bloomEnabled = gui.toggle("enabled");
  float bloomThreshold = gui.slider("threshold", 0.9f, 0.0f, 1.0f);
  int bloomBlurSize  = gui.sliderInt("blurSize", 10, 0, 200);
  float bloomSigma     = gui.slider("sigma", 200.0f, 0.0f, 500.0f);
  gui.popFolder();

  // --- sobel ---
  gui.pushFolder("sobel");
  boolean sobelEnabled = gui.toggle("enabled");
  gui.popFolder();

  gui.popFolder(); // postfx

  // Build chain conditionally
  PostFXBuilder b = fx.render();

  if (rgbEnabled)   b = b.rgbSplit(rgbDelta);
  if (bloomEnabled) b = b.bloom(bloomThreshold, bloomBlurSize, bloomSigma);
  if (sobelEnabled) b = b.sobel();

  b.compose();
}

int blendConstFromName(String mode) {
  if (mode == null) return BLEND;

  // switch on strings is fine in Java mode
  switch (mode) {
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

int getBlendModeFromGui() {
  // path is "blendMode/mode" (no need for pushFolder unless you prefer it)
  String mode = gui.radio("blendMode/mode", BLEND_MODE_NAMES, "BLEND");
  return blendConstFromName(mode);
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

void applyFilterFromGui() {
  // Pick filter mode
  String mode = gui.radio("filter/mode", FILTER_MODE_NAMES, "NONE");
  if (mode == null || mode.equals("NONE")) return;

  // Parameters (only used for some modes)
  // Keep these always present; simplest + stable. (You can hide later if you want.)
  float thresholdLevel = gui.slider("filter/thresholdLevel", 0.5f, 0.0f, 1.0f);
  int posterizeLevels  = gui.sliderInt("filter/posterizeLevels", 6, 2, 255);
  float blurRadius     = gui.slider("filter/blurRadius", 1.0f, 0.0f, 20.0f);

  switch (mode) {
    case "THRESHOLD":
      filter(THRESHOLD, thresholdLevel);
      break;

    case "GRAY":
      filter(GRAY);
      break;

    case "OPAQUE":
      filter(OPAQUE);
      break;

    case "INVERT":
      filter(INVERT);
      break;

    case "POSTERIZE":
      filter(POSTERIZE, posterizeLevels);
      break;

    case "BLUR":
      filter(BLUR, blurRadius);
      break;

    case "ERODE":
      filter(ERODE);
      break;

    case "DILATE":
      filter(DILATE);
      break;
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
}


void fileSelected(File selection) {
  if (selection == null) return; // user cancelled :contentReference[oaicite:2]{index=2}

  imgPath = selection.getAbsolutePath();
  PImage loaded = loadImage(imgPath);
  if (loaded == null) {
    println("Failed to load image: " + imgPath);
    return;
  }

  img = loaded;

  // Resize window to match the image dimensions
  // Guard against pathological sizes (optional but pragmatic)
  int w = max(64, img.width);
  int h = max(64, img.height);

  surface.setSize(w, h);
}

String getTemporalName(String prefix, String suffix){
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if(lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}
