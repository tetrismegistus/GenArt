int attempts = 100000;
ArrayList<Flower> CIRCLES = new ArrayList<Flower>();

void setup() {
  size(1024, 768);
  colorMode(HSB);
  CIRCLES = PackCircles(attempts, CIRCLES);
}

void draw(){

  background(random(255), random(255), random(255));
  noStroke();
  for (Flower c : CIRCLES) {    
    c.render();
  }
  save("test.png");
  noLoop();
}


void flower(float x, float y, float size) {
  noStroke();
  pushMatrix();
  translate(x, y);
  float x1 = random(0, size);
  float y1 = random(0, size);
  float x2 = random(0, size);
  float y2 = random(0, size);
  float cp1x = random(0, size);
  float cp1y = random(0, size);
  float cp2x = random(0, size);
  float cp2y = random(0, size);
  float col = random(255);  

  for (int i = 0; i < 36; i++) {
    
    fill(col, random(100, 255), random(100, 255), random(100, 255));
    bezier(x1, y1,  cp1x, cp1y,  cp2x, cp2y,  x2, y2);
    bezier(-x1, y1,  -cp1x, cp1y,  -cp2x, cp2y,  -x2, y2);
    rotate(radians(10));
  }
  popMatrix();

}


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
    pushMatrix();
    translate(center.x, center.y);
    for (int i = (int) radius; i > 0;  i -= 1){  
      x1 = random(0, i);
      y1 = random(0, i);
      x2 = random(0, i);
      y2 = random(0, i);
      cp1x = random(0, i);
      cp1y = random(0, i);
      cp2x = random(0, i);
      cp2y = random(0, i);
      col = random(255);
        
      for (int r = 0; r < 36; r++) {
        fill(col, random(100, 255), random(100, 255), random(0, 255));
        bezier(x1, y1,  cp1x, cp1y,  cp2x, cp2y,  x2, y2);
        bezier(-x1, y1,  -cp1x, cp1y,  -cp2x, cp2y,  -x2, y2);
        rotate(radians(10));
      }
    }
    popMatrix();
  }
  
  
 float distance(Flower circle2){
    float d = center.distance(circle2.center);
    return d - (radius + circle2.radius);
  }
}

ArrayList<Flower> PackCircles(int attempts, ArrayList<Flower> circleList){  
  for (int i = 0; i < attempts; i ++){
    CompositePoint point = new CompositePoint(random(0, width),
                                              random(0, height));
    Flower circle = new Flower(random(5, 255), point);
    boolean collides = false;
    for (Flower c : circleList) {
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
