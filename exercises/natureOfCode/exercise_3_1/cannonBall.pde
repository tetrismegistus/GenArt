// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

class CBall {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;

  float angle = 0;
  float aVelocity = 0;
  float aAcceleration = 0;
  int colr;
  
  ArrayList<PVector> trail;

  CBall(float m, float x, float y) {
    
    
    mass = m;
    location = new PVector(x,y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0,0);
    trail = new ArrayList<PVector>();
    trail.add(location.copy());
    colr = color(random(255), random(255), random(255));
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force,mass);
    acceleration.add(f);
  }

  void update() {

    velocity.add(acceleration);
    location.add(velocity);



    acceleration.mult(0);
    if (trail.size() > 800) {
      trail.remove(0);
    } 
    
    trail.add(location.copy());
    

  
  }

  void display() {
    
    
    noFill();
    beginShape();
    for (int i = 0; i < trail.size(); i++) {
      float a = map(i, 0, trail.size(), 100, 255);
      stroke(colr, a);
      curveVertex(trail.get(i).x, trail.get(i).y);
    }
    endShape();
    
    
    stroke(colr);
    fill(colr,200);
    float angle = atan2(velocity.y, velocity.x);
    rectMode(CENTER);
    pushMatrix();
    translate(location.x,location.y);
    rotate(angle);
    rect(0,0,mass*16,mass*16);    
    popMatrix();
    
    
  }
  
  void checkEdges() {
    if (location.y > height) {
      velocity.y *= -1;
      location.y = height;
    }
      
  }

}
