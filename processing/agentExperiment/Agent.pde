class Agent {
  PVector pos;
  PVector acc;
  PVector vel;  
  int trailIndex; 
  float mass;
  color c;
  
  Agent(PVector pos, PVector acc, PVector vel, color c) {
    this.pos = pos;
    this.acc = acc;
    this.vel = vel;
    this.c = c;
    
    this.mass = random(1, 30);
    // since several Agents will be accessing a common store of trails, the TrailManager 
    // will take care of telling the Agent which index their trail is at    
    trailIndex = trailManager.createTrail(c);
  }
  
  void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(mass);
    acc.add(f);
  }
  
  void update() {
    vel.add(acc);
    vel.limit(10);
    pos.add(vel);
        
    trailManager.trails.get(trailIndex).trail.add(pos.copy());  // whew!
  }
  
  void display() {
    //circle(pos.x, pos.y, 10);
  }  
  
  void checkEdges() {
    
    if (pos.x > width) {
      pos.x = width;
      vel.x *= -1;
    } else if (pos.x < 0) {
      vel.x *= -1;
      pos.x = 0;
    }
    
    
     if (pos.y > height) {
       vel.y *= -1;
       pos.y = height;
     }
  }
}
