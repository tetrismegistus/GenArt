String sketchName = "mySketch";
String saveFormat = ".png";
int calls = 0;
long lastTime;

PGraphics pg;
int outputWidth = 1000; // Higher resolution for saving
int outputHeight = 1000; // Higher resolution for saving

float x1, y1, x2, y2; // Function domain
float step; // Step within domain
float y;


void setup() {
  size(1000, 1000); // Display resolution
  background(#EFEDE8);
  
  pg = createGraphics(outputWidth, outputHeight);
  pg.smooth(8);
  pg.beginDraw();
  pg.background(#EFEDE8);

  pg.noFill();
  pg.blendMode(MULTIPLY);
  pg.endDraw();

  // Initialize domain variables
  x1 = y1 = -3;
  x2 = y2 = 3;
  y = y1;

  // Calculate step for drawing variations
  step = sqrt(n) * (x2 - x1) / (2.321 * outputWidth);

  // Draw stipple pattern
  stipple(pg, 300, 1.5, #ACABA9);
 
  pg.beginDraw();
  pg.stroke(#A7C0DB);
  pg.strokeWeight(0.4);
  pg.endDraw();
}

boolean go = true;
void draw() {
  if (go) {
    pg.beginDraw();
    for (int i = 0; (i < 20) & go; i++) { // Draw 20 lines at once
      for (float x = x1; x <= x2; x += step) {
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

int n = 24;
void drawVariationFP(PGraphics pg, float x, float y) {
  PVector v = new PVector(x, y);
  float margin = outputWidth * .95;
  for (int i = 0; i < n; i++) {
    v =spherical(rectt(popcorn(v, 1.0), 1.0), 1.0);
    float xx = map(v.x + 0.003 * randomGaussian(), x1, x2, margin, outputWidth - margin);
    float yy = map(v.y + 0.003 * randomGaussian(), y1, y2, margin, outputHeight - margin);
    pg.point(xx, yy);
  }
}

void drawVariation(PGraphics pg, float x, float y) {
  PVector v = new PVector(x,y);
  float amount = 1.0;
 
  v = swirl(v, amount);
 
  float xx = map(v.x+0.003*randomGaussian(), x1, x2, 20, width-20);
  float yy = map(v.y+0.003*randomGaussian(), y1, y2, 20, height-20);
  pg.point(xx, yy);
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
