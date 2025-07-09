String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

void setup() {
  size(400, 400);
  colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
  background(0, 0, 100);
  Brush b = new Brush(10, width/2, height/2, color(random(360), random(100), random(100)));
  
  
  bezier(340, 80, 40, 40, 360, 360, 60, 320);
  int steps = 1000;
  for (int i = 0; i <= steps; i++) {
    float t = i / float(steps);
    float x = bezierPoint(340, 40, 360, 60, t);
    float y = bezierPoint(80, 40, 360, 320, t);
    b.cx = x;
    b.cy = y;
    b.render();
    //ellipse(x, y, 10, 10);
  }
  
  noLoop();
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


class Brush {
  float rad, cx, cy;
  color col;
  BrushTip[] brushEnds;
  
  Brush(float r, float x, float y, color c) {
    rad = r;
    cx = x;
    cy = y;
    col = c;
    int cap = ((int) rad * (int) rad) * 2;
    brushEnds = new BrushTip[cap];
    for (int i = 0; i < cap; i++) {
      brushEnds[i] = getBrushTip();      
    }
  }
  
  void render() {
    pushMatrix();
    translate(cx, cy);
    for (BrushTip bt : brushEnds) {
      if (random(1) > .1) {
        strokeWeight(bt.sz);
        stroke(col, random(.4));      
        point(bt.pos.x, bt.pos.y);
      }
    }
    popMatrix();
  }
  
  BrushTip getBrushTip() {
    float r = rad * sqrt(random(0, 1));
    float theta = random(0, 1) * 2 * PI;
    float x = r * cos(theta) + randomGaussian();
    float y = r * sin(theta) + randomGaussian();
    return new BrushTip(new PVector(x, y), .2 + abs(randomGaussian()));    
  }
}


class BrushTip {
  float sz;
  PVector pos;
  
  BrushTip(PVector xy, float isz) {
    pos = xy;
    sz = isz;
  }
}
