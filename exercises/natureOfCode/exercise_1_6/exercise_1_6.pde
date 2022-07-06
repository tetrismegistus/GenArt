ArrayList<Mover>  movers = new ArrayList<Mover>();

Mover mover;

void setup() {
  size(800, 800);
  for (int i = 0; i < 100; i++) {
    movers.add(new Mover(width/2, height/2));
  }
}


void draw() {
  background(255);
  for (Mover m: movers) {
    m.update();
    m.checkEdges();
    m.display();
  }
    
}

class Mover {
  PVector location;
  PVector velocity;
  PVector acceleration;
  ArrayList<PVector> points;
  int c;
  
  Mover(float x, float y) {
    points = new ArrayList<PVector>();
    location = new PVector(x, y);
    points.add(new PVector(location.x, location.y));
    velocity = new PVector(random(-2, 2), random(-2, 2));
    acceleration = new PVector(-0.001, 0.1);
    c = color(random(255), random(255), random(255));
  }
  
  void update() {
    
    float tx = noise(location.x * 0.01, location.y * 0.01, frameCount* 0.01);
    float ty = noise(location.x * 0.01, location.y * 0.01, frameCount* 0.09);
    float ax = map(tx, 0, 1, -.5, .5);
    float ay = map(ty, 0, 1, -.5, .5);
    acceleration = new PVector(ax, ay);
    velocity.add(acceleration);
    velocity.limit(10);
    location.add(velocity);
    if (points.size() <= 1000) {
      points.add(new PVector(location.x, location.y));
      
    } else {
      points.add(0, new PVector(location.x, location.y));
      points.remove(points.size() - 1);
                
    }
    
  }
  
  void display() {
    stroke(c);    
    ellipse(location.x, location.y, 16, 16);
    noFill();
    beginShape();
    for (int i = 0; i < points.size(); i++) {
      PVector p = points.get(i);
      curveVertex(p.x, p.y);
      
    
    }
    endShape();
    //point(location.x, location.y);
  }
  
  void checkEdges() {
    if (location.x > width) {
      location.x = 0;
    } else if (location.x < 0) {
      location.x = width;
    }
    
     if (location.y > height) {
       location.y = 0;
     } else if (location.y < 0) {
       location.y = height;
     }
  }
}
