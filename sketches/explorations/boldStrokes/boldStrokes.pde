/*
SketchName: boldStrokes.pde
Credits: postfx, lazygui
Description: thick stroke + painted inner strokes (simple usage)
*/

import java.util.List;

String sketchName = "mySketch";
String saveFormat = ".png";

int WIDTH = 1500;
int HEIGHT = 1500;
int calls = 0;
long lastTime;

int NUM_STRIPES = 30;          // how many horizontal bands
float JITTER_Y = 8;            // vertical wobble amplitude (px, in pg space)

int NUM_BUILDINGS = 80;        // vertical strokes
float BUILDING_MAX_H_FRAC = 0.32; // variety (up to ~1/3 of canvas height)
float BUILDING_W_MIN = 60;     // variety (narrower min)
float BUILDING_W_MAX = 320;    // variety (wider max)
float BUILDING_X_JITTER = 8;   // slight x wobble
float BUILDING_Y_JITTER = 6;   // slight y wobble

// only buildings taller than this fraction of maxH get windows
float TALL_WINDOW_THRESHOLD_FRAC = 0.65;  // tweak: 0.55..0.8

final int SS = 2;              // supersample factor
PGraphics pg;                  // offscreen render target

ArrayList<ThickStroke> stripes = new ArrayList<>();

class Building {
  ThickStroke body;
  ArrayList<ThickStroke> windows = new ArrayList<>();
  Building(ThickStroke body) { this.body = body; }
}
ArrayList<Building> buildingLayers = new ArrayList<>();

color[] p = {
  #210124, #4b072e, #750d37, #94767c, #b3dec1, #c7ecd9, #dbf9f0, #e9f9f4
};

final int BUILDING_COL = #210124;
final int WINDOW_COL   = #DBF9F0;

void settings() {
  size(WIDTH, HEIGHT, P2D);
}

