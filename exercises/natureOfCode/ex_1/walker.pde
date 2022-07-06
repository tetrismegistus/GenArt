class Walker {
  float x;
  float y;
  
  Walker() {
    x = width/2;
    y = height/2;
  }
  
  void display() {
    noFill();
    circle(x, y, 5);
  }
  
  void step() {
    float stepx = random(-1, 1);
    float stepy = random(-1, 1);
    x += stepx;
    y += stepy;        
  }
}
