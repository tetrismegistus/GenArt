import processing.svg.*;

void setup() {
  size(600, 600, SVG, "warpspeed.svg");
  frameRate(10);
}

void draw() {
  
  noFill();
  
  //rotateX(radians(50));
  for (int s = 0; s < width/2; s += 50) {
    drawStar(s);
  }
  //save("test.png");
  println("ding");
  exit();
  
}


void drawStar(float sz) {
  for (int l = 0; l < 360; l += 1) {
    float x = sin(radians(l)) * sz + width/2;
    float y = cos(radians(l)) * sz + height/2;
    pushMatrix();
    translate(x, y);
    rotate(radians(-l));
    line(0, 50, 0,50 + sin(radians(l)) * randomGaussian()*50);
    popMatrix();
  }
}
