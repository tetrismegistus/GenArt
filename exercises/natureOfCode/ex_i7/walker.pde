class Walker {
  float x;
  float y;
  float h;
  float s;
  float b;
  float tx, ty;
  
  Walker(float x_, float y_, float h_, float s_, float b_) {
    x = x_;
    y = y_;
    h = h_;
    s = s_;
    b = b_;
    ty = 10000;
  }
  
  void display() {
    noFill();
    stroke(h, s, b % frameCount);
    point(x, y);
  }
  
  void step() {
    float stepx = map(noise(tx), 0, 1, -1, 1);
    float stepy = map(noise(ty), 0, 1, -1, 1);
    x += stepx;
    y += stepy;
    tx += 0.01;
    ty += 0.01;
            
  }
}
