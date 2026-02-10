// credit to https://generateme.wordpress.com/2016/04/11/folds/

/*
 Special collaborator
 https://github.com/SebastienBissay/Genuary11
 */


String sketchName = "mySketch";
String saveFormat = ".png";
int calls = 0;
long lastTime;
Texture sampler = Texture.HALTON;
public static final int WIDTH = 2000;
public static final int HEIGHT = 2000;

PGraphics pg;
int outputWidth = 2000; // Higher resolution for saving
int outputHeight = 2000; // Higher resolution for saving

float x1, y1, x2, y2; // Function domain
float step; // Step within domain
float y;

color c1 = #A7C0DB;
color c2 = #63E06E;

void settings() {
  size(WIDTH, HEIGHT, P2D);
  smooth(8);
}


void setup() {
  background(#EFEDE8);

  pg = createGraphics(outputWidth, outputHeight);

  pg.smooth(8);
  pg.beginDraw();
  pg.blendMode(MULTIPLY);
  pg.background(#EFEDE8);

  pg.noFill();

  pg.endDraw();

  // Initialize domain variables
  x1 = y1 = -2;
  x2 = y2 = 2;
  y = y1;

  // Calculate step for drawing variations
  step = sqrt(n) * (x2 - x1) / (2.321 * outputWidth);

  // Draw stipple pattern
  stipple();

  pg.beginDraw();

  pg.strokeWeight(0.4);
  pg.endDraw();
}

boolean go = true;
void draw() {

  if (go) {
    pg.beginDraw();
    for (int i = 0; (i < 40) & go; i++) { // Draw 20 lines at once
      for (float x = x1; x <= x2; x += step) {
        pg.stroke(c1);
        //float n = map(noise(x, y), 0, 1, .0, .5);
        drawVariationFP(pg, x, y);
      }
      y += step;
      if (y > y2) {
        go = false;
        println("done");
        pg.save(getTemporalName(sketchName, saveFormat));
      }
    }
    pg.endDraw();
  }

  // Display the PGraphics on the main window
  image(pg, 0, 0, width, height);
}

void stipple(PGraphics pg, int k, float rad, color col) {
  PoissonDiscSampler sampler = new PoissonDiscSampler(outputWidth, outputHeight);
  ArrayList<PVector> allSamples = sampler.poissonDiskSampling(rad, k);
  pg.beginDraw();
  pg.strokeWeight(0.5);
  pg.stroke(col);
  for (PVector point : allSamples) {
    pg.point(point.x, point.y);
  }
  pg.endDraw();
  println("stippled... whew");
}

int n = 1;
void drawVariationFP(PGraphics pg, float x, float y) {
  PVector v = new PVector(x, y);
  float margin = outputWidth * .95;
  for (int i = 0; i < n; i++) {

    v = subF(rings(leviathan(v, .5), 1.0), disc(julia(v, .5), 1.0));

    //v.set(sinusoidal(v, (x2 - x1) / 2));
    wrap(v);
    float xx = map(v.x + 0.003 * randomGaussian(), x1, x2, margin, outputWidth - margin);
    float yy = map(v.y + 0.003 * randomGaussian(), y1, y2, margin, outputHeight - margin);
    pg.point(xx, yy);
  }
}





void keyReleased() {
  if (key == 's' || key == 'S') {
    pg.save(getTemporalName(sketchName, saveFormat));
  }
}

String getTemporalName(String prefix, String suffix) {
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}
