import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

/*
SketchName: crtSim.pde
Credits: sitting too close to the television
Description: drawing tv pixels, big or small
*/

String sketchName = "crtSim";
String saveFormat = ".png";

int calls = 0;
long lastTime;

PImage inImage;

PostFX fx;

void setup() {
  size(1024, 896, P3D);
  fx = new PostFX(this);
  blendMode(SCREEN);
  //colorMode(HSB, 360, 100, 100, 1);
  inImage = loadImage("FF.png");
}


void draw() {
  background(8);

  inImage.loadPixels();
  for (int x = 100; x < 256; x += 1) {
    for (int y = 100; y < 224; y += 1) {
      int idx = x + (y * 256);
      color c = inImage.pixels[idx];
      //strokeWeight(2);
      float r = red(c);; 
      float g = green(c);
      float b = blue(c);
      
      
      drawPixel((x * 40) - 100 * 40, (y * 40) - 100 * 40, 40, r, g, b);
    }
  }
  

    

}


void drawPixel(float x, float y, int sz, float r, float g, float b) {

  float minSig = 11;
  float bandWidth = sz/3;
  r = constrain(r, minSig, 255);
  g = constrain(g, minSig, 255);
  b = constrain(b, minSig, 255);
  strokeWeight(1);
  stroke(r, 0, 0);
  fill(r, 0, 0);
  rect(x, y, bandWidth, sz);  
  stroke(0, g, 0);
  fill(0, g, 0);
  rect(x+bandWidth, y, bandWidth, sz);
  stroke(0, 0, b);
  fill(0, 0, b);
  rect(x+bandWidth + bandWidth , y, bandWidth, sz);

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
