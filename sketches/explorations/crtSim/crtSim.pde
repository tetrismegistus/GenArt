import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

/*
SketchName: crtSim.pde
Credits: sitting too close to the television
Description: drawing tv pixels, big or small
*/

PostFX fx;

String sketchName = "crtSim";
String saveFormat = ".png";

int calls = 0;
long lastTime;

PImage inImage;


void setup() {
  size(3000, 3000, P3D);
  //blendMode(SCREEN);
  fx = new PostFX(this);
  //colorMode(HSB, 360, 100, 100, 1);
  inImage = loadImage("mySketch1770426855759.png");
  

}


void draw() {
  
      background(8);

  inImage.loadPixels();
  float pixelSize = 20;
  for (int x = 0; x < 1500; x += 1) {
    for (int y = 0; y < 1500; y += 1) {
      int idx = x + (y * 1500);
      color c = inImage.pixels[idx];
      //strokeWeight(2);
      float r = red(c);; 
      float g = green(c);
      float b = blue(c);
      
      drawPixel((random(1, 3) + x * pixelSize) - 100 * pixelSize, (random(1, 3) + y * pixelSize) - 100 * pixelSize, (int) pixelSize + (int) random(1, 10), r, g, b);
    }
  }
  

  fx.render()
    .bloom(.1, 10, 20)
    .sobel()
    .compose();

  filter(GRAY);

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
  rect(x, y, sz, bandWidth);  
  stroke(0, g, 0);
  fill(0, g, 0);
  rect(x, y + bandWidth, sz, bandWidth);
  stroke(0, 0, b);
  fill(0, 0, b);
  rect(x, y + bandWidth*2, sz, bandWidth);

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
