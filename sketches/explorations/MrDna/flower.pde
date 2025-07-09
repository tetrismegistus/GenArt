class CompositePoint {
  float x;
  float y;  
  
  CompositePoint(float x_pos, float y_pos){
    x = x_pos;
    y = y_pos;
  }
  
  float distance(CompositePoint point2){
    float xd = x - point2.x;
    float yd = y - point2.y;
    return sqrt(pow(xd, 2) + pow(yd, 2));  
  }      
}


class Flower{
  float radius;
  CompositePoint center;
  float x1;
  float y1;
  float x2;
  float y2;
  float cp1x;
  float cp1y;
  float cp2x;
  float cp2y;
  float col;
  
  Flower(float r, CompositePoint c) {
    radius = r;
    center = c;
    
  }
  
  void render(){
    Hexagon h = new Hexagon(center.x, center.y, radius);
    //stipCirc(center.x, center.y, radius, p[clrIdx]); //<>//
    fill(p[clrIdx], random(1));
    h.render();
    clrIdx = (clrIdx + 1) % p.length;
    
    //circle(center.x, center.y, radius * 2);
  }
  
  
 float distance(Flower circle2){
    float d = center.distance(circle2.center);
    return d - (radius + circle2.radius);
  }
}
