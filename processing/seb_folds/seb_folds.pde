String sketchName = "folds";
String saveFormat = ".png";
int calls = 0;
long lastTime;

public static final long SEED = 1;
public static final int N = 3;
public static final int WIDTH = 1200;
public static final int HEIGHT = 1200;
public static final int MARGIN = 50;
public static final float MIN_X = -3;
public static final float MAX_X = 3;
public static final float MIN_Y = -3;
public static final float MAX_Y = 3;
public static final float STEP = sqrt(N) * (MAX_X - MIN_X) / (2.321f * WIDTH);
public static final int MINIMUM_VARIATIONS = 3;
public static final int MAXIMUM_VARIATIONS = 5;

public static final float LINEAR_PARAMETER = 1f;
public static final float SINUSOIDAL_PARAMETER = 1f;
public static final float HYPERBOLIC_PARAMETER = 1f;
public static final float PDJ_A_PARAMETER = 0.1f;
public static final float PDJ_B_PARAMETER = 1.9f;
public static final float PDJ_C_PARAMETER = -0.8f;
public static final float PDJ_D_PARAMETER = -1.2f;
public static final float PDJ_PARAMETER = 1f;
public static final float JULIA_PARAMETER = 1f;
public static final float SECH_PARAMETER = 1f;
public static final float BENT_PARAMETER = 1f;
public static final float EX_PARAMETER = 1f;
public static final float DIAMOND_PARAMETER = 1f;
public static final float SPIRAL_PARAMETER = 1f;
public static final float DISC_PARAMETER = 1f;

static PApplet pApplet;

void settings() {
  pApplet = this;
  size(WIDTH, HEIGHT);
  randomSeed(floor(random(MAX_INT)));
  noiseSeed(floor(random(MAX_INT)));
  smooth(8);
}

void setup() {
  blendMode(MULTIPLY);
  colorMode(HSB, 360, 100, 100, 1);
  background(#EFEDE8);
  
  noFill();
  //stipple(300, 1.5, #ACABA9);
  strokeWeight(.4);
  noLoop();
}

void draw() {
  Formula formula = new Formula(this);
  System.out.println(formula.getName());
  stroke(#A7C0DB);
  println("baking");
  for (float y = MIN_Y; y <= MAX_Y; y += STEP) {
    for (float x = MIN_X; x <= MAX_X; x += STEP) {
        drawVariation(x, y, formula);
    }
  }
  save(getTemporalName(sketchName, saveFormat));
  println("ding");
}


void drawVariation(float x, float y, Formula formula) {
  for (int j = 0; j < N; j++) {
    PVector v = new PVector(x, y);
    v = formula.apply(v);
    v = sinusoidal(v,(MAX_X -MIN_X)/2); 
    float xx = map(v.x + 0.003f * randomGaussian(), MIN_X, MAX_X, MARGIN, WIDTH - MARGIN);
    float yy = map(v.y + 0.003f * randomGaussian(), MIN_Y, MAX_Y, MARGIN, HEIGHT - MARGIN);
    point(xx, yy);
  }

}
    


void keyReleased() {
  if (key == 's' || key == 'S') {
    save(getTemporalName(sketchName, saveFormat));
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
