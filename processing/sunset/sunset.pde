String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float hue = 360;
float sat = 100;
float brt = 100;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
  
}


void draw() {
  background(#8b879f);  
  for (int i = 20; i < 360; i+=5) {
    float rad = radians(i);
    float x1 =width/2 + 200 * sin(rad);
    float y1 = height/2 + 200 * cos(rad);           
    float rad2 = radians(-i);
    float x2 =width/2 + 200 * sin(rad2);
    float y2 = height/2 + 200 * cos(rad2);  
    Brush b = new Brush(15, 0, 0, color(hue, sat, brt));
    for (int j = 0; j < 200; j++) {
      float nx = lerp(x1, x2, j/200.);
      float ny = lerp(y1, y2, j/200.);
      b.cx = nx;
      b.cy = ny;
      b.render();
    }  
    brt -= 1;
  }
  
  
  for (float y = -10; y < height; y += 70) {
    for (float x = -10; x < width; x += 10) {
      x += random(20);
      if(random(1) > .5) {
        Brush b = new Brush(random(50), 0, 0, #3C3B5F);
        float ex = x + random(5, 40);
        for (int j = 0; j < 200; j++) {
          float nx = lerp(x, x + ex, j/200.);
          float ny = lerp(y, y, j/200.);
          b.cx = x + nx;
          b.cy = ny + constrain(randomGaussian(), -10, 10);
          b.render();
        }
        x = x + ex;
        
        //line(x, y, x + random(5, 40), y);
      }
      
    }
    y += random(2);
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
        stroke(col, .2);      
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
