// credit to https://generateme.wordpress.com/2016/04/11/folds/

/*
 Special collaborator
 https://github.com/SebastienBissay/Genuary11
 */


String sketchName = "mySketch";
String saveFormat = ".png";
int calls = 0;
long lastTime;

WrapMode currentMode = WrapMode.NO_WRAP;
Texture sampler = Texture.HALTON;
public static final int WIDTH = 2000;
public static final int HEIGHT = 2000;

public static final float MIN_X = -3;
public static final float MAX_X = 3;
public static final float MIN_Y = -3;
public static final float MAX_Y = 3;

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
  stipple(pg);
  pg.noFill();

  pg.endDraw();

  // Initialize domain variables
  x1 = y1 = -3;
  x2 = y2 = 3;
  y = y1;

  // Calculate step for drawing variations
  step = sqrt(n) * (x2 - x1) / (2.321 * outputWidth);


  pg.beginDraw();

  pg.strokeWeight(0.4);
  pg.endDraw();
}

boolean go = true;
void draw() {
  background(#FFFFFF);
  if (go) {
    pg.beginDraw();
    pg.stroke(c1);
   
    for (float y = MIN_Y; y <= MAX_Y; y+= step) {
      for (float x = MIN_X; x <= MAX_X; x+=step) {
        drawVariationFP(pg, x, y);  
      }
    }
    println("done");
    go = false;
    pg.endDraw();
    pg.save("out/" + getTemporalName(sketchName, saveFormat));

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

int n = 3;
void drawVariationFP(PGraphics pg, float x, float y) {
  PVector v = new PVector(x, y);
  float margin = outputWidth * .95;
  for (int i = 0; i < n; i++) {

    //v = addF(polar(v, 1.0), julia(horseshoe(v, .5), 1.0));
    //v = julia(addF(popcorn(v, .5), disc(v, .5)), 1.0);
    v = blob(diamond(v, .5), .5);
    currentMode.wrap(v); 
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
