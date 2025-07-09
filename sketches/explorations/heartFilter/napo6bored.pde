int steps = 100;
ArrayList<PVector> points = new ArrayList<PVector>();
PGraphics mask;
PGraphics bg;
int[] colors = {#FAF0CA, #F4D35E, #EE964B, #F95738};

void setup() {
  size(800, 800);
  mask  = createGraphics(800, 800);
  bg = createGraphics(800, 800);
  smooth(8);
  
  for (int i = 0; i <= width; i++) {
    float t = pos_t(i); 
    PVector p = new PVector(pos_x(t) * 20, -pos_y(t) * 20);
    points.add(p);
  }  
}

void draw() {
  bg.beginDraw();
  bg.background(#FFE0B5);
  bg.stroke(#CA2E55);
  bg.strokeWeight(1.5);
  
  bg.pushMatrix();
  bg.translate(width/2, height/2);
  bg.fill(#CA2E55);
  bg.beginShape();
  for (int i = 0; i < points.size(); i++) {
    PVector p = points.get(i);
    bg.curveVertex(p.x, p.y);
    
  }
  bg.endShape();
  bg.popMatrix();
  for (int y = 0; y <=height; y+=2) {
    variSegLine(0, y, width, y);
  }
  
  
  
  mask.beginDraw();
  mask.translate(width/2, height/2);
  mask.fill(255);
  mask.background(0);
  mask.beginShape();
  for (int i = 0; i < points.size(); i++) {
    PVector p = points.get(i);
    mask.curveVertex(p.x, p.y);
    
  }
  mask.endShape();
  mask.endDraw();
  
  //fill(255);
  bg.mask(mask);
  bg.endDraw();
  background(#FFE0B5);
  image(bg, 0, 0);
  
  save("love.png");
  
  noLoop();
  
}


void variSegLine(float x1, float y1, float x2, float y2) {
  PVector v1 = new PVector(x1, y1);
  PVector v2 = new PVector(x2, y2);
  for (float i = 0; i <= 1; i+=.01) {
      float adj = constrain(i + (randomGaussian() + 2) / 5, i, 1);
      PVector lp1 = PVector.lerp(v1, v2, i);
      PVector lp2 = PVector.lerp(v1, v2, adj);
      bg.strokeWeight(random(.5, 10)); 
      bg.stroke(pickColor(), 100);
      bg.line(lp1.x, lp1.y, lp2.x, lp2.y);
      i = adj;
      

    }
  
}

int pickColor() {
  int i = round(random(0, colors.length  - 1));
  return colors[i];
}


float pos_t (float n) {
  return lerp(-PI,PI,n/400);
}

float pos_x(float n){
  return 16*pow(sin(n),3);
}


float pos_y(float n){
  return 13*cos(n)-5*cos(2*n)-2*cos(3*n)-cos(4*n);
}
