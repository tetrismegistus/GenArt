PShader shader;

float iteration = radians(0);
int attempts = 10000;
ArrayList<Circle> CIRCLES = new ArrayList<Circle>();

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
    float d = radius*2;
    shader.set("u_resolution", d, d);
    shader.set("u_mouse", float(mouseX), float(mouseY));
    shader.set("u_time", millis() / 1000.0);
    shader(shader);
    
    
    ellipse(center.x, center.y, d, d);
    //resetShader();
  }
  
 float distance(Circle circle2){
    float d = center.distance(circle2.center);
    return d - (radius + circle2.radius);
  }
}


ArrayList<Circle> PackCircles(int attempts, ArrayList<Circle> circleList){  
  for (int i = 0; i < attempts; i ++){
    CompositePoint point = new CompositePoint(random(0, width),
                                              random(0, height));
    Circle circle = new Circle(random(5, 100), point);
    boolean collides = false;
    for (Circle c : circleList) {
      boolean overlap = c.distance(circle) < 5;
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

void setup() {
  size(1024, 768, P2D);
  noStroke();
  shader = loadShader("shader.frag");
  CIRCLES = PackCircles(attempts, CIRCLES);

}

void draw() {
  background(0);
  
  for (Circle c : CIRCLES) {    
    c.render();
  }
  saveFrame("frames/####.png");
 
}
