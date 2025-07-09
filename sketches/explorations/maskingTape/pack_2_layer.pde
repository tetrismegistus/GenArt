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
}


ArrayList<Circle> PackCircles(int attempts, ArrayList<Circle> circleList){  
  for (int i = 0; i < attempts; i ++){
    CompositePoint point = new CompositePoint(random(0, width),
                                              random(0, height));
    Circle circle = new Circle(random(2, 255), point);
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
 
  
int attempts = 500;



void setup() {
  size(512, 512);
  background(0, 0, 123);
}


void draw() {
  background(0, 0, 0);
  ArrayList<Circle> CIRCLES1 = new ArrayList<Circle>();
  CIRCLES1 = PackCircles(1000000, CIRCLES1);        
  for (Circle c : CIRCLES1) {    
    noStroke();
    fill(255);
    c.render();
  } 
  
  
  
  PImage mask = createImage(width, height, RGB);
  mask.loadPixels();
  loadPixels();
  for (int i = 0; i < mask.pixels.length; i++) {
    mask.pixels[i] = pixels[i];
  }
  mask.updatePixels();
  background(255, 165, 0);
  ArrayList<Circle> CIRCLES = new ArrayList<Circle>();
  CIRCLES = PackCircles(1000000, CIRCLES);        
  for (Circle c : CIRCLES) {
    noStroke();
    fill(c.radius, random(0, 255), random(0, 255));
    c.render();
  }
  PImage img = createImage(width, height, RGB);
  img.loadPixels();
  loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = pixels[i];
  }
  img.updatePixels();
  background(0, 0, 123);
  
  
  img.mask(mask);
  image(img, 0, 0);
  save("packed.png");
  noLoop();
  
}

void polygon(float sides, float sz){
  beginShape();
  noStroke();
  fill(255);
  for (int i = 0; i < sides; i++) {
    float step = radians(360/sides);
    vertex(sz * cos(i*step), sz*sin(i*step));
    
  }
  endShape(CLOSE);  
}

void mousePressed() {
  redraw();
}
