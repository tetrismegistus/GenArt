import processing.svg.*;

color[] pal = new color[] {
  #B55239,
  #221E11,
  #7DB295,
  #603A2B,
  #DEDEDA,
};

float[] seq = {.8, .5, .3, .2, .1};

void setup() {
  size(400, 400, SVG, "logo.svg");
  noFill();
  noStroke();
}

void draw() {
  float baseDiameter = 400 * .95;
  float beamWidth = (baseDiameter * seq[4]) / 2.0;
  float x = width / 2;
  float y = height / 2;
  rectMode(CORNER);  

  
  // Draw circles
  for (int i = 0; i < 5; i++) {
    fill(pal[i]);
    circle(x, y, baseDiameter * seq[i]);
  }
 
  float radius = baseDiameter * seq[0] / 2; 
  float rectWidth = radius;  
  float rectX = x + (radius - rectWidth) / 2;  
  float beamCurvedMod = .01;

  PVector arcStart = new PVector(x + radius, y - beamWidth / 2);
  PVector arcEnd = new PVector(x + radius, y + beamWidth / 2);
  float startAngle = atan2(arcStart.y - y, arcStart.x - x);
  float endAngle = atan2(arcEnd.y - y, arcEnd.x - x);
  PVector c1 = new PVector(rectX, y - beamWidth / 2, 2);
  PVector c2 = new PVector(x + radius * cos(startAngle), y + radius * sin(startAngle), 1).add(new PVector(beamCurvedMod, 0));
  PVector c3 = new PVector(x + radius * cos(endAngle), y + radius * sin(endAngle), 1).add(new PVector(beamCurvedMod, 0));
  PVector c4 = new PVector(rectX, y + beamWidth / 2, 2);
  
  fill(pal[pal.length - 1]);
  beginShape();
  vertex(c1.x, c1.y);
  vertex(c2.x, c2.y);
  curveVertex(c2.x, c2.y);
  float angleStep = radians(.01); // Adjust the step size for smoother curves
  for (float angle = startAngle; angle <= endAngle; angle += angleStep) {
    float arcX = x + radius * cos(angle);
    float arcY = y + radius * sin(angle);
    curveVertex(arcX + beamCurvedMod, arcY);
  }
  curveVertex(c3.x, c3.y);
  vertex(c3.x, c3.y);
  vertex(c4.x, c4.y);
  endShape(CLOSE);

  println("Finished.");
  exit();
}
