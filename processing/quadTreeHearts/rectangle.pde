class Rectangle {
  float x, y, w, h;
  
  Rectangle(float x_, float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;  
  }
  
  boolean contains(PVector point) {
    return((point.x >= x - w) && 
    (point.x <= x + w) && 
    (point.y >= y - h) && 
    (point.y <= y + h)); 
  }
  
  
}
