class Particle {
  PVector velocity = new PVector();
  PVector pos;
  float minX = border;
  float minY = border;
  float maxX = width - border;
  float maxY = height - border;
  float damping = .1;
  ArrayList<PVector> trail = new ArrayList<>();
  
  Particle (float x, float y) {
    pos = new PVector(x, y);
  }
  
  void update() {
    trail.add(pos.copy());
    pos.add(velocity);    
    if (pos.x < minX) {
      pos.x = minX - (pos.x - minX);
      velocity.x = -velocity.x;
    }
    
    if (pos.x > maxX) {
      pos.x = maxX - (pos.x - maxX);
      velocity.x = -velocity.x;
    }
    
    if (pos.y < minY) {
      pos.x = minY - (pos.y - minY);
      velocity.y = -velocity.y;
    }
    
    if (pos.y > maxY) {
      pos.y = maxY - (pos.y - maxY);
      velocity.y = -velocity.y;
    }
    
    velocity.mult(1-damping);      
  }
  
  void render() {
    circle(pos.x, pos.y, 3);
    if (dispTrail) {
      //beginShape();
      for (PVector t : trail) {
        point(t.x, t.y);
      }
      //endShape();
    }
    
  }

}
