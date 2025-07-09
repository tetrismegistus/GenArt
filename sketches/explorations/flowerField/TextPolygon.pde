void polygon(float x, float y, int sides, float sz, color c){
    
  
  noFill();  
  for (float size = sz; size > 0; size -= 10) {
    PVector[] corners = new PVector[sides]; 
    
    for (int i = 0; i < sides; i++) {
      float step = radians(360/sides);
      corners[i] = new PVector(size * cos(i*step) + x, size * sin(i*step) + y);      
    } 
    
    for (int corner = 0; corner < corners.length - 1; corner++) {
      PVector currentCorner = corners[corner];
      PVector nextCorner = corners[corner + 1];
      
      lerpLine(currentCorner.x, currentCorner.y, nextCorner.x, nextCorner.y, c);
    }
    lerpLine(corners[corners.length - 1].x, corners[corners.length - 1].y, corners[0].x, corners[0].y, c);
  
  }
}

void lerpLine(float x1, float y1, float x2, float y2, color c) {
  float d = dist(x1, y1, x2, y2);
  Brush b = new Brush(2, 0, 0, c);
  for (float i = 0; i < d; i++) {
    b.cx = lerp(x1, x2, i/d);
    b.cy = lerp(y1, y2, i/d);
    b.render();    
  }
}
