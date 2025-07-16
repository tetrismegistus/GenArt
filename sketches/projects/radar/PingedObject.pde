class PingedObject {
  PVector location;
  PVector velocity;
  PVector acceleration;  
  float staleness = 0;
  color c = color(192, 30, 93, 0);
  float h = 192;
  float s = 30;
  float b = 93;
  PVector lastSeen;
  float alpha = 0;
  float pingAge = 0;
  float lastSeenTime;
  
    
  PingedObject(float x, float y) {    
    location = new PVector(x, y);    
    velocity = new PVector(random(-2, 2), random(-2, 2));
    acceleration = new PVector(-0.1, 0.1);
    lastSeenTime = animationTime;
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
    location.x = (location.x + width) % width;
    location.y = (location.y + height) % height;
  }
  
  void display() {
    
    fill(h, s, b, 1);
    noStroke();
    if (lastSeen != null) {
      ellipse(lastSeen.x, lastSeen.y, 10, 10);
    }
    //point(location.x, location.y);
  }
  
  void ping() {
    alpha = 1;
    lastSeen = location.copy();
    lastSeenTime = animationTime;
  }
  

}
