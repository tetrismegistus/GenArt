int[] alivep = {#E0BBE4, #957DAD, #D291BC, #FEC8D8, #FFDFD3};


void setup() {
  size(900, 900);

}

void draw() {
  background(123);
  float x1 = 0;
  float y1 = 0;
  float x2 = width;
  float y2 = 0;
  float x3 = 0;
  float y3 = height;


  noStroke();
  fill(random(0, 255), 200, 200);
  recurseSub(x1, y1, x2, y2, x3, y3);
  recurseSub(x2, y2, x3, y3, x2, y3);
  save("test.png");
  noLoop();
}

void recurseSub(float x1, float y1, float x2, float y2, float x3, float y3) {
  if (dist(x1, y1, x2, y2) > 11) {
    int choice = int(random(0, alivep.length));
    fill(alivep[choice], random(100, 255));
    triangle(x1, y1, x2, y2, x3, y3);
    float[] next = getSub(x1, y1, x2, y2, x3, y3);    
    recurseSub(next[0], next[1], next[2], next[3], next[4], next[5]);
    //fill(255, 0, 0);
    recurseSub(next[0], next[1], next[4], next[5], x1, y1);
    //recurseSub(next[0], next[1], next[2], next[3], x2, y2);
    //recurseSub(next[2], next[3], next[4], next[5], x3, y3);
  }
}


float[] getSub(float x1, float y1, float x2, float y2, float x3, float y3) {
  float lerpPercent = random(.3, .7);
  x1 += randomGaussian() * 9.8;
  y1 += randomGaussian() * 9.8;
  x2 += randomGaussian() * 9.8;
  y2 += randomGaussian() * 9.8;
  x3 += randomGaussian() * 9.8;
  y3 += randomGaussian() * 9.8;
  float mpx1 = lerp(x1, x2, lerpPercent);
  float mpy1 = lerp(y1, y2, lerpPercent);  

  float mpx2 = lerp(x2, x3, lerpPercent);
  float mpy2 = lerp(y2, y3, lerpPercent);  

  float mpx3 = lerp(x3, x1, lerpPercent);
  float mpy3 = lerp(y3, y1, lerpPercent);
  float[] vertices = {mpx1, mpy1, mpx2, mpy2, mpx3, mpy3};
  return vertices;
}
