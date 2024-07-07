
PVector wind = new PVector(0.01,0);
PVector gravity = new PVector(0, 0.1);

Mover mover;
Mover[] movers = new Mover[100];

void setup() {
  colorMode(HSB, 360, 100, 100, 1);
  size(800, 800);
  for (int i = 0; i < movers.length; i++) {
    movers[i] = new Mover(0, 0, randomGaussian());
  }
  
  
}


void draw() {
  background(0);
  
  for (int i = 0; i < movers.length; i++) {
    movers[i].applyForce(wind);
    movers[i].applyForce(gravity);
    movers[i].update();
    movers[i].display();
    movers[i].checkEdges();
  }
  saveFrame("frames/####.png");
  
    
}

class Mover {
  ArrayList<PVector> pointList;
  
  PVector location;
  PVector velocity;
  PVector acceleration;
  
  int c;
  float topspeed;
  float mass;
  
  
  Mover(float x, float y, float m) {
    pointList = new ArrayList<PVector>();
    location = new PVector(x, y);
    velocity = new PVector(0, -.1);
    acceleration = new PVector(0, 0);
    mass = m;
    c = color(random(255), random(255), random(255));
    topspeed = 10;
               
    pointList.add(new PVector(location.x, location.y));
  }
  
  void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(mass);
    acceleration.add(f);
  }
  
  void update() {
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
    acceleration.mult(0);
    
    int size = pointList.size();

    
    if (size <= 150) {           
      pointList.add(new PVector(location.x, location.y));                 
    } else {      
      pointList.remove(0);
      pointList.add(new PVector(location.x, location.y));      
    }
  }
  
  void display() {
    //stroke(c);
    float c = map(mass, 0, 5, 0, 360);
    float a = map(mass, 0, 5, 0, 1);
    noStroke();
    
    fill(c, 100, 100, a);
    ellipse(location.x, location.y, mass*16, mass*16);
    //noFill();
    beginShape();
    for (PVector p : pointList) {
      curveVertex(p.x, p.y);
    }
    endShape();
    //point(location.x, location.y);
  }
  
  void checkEdges() {
    if (location.x > width) {
      location.x = width;
      velocity.x *= -1;
    } else if (location.x < 0) {
      velocity.x *= -1;
      location.x = 0;
    }
    
     if (location.y > height) {
       velocity.y *= -1;     
       location.y = height;
     }
  }
}
