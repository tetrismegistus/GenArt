class Brush {
  float rad, cx, cy, z;
  color col;
  BrushTip[] brushEnds;
  
  Brush(float r, float x, float y, color c) {
    rad = r;
    cx = x;
    cy = y;
    col = c;

    int cap = ((int) rad * (int) rad) * 4;
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

void lerpLine(float x1, float y1, float x2, float y2, color c) {
  float d = dist(x1, y1, x2, y2);
  Brush b = new Brush(3, 0, 0, c);
  for (float i = 0; i < d; i++) {
    b.cx = lerp(x1, x2, i/d);
    b.cy = lerp(y1, y2, i/d);
    b.render();    
  }
}
