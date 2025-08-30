import com.krab.lazy.*;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float off = 0.01;   // spatial scale for field sampling
float PL  = 2;      // contour march step length

float border = .5;  // current iso target at seed
float ix, iy;

PShader sh;
LazyGui gui;
OpenSimplexNoise noise;

PGraphics pgPreview;   // downsampled paper shader preview
PGraphics mapLayer;    // cached map layer (built once)
boolean mapBuilt = false;

// fBM toggle (press F or use GUI)
boolean fbmEnabled = true;

// 1) final/world size for shader continuity (preview is downsampled)
int TARGET_W = 1500, TARGET_H = 1500;
int DS = 3; // preview downsample factor (preview buffer = TARGET/DS)

// paper color controls (0..1)
float baseR, baseG, baseB;
float brightMinR, brightMinG, brightMinB;

// shader uniforms
float u_warp_scale, u_warp_freq_x, u_warp_freq_y, u_warp_offset_x, u_warp_offset_y, u_warp_freq_dx, u_warp_freq_dy;
int   u_warp_iterations;
float u_fbm_scale, u_fbm_lacunarity, u_fbm_gain;
int   u_fbm_octaves;

// ---- fBM params for contours (you can tweak) ----
int   FBM_OCTAVES    = 3;
float FBM_LACUNARITY = 0.2;
float FBM_GAIN       = 0.9;

void setup() {
  size(1000, 1000, P2D);
  colorMode(HSB, 360, 100, 100, 1);

  gui = new LazyGui(this);
  noise = new OpenSimplexNoise((long) random(0, 255));

  // shader + preview buffer
  sh = loadShader("glsl.frag");
  pgPreview = createGraphics(TARGET_W/DS, TARGET_H/DS, P2D);
  pgPreview.noSmooth();

  // cached map layer matches the window size
  mapLayer = createGraphics(width, height, P2D);
  mapLayer.noSmooth();

  // --- paper ---
  gui.pushFolder("paper");
  gui.colorPicker("baseColor", color(255));
  gui.sliderSet("brightMin/r", 0.15);
  gui.sliderSet("brightMin/g", 0.15);
  gui.sliderSet("brightMin/b", 0.15);
  gui.popFolder();

  // --- warp ---
  gui.pushFolder("warp");
  gui.sliderSet("scale",     100);
  gui.sliderSet("freq_x",    0.01);
  gui.sliderSet("freq_y",    0.01);
  gui.sliderSet("offset_x",  1000);
  gui.sliderSet("offset_y",  1000);
  gui.sliderSet("freq_dx",   0.001);
  gui.sliderSet("freq_dy",   0.001);
  gui.sliderIntSet("iterations", 4);
  gui.popFolder();

  gui.pushFolder("fbm");
  gui.toggleSet("enabled", true);   // the actual fbm on/off switch
  gui.button("rebuild_now");        // one-shot button
  gui.sliderSet("scale",       1.0);
  gui.sliderSet("lacunarity",  2.0);
  gui.sliderSet("gain",        0.5);
  gui.sliderIntSet("octaves",  5);
  gui.popFolder();

}

void draw() {
  // 1) PAPER SHADER PREVIEW (downsampled)
  renderShaderPreview();

  // draw the preview behind everything
  background(0);
  image(pgPreview, 0, 0, width, height);

  // 2) MAP LAYER (build once, then blit)
  if (!mapBuilt) buildMapLayer(mapLayer);
  image(mapLayer, 0, 0);
}

