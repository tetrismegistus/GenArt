// FbmWarpSketch.pde
// Fullscreen, P2D, shader-driven + circular offset orbit

import processing.opengl.*;
import com.krab.lazy.LazyGui;

PShader sh;
PGraphics pg;
LazyGui gui;

// uniforms (GUI-driven)
float u_warp_scale, u_warp_freq_x, u_warp_freq_y, u_warp_offset_x, u_warp_offset_y, u_warp_freq_dx, u_warp_freq_dy;
int   u_warp_iterations;
float u_fbm_scale, u_fbm_lacunarity, u_fbm_gain, u_fbm_octaves;
float baseR, baseG, baseB;          // 0..1
float brightMinR, brightMinG, brightMinB;

void settings() {
  fullScreen(P2D);
  smooth(4);
}

void setup() {
  surface.setTitle("FBM Warp — fullscreen");
  sh = loadShader("glsl.frag");              // put your fragment shader in data/glsl.frag
  pg = createGraphics(width, height, P2D);
  gui = new LazyGui(this);

  gui.pushFolder("shader");
  gui.sliderSet("fbm/scale", 100);
  gui.sliderSet("fbm/freq_x", 0.01);
  gui.sliderSet("fbm/freq_y", 0.01);

  gui.sliderSet("fbm/freq_dx", 0.001);
  gui.sliderSet("fbm/freq_dy", 0.001);
  gui.sliderIntSet("fbm/iterations", 4);

  gui.sliderSet("fbm/scale", 1.0);
  gui.sliderSet("fbm/lacunarity", 2.0);
  gui.sliderSet("fbm/gain", 0.5);
  gui.sliderSet("fbm/octaves", 5.0);

  // color picker with default (no setHex)

  gui.sliderSet("fbm/brightMin/r", 0.15);
  gui.sliderSet("fbm/brightMin/g", 0.15);
  gui.sliderSet("fbm/brightMin/b", 0.15);

  // simple circular orbit controls
  gui.pushFolder("orbit");
  gui.toggleSet("enable", true);
  gui.sliderSet("radius", 300);
  gui.sliderSet("speed (rad/s)", 0.4);
  gui.sliderSet("phase", 0.0);
  gui.popFolder();

  gui.popFolder();
}

void draw() {
  background(10);

  // recreate pg if window size changes
  if (pg.width != width || pg.height != height) {
    pg = createGraphics(width, height, P2D);
  }

  // ----------------- GUI → uniforms -----------------
  gui.pushFolder("shader");
  u_warp_scale      = gui.slider("fbm/scale",     100,   0,   500);
  u_warp_freq_x     = gui.slider("fbm/freq_x",    0.01,  0,   0.1);
  u_warp_freq_y     = gui.slider("fbm/freq_y",    0.01,  0,   0.1);
  u_warp_offset_x   = gui.slider("fbm/offset_x",  1000,  0,   5000);
  u_warp_offset_y   = gui.slider("fbm/offset_y",  1000,  0,   5000);
  u_warp_freq_dx    = gui.slider("fbm/freq_dx",   0.001, 0,   0.02);
  u_warp_freq_dy    = gui.slider("fbm/freq_dy",   0.001, 0,   0.02);
  u_warp_iterations = gui.sliderInt("fbm/iterations", 4, 0, 10);

  u_fbm_scale       = gui.slider("fbm/scale",      1.0,   0.01, 10);
  u_fbm_lacunarity  = gui.slider("fbm/lacunarity", 2.0,   1.1,  4);
  u_fbm_gain        = gui.slider("fbm/gain",       0.5,   0.1,  0.9);
  u_fbm_octaves     = gui.slider("fbm/octaves",    5.0,   1,    8);
  if (gui.button("save/export image")) { exportImage(); return; }
  int baseHex = gui.colorPicker("fbm/colorbase", color(255)).hex; // get hex safely
  float[] rgb01 = hexToRGB01(baseHex);
  baseR = rgb01[0]; baseG = rgb01[1]; baseB = rgb01[2];

  brightMinR = gui.slider("brightMin/r", 0.15, 0, 1);
  brightMinG = gui.slider("brightMin/g", 0.15, 0, 1);
  brightMinB = gui.slider("brightMin/b", 0.15, 0, 1);

  // -------- circular orbit for offsets --------
  gui.pushFolder("orbit");
  boolean orbitOn = gui.toggle("enable", true);
  float radius    = gui.slider("radius", 300, 0, 5000);
  float speed     = gui.slider("speed (rad/s)", 0.4, -10, 10);
  float phase     = gui.slider("phase", 0.0, 0, TWO_PI);
  gui.popFolder();
  gui.popFolder();

  float t = millis() / 1000.0;
  float offX = u_warp_offset_x;
  float offY = u_warp_offset_y;
  if (orbitOn) {
    float ang = t * speed + phase;
    offX = u_warp_offset_x + radius * cos(ang);
    offY = u_warp_offset_y + radius * sin(ang);
  }

  // ----------------- push uniforms -----------------
  sh.set("u_time", millis()/1000.0);
  sh.set("u_resolution", (float)width, (float)height);

  sh.set("u_warp_scale", u_warp_scale);
  sh.set("u_warp_freq_x", u_warp_freq_x);
  sh.set("u_warp_freq_y", u_warp_freq_y);
  sh.set("u_warp_offset_x", offX);
  sh.set("u_warp_offset_y", offY);
  sh.set("u_warp_freq_dx", u_warp_freq_dx);
  sh.set("u_warp_freq_dy", u_warp_freq_dy);

  sh.set("u_warp_iterations", u_warp_iterations);
  sh.set("u_fbm_scale", u_fbm_scale);
  sh.set("u_fbm_lacunarity", u_fbm_lacunarity);
  sh.set("u_fbm_gain", u_fbm_gain);
  sh.set("u_fbm_octaves", u_fbm_octaves);

  sh.set("u_baseColor", baseR, baseG, baseB);
  sh.set("u_fbm_bright_min", brightMinR, brightMinG, brightMinB);

  // ----------------- render full-screen -----------------
  pg.beginDraw();
  pg.shader(sh);
  pg.noStroke();
  pg.rectMode(CORNER);
  pg.rect(0, 0, pg.width, pg.height);
  pg.resetShader();
  pg.endDraw();

  imageMode(CORNER);
  image(pg, 0, 0, width, height);

  if (gui.button("export/png")) {
    String name = "out/fbmWarp_" + timestamp() + ".png";
    pg.save(name);
    println("Saved " + name);
  }
}

float[] hexToRGB01(int hex) {
  float r = ((hex >> 16) & 0xFF) / 255.0;
  float g = ((hex >>  8) & 0xFF) / 255.0;
  float b = ((hex      ) & 0xFF) / 255.0;
  return new float[]{r, g, b};
}

void exportImage() {
    String filename = "out/duckforge_" + timestamp() + ".png";
    save(filename);
    println("Saved image to: " + filename);
}


String timestamp() {
  return year()+nf(month(),2)+nf(day(),2)+"_"+nf(hour(),2)+nf(minute(),2)+nf(second(),2);
}
