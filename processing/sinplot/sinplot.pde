String sketchName = "mySketch";
String saveFormat = ".png";
int calls = 0;
long lastTime;

PImage img;

color[] pal = {#a50104, #590004, #250001, #f3f3f3};

void settings() {
  img = loadImage("signal-2025-07-05-174029.png");  // replace with your image file
  size(img.width, img.height, P2D);
}


void setup() {
  colorMode(HSB, 360, 100, 100, 1);
  background(#EFDDDD);
  noLoop();

}

void draw() {
  noFill();

  img.loadPixels();

  for (int y = 0; y < height; y += 15) {
    strokeWeight(map(y, 0, height, 1.5, 2));

  // Compute position in palette
  float t = map(y, 0, height, pal.length - 1, 0);
  int idx = int(t);
  float lerpAmt = t - idx;
  color c1 = pal[idx];
  color c2 = pal[min(idx + 1, pal.length - 1)];
  
  // Use RGB interpolation to avoid hue distortion
  colorMode(RGB, 255);
  color strokeCol = lerpColor(c1, c2, lerpAmt);
  colorMode(HSB, 360, 100, 100, 1);
  stroke(strokeCol);

    beginShape();
    for (int x = 0; x < width; x++) {
      int index = x + y * width;
      color c = img.pixels[index];
      float satMod = map(brightness(c), 0, 100, 2, 0);
      float ymod = sin(x * satMod) * 5;
      curveVertex(x, y + ymod);
    }
    endShape();
  }

  save(getTemporalName(sketchName, saveFormat));
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
