class Car {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  float topspeed;
  int colr;
  
  Car(float x, float y) {
    location = new PVector(x,y);
    velocity = new PVector(0, 4);
    acceleration = new PVector(0,0);
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
    float angle = velocity.heading();
    rectMode(CENTER);
    pushMatrix();
    translate(location.x,location.y);
    rotate(angle);
    rect(0,0,30, 10);    
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
