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

  Mover(float m, float x, float y, color c) {
    mass = m;
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    trail = new ArrayList<PVector>();
    colr = c;
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
    
    
  }

  void display() {
    
    
    float sw = map(mass, 0.1, 1, 0.1, 3);
    float D = map(mass, 0.1, 1, 3, 6);
    strokeWeight(sw);
    
    noFill();
    for (int i = 1; i < trail.size(); i++) {
      
      
      PVector p = trail.get(i);
      if (p.x > lB && p.x < rB && p.y > tB && p.y < bB) {
        textCircle(p.x, p.y, D, colr);
      }
      
    }
    
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
