/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

String sketchName = "mySketch";
String saveFormat = ".png";
OpenSimplex2S noise;

PGraphics noiseBackground;
PGraphics eBack;

int calls = 0;
long lastTime;

float[][] field;
int acols = 8;
int arows = 8;
int rez = 1;
int cols, rows;
float inc = 0.1;
float zoff = 0.01;

PShader noiseShader;
PShader gradientShader;

float sunTheta = 0;
float moonTheta = PI;

PVector[] sunSpots = new PVector[5000];
PVector[] moonSpots = new PVector[1000];
ArrayList<Float> spokeDeltas = new ArrayList<>();

void setup() {
  size(1000, 1000, P2D);
  long seed = (long) random(0, 10293801);
  noise = new OpenSimplex2S((long) seed);
  //colorMode(HSB, 360, 100, 100, 1);
  int awidth = width/3;
  int aheight = height/3;
  cols= 1 + awidth / rez;
  rows = 1 + aheight /rez;
  noiseShader = loadShader("shader.frag");
  gradientShader = loadShader("gradientShader.frag");
  //noLoop();
  smooth();
  drawNoiseBackground();   
  
  drawEarthBackground();
  
  // set the random adjustments for the sun's rays
  int i = 0;
  for (float theta = 0; theta < TWO_PI; theta += radians(3)) {
    float t = radians(random(-.5, .5));
    spokeDeltas.add(i, theta);
    i++;    
  }
    
  // set the positions for the sunspots;  
  for (int s = 0; s < 5000; s++) {
    PVector rp = rndUCircPoint(pow(random(1), .13));
    sunSpots[s] = rp;        
  }
    
  for (int s = 0; s < 1000; s++) {
    PVector rp = rndUCircPoint(sqrt(random(0, 1)));
    moonSpots[s] = rp;
  }
  
}


void draw() {
  background(#b6b6b6);
  
  noFill();
  stroke(0);
  image(noiseBackground, 0, 0);
  PVector sun = drawSun();    
  drawMoon();  
  drawEarth(sun);   
  //eBack.filter(gradientShader);
  
  //save(getTemporalName(sketchName, saveFormat));
  sunTheta +=  radians(1);
  moonTheta -= radians(1);
  filter(noiseShader);
  saveFrame("output/####.png");
  if (sunTheta >= TWO_PI)
    noLoop();
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
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



void line(PVector v1, PVector v2, PGraphics pg) {
  pg.line(v1.x, v1.y, v2.x, v2.y);
  
}

float getState(float a, float b, float c, float d) {
  return a * 8 + b * 4 + c * 2 + d * 1;
}

float getNoise(float xoff, float yoff, int octaves, double zoom){  
  double total = 0;
  double frequency = 1;
  double amplitude = 1;
  double maxValue = 0;  
  double persistence = .9;    
      
  for (int i=0; i < octaves; i ++){
    total += noise.noise3_Classic((xoff *  frequency) * zoom, (yoff *  frequency) * zoom, zoff * frequency * zoom) * amplitude;
    maxValue += amplitude;
    amplitude *= persistence;
    frequency *= 2;      
  }
  return (float) total;
  
}


PVector rndUCircPoint(float r) {    
    float theta = random(TWO_PI);
    float x = r * cos(theta);
    float y = r * sin(theta);
    return new PVector(x, y);    
}
