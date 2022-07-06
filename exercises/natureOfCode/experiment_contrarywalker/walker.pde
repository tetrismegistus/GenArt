class Walker {
  float x;
  float y;
  
  Walker(float x_, float y_) {
    x = x_;
    y = y_;
  }
  
  void display() {
    noFill();
    circle(x, y, 1);
  }
  
  void step() {
    float stepx;
    float stepy;
    if (mouseX > x) {
        stepx = +1 ;
      } else if (mouseX < x) {
        stepx = -1;
      } else {
        stepx = 0;
      }
      
      if (mouseY > y) {
        stepy = +1 ;
      } else if (mouseY < x) {
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
