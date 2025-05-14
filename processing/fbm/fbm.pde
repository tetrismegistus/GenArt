/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float z = 0;

OpenSimplexNoise noise = new OpenSimplexNoise();

void setup() {
  size(1500, 1500);
  colorMode(HSB, 360, 100, 100, 1);
  strokeWeight(.5);
}


void draw() {
  background(#E7DFC6);
  color ref = #E7DFC6;
  for (float x = 0; x < width; x++) {
    for (float y = 0; y < height; y++) {
      float n = fbm_warp(x, y, 3, .2, .9);

      float brt = map(n, -1, 1, 75, 100);

      stroke(hue(ref), saturation(ref), brt, 1);
      point(x, y);
      
    }
  }
  
  save(getTemporalName("output/" + sketchName, saveFormat)); 
  noLoop();

}




float fbm_warp(float x, float y, int octaves, float lacunarity, float gain) {
  float warpX = x;
  float warpY = y;

  // Use a simpler fBM to distort the coordinates
  for (int i = 0; i < 4; i++) {
    float dx = (float) noise.eval(warpX * .1, warpY * 0.01, z);
    float dy = (float) noise.eval((warpX  + 100) * 0.005, (warpY + 100) * 0.005, z);
    warpX += dx * 100;
    warpY += dy * 100;
  }

  // Now compute fbm with the warped coordinates
  float sum = 0;
  float amplitude = 1;
  float frequency = 0.1;
  for (int i = 0; i < octaves; i++) {
    float n = (float) noise.eval(warpX * frequency, warpY * frequency, z);
    sum += amplitude * n;
    frequency *= lacunarity;
    amplitude *= gain;
  }
  return sum;
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
