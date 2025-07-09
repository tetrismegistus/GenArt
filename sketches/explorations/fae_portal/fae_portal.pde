float HEXSIZE =  20;
float HEXW = sqrt(3) * HEXSIZE;
float HEXH = 2 * HEXSIZE;
float r = 0; 

void setup() {
  size(500, 500, P3D);
  frameRate(10);
  
}


void draw() {
  noStroke();
  background(100, 50, 123);
  
  pushMatrix();
  translate(width/2, height/2);
  rotateX(PI/3);
  
  rotate(r);
  stroke(0);
  for (int x = -width; x <= width + HEXW; x += HEXW) {
    for (int y = -height; y <= height + HEXH; y += HEXH) {
      fill(0, 50, 120);
      drawHex(x, y);
      fill(255,165,0);
      drawDiamond(x, y);
      noFill();
      //noStroke();
      
      //ellipse(x, y, HEXW, HEXH);
    }  
  }
  popMatrix();
  r += radians(1); 
  if (r <= radians(359)) {    
    saveFrame("frames/####.png");
  }
  
  
}


void drawDiamond(float x, float y) {
  PVector c = new PVector(x, y);
  PVector c1 = pointyHexCorner(c, HEXSIZE, 2);       
  PVector c2 = new PVector(x + HEXW / 2, y);
  PVector c3 = pointyHexCorner(c, HEXSIZE, 5);
  PVector c4 = new PVector(x - HEXW / 2, y); 
  beginShape();
  vertex(c1.x, c1.y, 10);
  vertex(c2.x, c2.y, 10);
  vertex(c3.x, c3.y, 10);
  vertex(c4.x, c4.y, 10);
  vertex(c1.x, c1.y, 10);
  endShape();  
}

void drawHex(float x, float y) {
  PVector c = new PVector(x, y);
  beginShape();
  for (int i = 0; i < 6; i++) {
    PVector corner = pointyHexCorner(c, HEXSIZE, i);
    vertex(corner.x, corner.y, 0);  
  }
  PVector corner = pointyHexCorner(c, HEXSIZE, 0);
  vertex(corner.x, corner.y, 0);
  endShape();
}

PVector pointyHexCorner(PVector center, float size,  float i) {
  float angle_deg = 60 * i - 30;
  float angle_rad = PI / 180 * angle_deg;
  PVector vector = new PVector(center.x + size * cos(angle_rad),
                               center.y + size * sin(angle_rad), -3);
  return vector; 
}
