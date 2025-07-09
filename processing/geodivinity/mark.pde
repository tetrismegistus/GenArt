class Mark {
  float x, y, size;
  boolean pleft = false;
  int i = 0;
  
  Mark (float xi, float yi, float sz, int idx) {
    x = xi;
    y = yi;
    size = sz;
    i = idx;
  }
  
  void render() {
    noStroke();
    rectMode(CENTER);
    pushMatrix();
    translate(x, y);
    rotate(radians(45));
    fill(0);
    square(0, 0, size);
    popMatrix();
    if (pleft) {     
      stroke(0, 0, 0);
      line(x, y, x - size * 2, y);      
    }

  }
     
}
