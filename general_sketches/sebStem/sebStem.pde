/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

color[] stemC = {#005f73, #0a9396, #94d2bd};

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
  background(color(#000000));
  float h = hue(#001219);
  float s = saturation(#001219);
  float b = 100;
  for (int y = 0; y < height; y+=5) {
    for (int x = 0; x < width; x+=5) {    
      color bg = color(h,s,b);
      textSquare(x, y, 5, bg);    
      s += .1;
    }
    
    b -= .03;
  }
  
  for (int x = 0; x < width; x++) {
    if (random(1) > .5) {
      blade(x);
    }
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
