class Walker {
  float x;
  float y;
  float h;
  float s;
  float b;
  
  Walker(float x_, float y_, float h_, float s_, float b_) {
    x = x_;
    y = y_;
    h = h_;
    s = s_;
    b = b_;
  }
  
  void display() {
    noFill();
    stroke(h, s, frameCount % 100);
    circle(x, y, 1);
  }
  
  void step() {
    float stepx;
    float stepy;
    if (attractor.x > x) {
        stepx = +1 ;
      } else if (attractor.x < x) {
        stepx = -1;
      } else {
        stepx = 0;
      }
      
      if (attractor.y > y) {
        stepy = +1 ;
      } else if (attractor.y < x) {
        stepy = -1;
      } else {
        stepy = 0;
      }
    
    if (random(1) > .5) {
      stepx = -stepx;
      stepy = -stepy;
    } 
      
          
 
    x += stepx;
    y += stepy;        
  }
}
