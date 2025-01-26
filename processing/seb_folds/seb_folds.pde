/*
  This is satisfying and I have spent hours implementing and testing a host
  of functions as defined in:
  
  https://flam3.com/flame_draves.pdf
  
  But I'd not even have got that far had I not come across this:
  
  https://generateme.wordpress.com/2016/04/11/folds/
  
  and then Sebastien Bissay provided the abstraction for the dynamic
  formula generation and execution.
  
  https://github.com/SebastienBissay/RandomFormulaGenerator
  
  so this is to say that I have made nothing here, merely put together 
  the parts that were generously made and given away by others. 
*/


String sketchName = "folds";
String saveFormat = ".png";
int calls = 0;
long lastTime;

public static int SEED = 1521561344;
public static final boolean RNDSEED = false;
WrapMode currentMode = WrapMode.SINUSOIDAL_WRAP;
public static final int N = 1;
public static final int WIDTH = 1200;
public static final int HEIGHT = 1200;
public static final int MARGIN = 50;
public static final float MIN_X = -3;
public static final float MAX_X = 3;
public static final float MIN_Y = -3;
public static final float MAX_Y = 3;
public static final float STEP = sqrt(N) * (MAX_X - MIN_X) / (2.321f * WIDTH);
public static final int MINIMUM_VARIATIONS = 2;
public static final int MAXIMUM_VARIATIONS = 6;
public static final float LINEAR_PARAMETER = 1f;
public static final float SINUSOIDAL_PARAMETER = 1f;
public static final float HYPERBOLIC_PARAMETER =1f;
public static final float PDJ_A_PARAMETER = 0.1f;
public static final float PDJ_B_PARAMETER = 1.9f;
public static final float PDJ_C_PARAMETER = 1.4;
public static final float PDJ_D_PARAMETER = TWO_PI;
public static final float PDJ_PARAMETER = 1f;
public static final float DPDJ_PARAMETER = 1f;
public static final float JULIA_PARAMETER = 1f;
public static final float SECH_PARAMETER = 2f;
public static final float BENT_PARAMETER = 1f;
public static final float EX_PARAMETER = 1f;
public static final float DIAMOND_PARAMETER = .5f;
public static final float SPIRAL_PARAMETER = 1f;
public static final float DEJONG_B = 2.71;
public static final float DEJONG_D = -1.05;
public static final float DEJONG_A = -.47;
public static final float DEJONG_C = -0.8;
public static final float DEJONG_PARAMETER = 1f;
public static final float POLAR_PARAMETER = 1f;
public static final float DISC_PARAMETER =1f;
public static final float RECT_PARAMETER = 2f;
public static final float HEART_PARAMETER = 1f;
public static final float SWIRL_PARAMETER = 1f;
public static final float HORSESHOE_PARAMETER = 1;
public static final float POPCORN_C_PARAMETER = .1;
public static final float POPCORN_F_PARAMETER = .09;
public static final float POPCORN_PARAMETER = 1.5f;
public static final float SPHERICAL_PARAMETER = 1f;

static PApplet pApplet;

void settings() {
  pApplet = this;
  size(WIDTH, HEIGHT);
  if (RNDSEED) SEED = floor(random(MAX_INT));

  randomSeed(SEED);
  noiseSeed(floor(random(MAX_INT)));
  smooth(8);
}

void setup() {
  blendMode(MULTIPLY);
  colorMode(HSB, 360, 100, 100, 1);
  background(#EFEDE8);
  noFill();
  stipple(300, 1.5, #ACABA9);
  strokeWeight(.4);
  noLoop();
}

void draw() {
  Formula formula = new Formula(this);
  println(formula.getName());
  println("N = " + N);
  println("seed = " + SEED);
  stroke(#A7C0DB);
  for (float y = MIN_Y; y <= MAX_Y; y += STEP) {
    for (float x = MIN_X; x <= MAX_X; x += STEP) {
        drawVariation(x, y, formula);
    }
  }
  save(getTemporalName(sketchName, saveFormat));
  println("ding");
}


void drawVariation(float x, float y, Formula formula) {
  PVector v = new PVector(x, y);
  for (int j = 0; j < N; j++) {
    v = formula.apply(v);
    currentMode.wrap(v); 
    float xx = map(v.x + 0.003f * randomGaussian(), MIN_X, MAX_X, MARGIN, WIDTH - MARGIN);
    float yy = map(v.y + 0.003f * randomGaussian(), MIN_Y, MAX_Y, MARGIN, HEIGHT - MARGIN);
    point(xx, yy);
  }
}

void wrap(PVector v) {
   PVector newV = sinusoidal(v,(MAX_X -MIN_X)/2);  // this is my wrap logic
   v.x = newV.x;
   v.y = newV.y;
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
