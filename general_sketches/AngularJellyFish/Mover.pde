// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  ArrayList<PVector> trail;
  int colr;

  Mover(float m, float x, float y) {
    mass = m;
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    trail = new ArrayList<PVector>();
    colr = color(200, random(100), random(100), random(1));
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    trail.add(location.copy());
    if (trail.size() > 100) {
      trail.remove(0);
    }
    
    
    
  }

  void display() {
    stroke(colr);
    strokeWeight(2);
    fill(colr, 100);
    //ellipse(location.x, location.y, mass*24, mass*24);
    float sw = map(mass, 0.1, 1, 0.1, 2);
    
    strokeWeight(sw);
    
    beginShape();
    noFill();
    
    for (int i = 0; i < trail.size(); i++) {
      float a = map(i, 0, trail.size(), 0, 255);
      stroke(colr, a);
      curveVertex(trail.get(i).x, trail.get(i).y);
    }
    endShape();
    
  }

  PVector attract(Mover m) {
    PVector force = PVector.sub(location, m.location);             // Calculate direction of force
    float distance = force.mag();                                 // Distance between objects
    distance = constrain(distance, 5.0, 25.0);                             // Limiting the distance to eliminate "extreme" results for very close or very far objects
    force.normalize();                                            // Normalize vector (distance doesn't matter here, we just want this vector for direction

    float strength = (g * mass * m.mass) / (distance * distance); // Calculate gravitional force magnitude
    force.mult(strength);                                         // Get force vector --> magnitude * direction
    return force;
  }


}
