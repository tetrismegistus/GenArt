/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

int[] morning = {#B86B77, #EABFB9, #F6CFCA, #FFE8E5, #F3C3D9, #97D5DB};

OpenSimplexNoise noise;

void setup() {
  size(675, 1200);
  colorMode(HSB, 360, 100, 100, 1);
  noise = new OpenSimplexNoise((long) random(1000000000));
  
  
}


void draw() {
  int backgroundIdx = (int) random(0, morning.length);
  background(morning[backgroundIdx]);
  noStroke();
  float h = 204;
  float s = 20;
  float b = 95;
  
  float mh = hue(morning[backgroundIdx]);
  float ms = saturation(morning[backgroundIdx]);
  float mb = brightness(morning[backgroundIdx]);
  ms -= 5;
  mb += 10;
  float sunRad = random(100, 300);
  float theta = radians(random(225, 315));
  float sr = random(600, 1200);
  float sx = width/2 + cos(theta) * sr; 
  float sy = height + sin(theta) * sr;
  fill(mh, ms, mb);
  float dayNight = random(1);
  float k = random(0, 50);
  if (dayNight > .5) {
    circle(sx, sy, sunRad);
  } else {
    pushMatrix();
    translate(sx, sy);
    rotate(-PI/2);
    
    arc(0, 0, sunRad, sunRad, 0, PI*4);
    fill(morning[backgroundIdx]);
    k=k+5;
    arc(k, k, sunRad, sunRad, 0, PI*4);
    popMatrix();
  }
  
  int y = height/2;
  for (int i = 0; i < 20; i++) {
    fill(h, s, b);  
    PerlinPeaks(0, y, .005, width, height/2, 10, 30);
    s -= 1;
    b -= 10;
    fill(h, s, b);
    y+=80;
   
  }
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

void PerlinPeaks(int x1, int y1, float inc, int w, int h, int octaves, int variance) {  
  noiseDetail(octaves);
  float xoff = x1;
  float yoff = y1;
  beginShape();
  for (int x = x1; x <= x1 + w; x ++) {    
    float y = map((float)noise.eval(xoff, y1), 0, 1, y1+variance, y1-variance);
    vertex(x, y);
    xoff += inc;
    yoff += inc;
  }
  vertex(x1 + w, y1 + h);
  vertex(x1, y1 + h);
  vertex(x1, map(noise(0), 0, 1, y1+variance, y1-variance));
  endShape();
}