void setup() {
  colorMode(HSB, 360, 100, 100, 1);

  // offscreen buffer at 2x resolution
  pg = createGraphics(WIDTH * SS, HEIGHT * SS, P2D);
  pg.colorMode(HSB, 360, 100, 100, 1);

  stripes.clear();
  buildingLayers.clear();

  // ----------------------------
  // Horizontal stripes (background)
  // ----------------------------
  float top = 0;
  float bot = pg.height;
  float span = bot - top;
  float dy = span / max(1, (NUM_STRIPES - 1));

  int ptsPerStripe = max(8, pg.width / 40);
  float dx = pg.width / float(ptsPerStripe - 1);

  for (int s = 0; s < NUM_STRIPES; s++) {
    float yBase = top + s * dy;

    ArrayList<PVector> line = new ArrayList<>();
    float yNoiseSeed = random(10000);

    for (int i = 0; i < ptsPerStripe; i++) {
      float x = i * dx;
      float wobble = map(noise(yNoiseSeed, i * 0.15f), 0, 1, -JITTER_Y, JITTER_Y);
      float y = yBase + wobble;
      line.add(new PVector(x, y));
    }

    int steps = ptsPerStripe;
    float waves = steps * 0.02f;

    float strokeW = random(80, 260);
    float paintMin = strokeW * random(0.04, 0.12);
    float paintMax = strokeW * random(0.18, 0.45);

    ThickStroke ts = new ThickStroke(line, strokeW, new SineMul(0.10, waves, 0.2))
      .paintInside(80, paintMin, paintMax, 0.10, 0.55, new SineMul(0.10, waves, 0.2));

    stripes.add(ts);
  }

  // ----------------------------
  // Buildings (+ windows only if very tall)
  // ----------------------------
  int ptsPerBuilding = 10;
  float maxH = pg.height * BUILDING_MAX_H_FRAC;
  float groundY = pg.height;
  float tallH = maxH * TALL_WINDOW_THRESHOLD_FRAC;

  for (int b = 0; b < NUM_BUILDINGS; b++) {
    float xBase = random(pg.width);

    // height variety (biased shorter with occasional tall)
    float h = maxH * pow(random(1), 1.8);
    h = constrain(h, maxH * 0.10f, maxH);
    float yTop = groundY - h;

    ArrayList<PVector> line = new ArrayList<>();
    float xSeed = random(10000);
    float ySeed = random(10000);

    for (int i = 0; i < ptsPerBuilding; i++) {
      float t = i / float(ptsPerBuilding - 1);
      float y = lerp(groundY, yTop, t)
              + map(noise(ySeed, i * 0.25f), 0, 1, -BUILDING_Y_JITTER, BUILDING_Y_JITTER);
      float x = xBase
              + map(noise(xSeed, i * 0.25f), 0, 1, -BUILDING_X_JITTER, BUILDING_X_JITTER);
      line.add(new PVector(x, y));
    }

    // width variety (biased narrower with occasional wide)
    float strokeW = lerp(BUILDING_W_MIN, BUILDING_W_MAX, pow(random(1), 1.6));

    float paintMin = strokeW * random(0.02f, 0.06f);
    float paintMax = strokeW * random(0.08f, 0.18f);

    ThickStroke body = new ThickStroke(line, strokeW, new NoiseMul(0.08f, 0.01f))
      .paintInside(40, paintMin, paintMax, 0.12f, 0.55f, new NoiseMul(0.16f, 0.03f));

    Building bb = new Building(body);

    // windows ONLY if very tall
    if (h >= tallH) {
      int colsWin = (strokeW < 120) ? 2 : (strokeW < 220) ? 3 : 4;
      float halfW = strokeW * 0.5f;

      float padX = max(6, strokeW * 0.08f);
      float padY = max(10, h * 0.1f);

      float usableW = max(10, strokeW - 2 * padX);
      float usableH = max(10, h - 2 * padY);

      float colStep = usableW / colsWin;

      float winW = min(colStep * 0.45f, strokeW * 0.18f);
      float winH = max(10, min(h * 0.04f, 28));
      float rowGap = winH * 0.9f + random(2, 10);

      int rowsWin = max(2, (int)(usableH / rowGap));

      for (int rr = 0; rr < rowsWin; rr++) {
        float yCenter = yTop + padY + rr * rowGap;
        if (yCenter + winH * 0.5f > groundY - padY) break;

        for (int cc = 0; cc < colsWin; cc++) {
          float xCenter = (xBase - halfW + padX) + (cc + 0.5f) * colStep;

          float xJ = random(-colStep * 0.05f, colStep * 0.05f);
          float yJ = random(-winH * 0.1f, winH * 0.1f);

          float xC = xCenter + xJ;
          float yC = yCenter + yJ;

          ArrayList<PVector> wline = new ArrayList<>();
          wline.add(new PVector(xC, yC - winH * 0.5f));
          wline.add(new PVector(xC, yC + winH * 0.5f));

          float wStroke = max(3, min(winW, strokeW * 0.18f));
          bb.windows.add(new ThickStroke(wline, wStroke, new ConstMul()));
        }
      }
    }

    buildingLayers.add(bb);
  }
}

void draw() {
  pg.beginDraw();
  pg.background(#F7F9F7);

  // stripes
  int pidx = 0;
  for (ThickStroke s : stripes) {
    s.render(pg, p[min(pidx, p.length - 1)]);
    pidx++;
  }

  // buildings + windows (painter's algorithm per-building)
  for (Building bb : buildingLayers) {
    bb.body.render(pg, BUILDING_COL);
    for (ThickStroke w : bb.windows) {
      w.render(pg, WINDOW_COL);
    }
  }

  pg.endDraw();

  background(#F7F9F7);
  image(pg, 0, 0, WIDTH, HEIGHT);

  save("out/" + getTemporalName(sketchName, saveFormat));
  noLoop();
}

void keyReleased() {
  if (key == 's' || key == 'S') pg.save("out/" + getTemporalName(sketchName, saveFormat));
}

String getTemporalName(String prefix, String suffix){
  long time = System.currentTimeMillis();
  if(lastTime == time) calls++;
  else { lastTime = time; calls = 0; }
  return prefix + time + (calls>0 ? "-" + calls : "") + suffix;
}
