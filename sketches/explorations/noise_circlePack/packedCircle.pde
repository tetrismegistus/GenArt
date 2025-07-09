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


class Circle{
  float radius;
  CompositePoint center;
  
  Circle(float r, CompositePoint c) {
    radius = r;
    center = c;
  }
  
  void render(){    
    ellipse(center.x, center.y, radius*2, radius*2);    
  }
  
 float distance(Circle circle2){
    float d = center.distance(circle2.center);
    return d - (radius + circle2.radius);
  }
  
  boolean contains(CompositePoint point) {
    if (point.distance(center) < radius) {
      return true;
    } else {
      return false;
    }
  }
}


ArrayList<Circle> PackCircles(int attempts, ArrayList<Circle> circleList){ 
  int spacing = 5;
  for (int i = 0; i < attempts; i ++){
    CompositePoint point = new CompositePoint(random(0, width),
                                              random(0, height));
    Circle circle = new Circle(random(2, 255), point);
    boolean collides = false;
    for (Circle c : circleList) {
      boolean overlap = c.distance(circle) < spacing;
      if (overlap) {
        collides = true;
        break;        
      }            
    }
    if (!collides){
     circleList.add(circle);
    }           
  }
  return circleList;
}
