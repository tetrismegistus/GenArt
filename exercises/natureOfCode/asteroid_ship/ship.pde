class Ship {
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector heading;
  float mass;
  float topspeed;
  int colr;
  
  Ship(float x, float y) {
    location = new PVector(x,y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0,0);
    heading = velocity.copy();
    colr = color(random(255), random(255), random(255));
    mass = 1;
    topspeed = 4;
  }
  
  void applyForce(PVector force) {
    PVector f = PVector.div(force,mass);
    acceleration.add(f);
  }
  
  void display() {          
    
    stroke(colr);
    fill(colr,200);
    float angle = heading.heading();
    rectMode(CENTER);
    pushMatrix();
    translate(location.x,location.y);
    rotate(angle);
    triangle(10, 0, -10, 10, -10, -10);
    rectMode(CORNER);
    rect(-14, -8, 4, 2);
    rect(-14, 4, 4, 2);
    popMatrix();
    
    
  }
  
  void update() {
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);    
  }
  
  void checkEdges() {

    if (location.x > width) {
      location.x = 0;
    } 
    else if (location.x < 0) {
      location.x = width;
    }

    if (location.y > height) {
      location.y = 0;
    } 
    else if (location.y < 0) {
      location.y = height;
    }
  }
  

}
