void setup () {
  size(2000, 2000);
}

void draw() { 
  background(#FCF5E5);
  int numCircles = int((width * height / 1000000.0) * 3000);
  parchmentTexture(numCircles);
  println("done");
  noLoop();
}


void parchmentTexture(int numCircles) {
  noFill();
  stroke(23, 17, 3, 5);
  float radBase = 200;
  float curveSpread = 100;
  for (int i = 0; i < numCircles; i++) {
    float x = random(width + radBase);
    float y = random(height + radBase);
    float rad = randomGaussian() * curveSpread + radBase;
    circle(x, y, rad);
  }
}

void parchmentTexture2(int numCircles) {
  noFill();
  stroke(23, 17, 3, 5);
  float radBase = 200;
  float curveSpread = 100;
  for (int i = 0; i < numCircles; i++) {
    float x = random(width + radBase);
    float y = random(height + radBase);
    float rad = randomGaussian() * curveSpread + radBase;
    float angle = random(TWO_PI);
    float x1 = x - cos(angle) * rad / 2;
    float y1 = y - sin(angle) * rad / 2;
    float x2 = x + cos(angle) * rad / 2;
    float y2 = y + sin(angle) * rad / 2;
    line(x1, y1, x2, y2);
  }
}
