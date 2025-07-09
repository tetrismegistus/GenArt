/*
SketchName: circleBrushExperiment.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

String sketchName = "circleBrushExperiment";
String saveFormat = ".png";

int calls = 0;
long lastTime;

color[] budC = {#9b5de5, #f15bb5, #fee440, #00bbf9, #00f5d4};


void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
  background(#000000);
  ArrayList<Circle> CIRCLES = new ArrayList<Circle>();
  CIRCLES = PackCircles(1000000, CIRCLES);        
  for (Circle c : CIRCLES) {    
    noStroke();
    fill(#FFFFFF);
    c.render();
  } 
  
  
  
  PImage mask = createImage(width, height, RGB);
  mask.loadPixels();
  loadPixels();
  for (int i = 0; i < mask.pixels.length; i++) {
    mask.pixels[i] = pixels[i];
  }
  mask.updatePixels();
  

  background(#000000);
  ArrayList<Circle2> CIRCLES1 = new ArrayList<Circle2>();
  CIRCLES1 = PackCircles2(500000, CIRCLES1);          
  
  for (Circle2 c : CIRCLES1) {    
    noStroke();    
    c.render();
  } 
  
  PImage img = createImage(width, height, RGB);
  img.loadPixels();
  loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = pixels[i];
  }
  img.updatePixels();
    
  background(#000000);
 
  
  
  img.mask(mask);
  
  image(img, 0, 0);
 
  print("done");
  save(getTemporalName(sketchName, saveFormat));
  noLoop();
}

void textCircle(float rad, float cx, float cy, color c) {
  int cap = ((int) rad * (int) rad) * 4;
  
  for (int i = 0; i < 2000; i++) {
    float brad = constrain(rad/10, 3, rad/10);
    Brush brush = new Brush(brad, width/2, height/2, #000000);
    float hue = hue(c);
    float sat = saturation(c) + random(-20, 20);
    float brt = brightness(c) + random(-20, 20);    
    brush.col = color(hue, sat, brt);    
    float r = rad * sqrt(random(0, 1));
    float theta = random(0, 1) * 2 * PI;
    float x = r * cos(theta) + randomGaussian();
    float y = r * sin(theta) + randomGaussian();
    brush.cx = x + cx;
    brush.cy = y + cy;
    brush.render();
  }
  
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
