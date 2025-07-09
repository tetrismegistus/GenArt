String sketchName = "mySketch";
String saveFormat = ".png";

PImage img;

int calls = 0;
long lastTime;

void setup() {
  size(1760, 1860);
  colorMode(HSB, 360, 100, 100, 1);
  img = loadImage("bl-mage.png");
  
}


void draw() {
  background(0);
  //textSquare(0, 0, width, #EDDDD4);

  
  img.loadPixels();
  for (int i = 0; i < 220; i+=8) {
    for (int j = 0; j < 220; j+=8) {
      //square(i, j, 20);
      noFill();
      
      float n = noise(i * 0.01, j * 0.01);

      Brush b = new Brush(10, width/2, height/2, img.pixels[i + j * 220]);
      
      //bezier(i, j, i, j + 40, i + 40, j, i + 40, j + 40);
      
      int steps = 100;
      for (int k = 0; k <= steps; k++) {
        float t = k / float(steps);
        float ni = i * 8;
        float nj = j * 8;
        float l = 60;
        if (n > .5) {
          
          b.cx = bezierPoint(ni, ni, ni + l, ni + l, t);
          b.cy = bezierPoint(nj, nj+ l, nj, nj + l, t);
        } else {
          b.cx = bezierPoint(     ni, ni, ni + l, ni + l, t);
          b.cy = bezierPoint(nj + l, nj, nj + l, nj,      t);        
        }
        b.render();        
      }
      stroke(0);
      strokeWeight(3);
    }
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
