class Walker {
  float x;
  float y;
  float h;
  float s;
  float b;
  float tx, ty;
  
  Walker(float x_, float y_, float h_, float s_, float b_) {

    h = h_;
    s = s_;
    b = b_;
    tx = 0;
    ty= 10000;
  }
  
  void display() {
    //noFill();
    //stroke(h, s, constrain(frameCount % 100, 20, 100));
    circle(x, y, 10);
  }
  
  void step() {
    
    x = map(noise(tx), 0, 1, 0, width);
    y = map(noise(ty), 0, 1, 0, height);
    
    tx += 0.01;
    ty += 0.01;
            
  }
}
