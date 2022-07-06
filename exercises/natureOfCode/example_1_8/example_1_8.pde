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
  
  int c;
  float topspeed;
  
  
  Mover(float x, float y) {
    location = new PVector(x, y);
    velocity = new PVector(random(-2, 2), random(-2, 2));
    acceleration = new PVector(-0.001, 0.1);
    c = color(random(255), random(255), random(255));
    topspeed = 10;
  }
  
  void update() {
    PVector mouse = new PVector(mouseX, mouseY);
    PVector dir = PVector.sub(mouse, location);
    dir.normalize();
    dir.mult(0.5);
    acceleration = dir;
    
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }
  
  void display() {
    stroke(c);
    fill(175);
    ellipse(location.x, location.y, 16, 16);
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