// -----------------------------------------------------------------------------
// Build the expensive map layer ONCE into the provided PGraphics
// -----------------------------------------------------------------------------
void buildMapLayer(PGraphics g) {
  g.beginDraw();
  g.colorMode(HSB, 360, 100, 100, 1);

  println("parachutes");
  for (int i = 50; i < g.width - 50; i += 10) {
    dropAgent(g, random(g.width), random(g.height));
  }
  println("deployed");

  // margins
  g.fill(#E0E1E4); g.noStroke();
  g.rect(0, 0, g.width, 50);
  g.rect(0, g.height - 50, g.width, 50);
  g.rect(0, 0, 50, g.height);
  g.rect(g.width - 50, 0, 50, g.height);

  // grid (draftsman outlines)
  g.noFill();
  for (int x = 50; x < g.width - 50; x += 50) {
    for (int y = 50; y < g.height - 50; y += 50) {
      rectOutline(g, x, y, 50, 50, color(0, 0, 0));
    }
  }

  // labels
  g.textSize(10); g.fill(0);
  int degreesLabel = (int) random(70);
  for (int x = 50; x < g.width - 50; x += 50) g.text(degreesLabel++ + "°", x, 48);

  degreesLabel = (int) random(70);
  g.pushMatrix(); g.translate(47, 950); g.rotate(radians(270));
  for (int x = 0; x < 900; x += 50) g.text(degreesLabel++ + "°", x, 0);
  g.popMatrix();

  // corner tick borders (with jitter)
  g.pushMatrix(); g.translate(50, 50);             drawBorder(g); g.popMatrix();
  g.pushMatrix(); g.translate(50, g.height - 50);  drawBorder(g); g.popMatrix();
  g.pushMatrix(); g.translate(50, 50);             g.rotate(radians(90)); drawBorder(g); g.popMatrix();
  g.pushMatrix(); g.translate(g.width - 50, 50);   g.rotate(radians(90)); drawBorder(g); g.popMatrix();

  g.endDraw();
  mapBuilt = true;
}

// -----------------------------------------------------------------------------
// Preview pass: reads GUI, updates uniforms, draws shader to pgPreview
// -----------------------------------------------------------------------------
void renderShaderPreview() {
  pgPreview.beginDraw();
  pgPreview.background(#c2f2f2);

  // ---- PAPER ----
  gui.pushFolder("paper");
  int baseHex = gui.colorPicker("baseColor", color(255)).hex;
  float[] rgb01 = hexToRGB01(baseHex);
  baseR = rgb01[0]; baseG = rgb01[1]; baseB = rgb01[2];
  brightMinR = gui.slider("brightMin/r", 0.15);
  brightMinG = gui.slider("brightMin/g", 0.15);
  brightMinB = gui.slider("brightMin/b", 0.15);
  gui.popFolder();

  // ---- WARP ----
  gui.pushFolder("warp");
  u_warp_scale      = gui.slider("scale",     u_warp_scale);
  u_warp_freq_x     = gui.slider("freq_x",    u_warp_freq_x);
  u_warp_freq_y     = gui.slider("freq_y",    u_warp_freq_y);
  u_warp_offset_x   = gui.slider("offset_x",  u_warp_offset_x);
  u_warp_offset_y   = gui.slider("offset_y",  u_warp_offset_y);
  u_warp_freq_dx    = gui.slider("freq_dx",   u_warp_freq_dx);
  u_warp_freq_dy    = gui.slider("freq_dy",   u_warp_freq_dy);
  u_warp_iterations = gui.sliderInt("iterations", u_warp_iterations);
  gui.popFolder();

  // ---- fBM (keep state; rebuild only on demand) ----
  // inside renderShaderPreview()
  gui.pushFolder("fbm");
  
  // keep GUI and variable in sync
  boolean prev = fbmEnabled;
  boolean now  = gui.toggle("enabled", prev);
  if (now != prev) {
    fbmEnabled = now; 
    gui.toggleSet("enabled", fbmEnabled); // avoid snapback
  }
  
  // one-shot rebuild button
  if (gui.button("rebuild_now")) {
    mapBuilt = false;
  }
  
  u_fbm_scale      = gui.slider("scale",      u_fbm_scale);
  u_fbm_lacunarity = gui.slider("lacunarity", u_fbm_lacunarity);
  u_fbm_gain       = gui.slider("gain",       u_fbm_gain);
  u_fbm_octaves    = gui.sliderInt("octaves", u_fbm_octaves);
  
  gui.popFolder();




  // ---- Shader uniforms ----
  if (sh != null) {
    sh.set("u_time", millis()/1000.0);
    sh.set("u_resolution", (float)TARGET_W, (float)TARGET_H);

    sh.set("u_warp_scale", u_warp_scale);
    sh.set("u_warp_freq_x", u_warp_freq_x);
    sh.set("u_warp_freq_y", u_warp_freq_y);
    sh.set("u_warp_offset_x", u_warp_offset_x);
    sh.set("u_warp_offset_y", u_warp_offset_y);
    sh.set("u_warp_freq_dx", u_warp_freq_dx);
    sh.set("u_warp_freq_dy", u_warp_freq_dy);
    sh.set("u_warp_iterations", (float)u_warp_iterations);

    sh.set("u_fbm_scale", u_fbm_scale);
    sh.set("u_fbm_lacunarity", u_fbm_lacunarity);
    sh.set("u_fbm_gain", u_fbm_gain);
    sh.set("u_fbm_octaves", (float)u_fbm_octaves);

    sh.set("u_baseColor", baseR, baseG, baseB);
    sh.set("u_fbm_bright_min", brightMinR, brightMinG, brightMinB);

    pgPreview.shader(sh);
    pgPreview.noStroke();
    pgPreview.rect(0, 0, pgPreview.width, pgPreview.height);
    pgPreview.resetShader();
  }
  pgPreview.endDraw();
}

// -----------------------------------------------------------------------------
// Toggle helper (used by key press). This one DOES rebuild.
// -----------------------------------------------------------------------------
// toggle helper
void setFbmEnabled(boolean val) {
  fbmEnabled = val;
  gui.pushFolder("fbm");
  gui.toggleSet("enabled", fbmEnabled);
  gui.popFolder();
  mapBuilt = false;              // flipping via key should rebuild
  println("fBM " + (fbmEnabled ? "ENABLED" : "DISABLED"));
}


// -----------------------------------------------------------------------------
// Border ticks (jittered), now writing into PGraphics
// -----------------------------------------------------------------------------
void drawBorder(PGraphics g) {
  for (int x = 0; x < g.width - 100; x += 50) {
    for (int i = 0; i < 3; i++) {
      float jx  = x + randomGaussian();
      float jy  = randomGaussian();
      rectOutline(g, jx, jy, 25, 2, #12776d);

      float jx2 = (x + 25) + randomGaussian() * 2;
      float jy2 = randomGaussian();
      rectOutline(g, jx2, jy2, 25, 2, 0);
    }
  }
}

// -----------------------------------------------------------------------------
// Agent drop + contour marching — now rendering into PGraphics
// -----------------------------------------------------------------------------
void dropAgent(PGraphics g, float x, float y) {
  float agentX = x;
  float agentY = y;

  float ISO = 0.5;
  while (fbm01(agentX * off, agentY * off) < ISO - 0.01 && noContourNear(g, agentX, agentY)) {
    agentY--;
    if (agentY <= 50) break;
  }

  g.fill(#f5f3dc);
  g.strokeWeight(.1);
  if (noContourNear(g, agentX, agentY)) {
    g.stroke(#ad776d);
    renderContour(g, agentX, agentY);
  }

  // vertical trace using g.pixels
  g.noFill();
  g.loadPixels();
  float lastY = agentY;
  for (float ny = agentY; ny > 50; ny--) {
    int ixp = (int) agentX;
    int iyp = (int) ny;
    if (ixp < 0 || ixp >= g.width || iyp < 0 || iyp >= g.height) continue;
    int idx = ixp + iyp * g.width;
    if (g.pixels[idx] == #f5f3dc && noContourNear(g, agentX, ny)) {
      lastY = ny;
    } else {
      draftsmanLine(g, agentX, lastY, agentX, ny, color(0, 0, 0));
      lastY = ny;
    }
  }
}

boolean noContourNear(PGraphics g, float x, float y) {
  boolean valid = true;
  g.loadPixels();
  for (int j = 1; j < 15; j++) {
    for (int nA = 0; nA < 360; nA += 1) {
      float nX = j * cos(radians(nA)) + x;
      float nY = j * sin(radians(nA)) + y;
      int ixp = (int) nX, iyp = (int) nY;
      if (ixp < 0 || ixp >= g.width || iyp < 0 || iyp >= g.height) continue;
      int idx = ixp + iyp * g.width;
      if (g.pixels[idx] == #ad776d) { valid = false; break; }
    }
    if (!valid) break;
  }
  return valid;
}

void renderContour(PGraphics g, float nx, float ny) {
  ix = nx;
  iy = ny;

  border = fbm01(ix * off, iy * off);

  float d  = 0;
  float sx = ix, sy = iy;

  for (int i = 0; i < 50000; i++) {
    float od = d;
    float ox = ix, oy = iy;

    // angular search for next point on iso-contour
    for (d = od + HALF_PI; (d > od - HALF_PI && !nn()) || d == od + HALF_PI; d -= .17) {
      ix = ox + PL * cos(d);
      iy = oy - PL * sin(d);
    }

    draftsmanLine(g, ox, oy, ix, iy, color(#08220d));

    if (dist(ix, iy, sx, sy) < PL && i > 1) {
      if (i > 4) draftsmanLine(g, ix, iy, sx, sy, color(#08220d)); // close loop
      break;
    }
  }

}


// -----------------------------------------------------------------------------
// Misc
// -----------------------------------------------------------------------------
void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));

  // in keyReleased()
  if (key == 'f' || key == 'F') {
    setFbmEnabled(!fbmEnabled);   // this flips state AND rebuilds
  }
  
  if (key == 'r' || key == 'R') {
    mapBuilt = false;             // manual rebuild shortcut
  }


}

String getTemporalName(String prefix, String suffix) {
  long time = System.currentTimeMillis();
  if (lastTime == time) { calls++; } else { lastTime = time; calls = 0; }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}

boolean nn() {
  // compare normalized field at current point to the seed iso-value “border”
  return abs(fbm01(ix * off, iy * off) - border) < 0.02;
}

/* -------------------------
   Helpers
   ------------------------- */

// geometric amplitude sum for classic fBM
float amplitudeSum(int octaves, float gain) {
  if (abs(gain - 1.0) < 1e-9) return octaves; // edge case
  return (1.0 - pow(gain, octaves)) / (1.0 - gain);
}

// Field mapped to [0,1]; uses fBM when enabled, else plain OpenSimplex
float fbm01(float x, float y) {
  if (!fbmEnabled) {
    float n = (float) noise.eval(x, y, 0.0);
    return n * 0.5f + 0.5f;
  }
  float raw = fbm_warp(x, y, FBM_OCTAVES, FBM_LACUNARITY, FBM_GAIN);
  float A = amplitudeSum(FBM_OCTAVES, FBM_GAIN);
  return constrain(raw / (2.0*A) + 0.5, 0, 1);  // [-A,+A] -> [0,1]
}

float[] hexToRGB01(int hex) {
  float r = ((hex >> 16) & 0xFF) / 255.0;
  float g = ((hex >>  8) & 0xFF) / 255.0;
  float b = ((hex      ) & 0xFF) / 255.0;
  return new float[]{r, g, b};
}
