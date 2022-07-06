void setup() {
  size(800, 800);
  colorMode(HSB);
}

void draw() {
  background(255, 100, 250);
  polymoire(width/4, height/4, width/5, 28);
  rectmoire((width - width/4) - width/5, height/4 - height/6, width/3, height/3);
  sinmoire((width/4) - width/5, height - height/4 - height/6, width/3, height/3);
  npolymoire((width - width/4), height - height/4, width/5, 6);
  save("test.png");
  noLoop();
  
}


void polymoire(float x, float y, float rad, int sides) {
  pushMatrix();
  translate(x, y);
  noFill();
  stroke(180, random(100, 255), 200);
  for (int r = 0; r < rad; r += 2) {
    polygon(0, 0, r, sides);
  }
  float r = radians(3);
  rotate(r);
  stroke(195, 200, 250);

  for (int row = 0; row < rad; row += 2) {
    polygon(0, 0, row, sides);
  }


  popMatrix();
  
}


void npolymoire(float x, float y, float rad, int sides) {
  pushMatrix();
  translate(x, y);
  noFill();
  stroke(180, random(100, 255), 200);
  for (int r = 0; r < rad; r += 2) {
    polygon(0, 0, r, sides);
  }
  
  stroke(195, 200, 250);

  for (int row = 0; row < rad; row += 2) {
    pushMatrix();
    float r = radians(random(1, 10));
    rotate(r);
    polygon(0, 0, row, sides);
    popMatrix();
  }


  popMatrix();
  
}




void rectmoire(float x, float y, float w, float h) {
  pushMatrix();
  translate(x, y);
  stroke(180, random(100, 255), 200);
  for (int r = 0; r < h; r += 3) {
    line(0, r, w, r);
  }
  float r = radians(random(1, 3));
  rotate(r);
  stroke(195, 200, 250);

  for (int row = 0; row < h; row += 2) {
    line(0, row, w, row);
  }
  
  rotate(r);
  stroke(170, 200, 250);

  for (int row = 0; row < h; row += 2) {
    line(0, row, w, row);
  }
  popMatrix();
  
}


void sinmoire(float x, float y, float w, float h) {
  pushMatrix();
  translate(x, y);
  stroke(180, random(100, 255), 200);
  for (int r = 0; r < h; r += 5) {
    line(0, r, w, r, 3);
  }
  float r = radians(2);
  rotate(r);
  stroke(195, 200, 250);

  for (int row = 0; row < h; row += 3) {
    line(0, row, w, row, 3);
  }
  
  rotate(r);
  stroke(170, 200, 250);
  for (int row = 0; row < h; row += 8) {
    line(0, row, w, row, 3);
  }

  popMatrix();
  
}


void line(float x1, float y1, float x2, float y2, float alt) {
  beginShape();
  float yl = 0;
  for (float i= x1; i <= x2; i+=alt) {
    float yp = lerp(y1, y2, yl);
    curveVertex(i, yp + sin(i) * 5);
    yl += .01;
  }
  endShape();
  
}




void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
