class Cannon {
  float cannonAngle;
  PVector pos;
  
  Cannon(float x, float y) {
    pos = new PVector(x, y);
    cannonAngle = radians(0);    
  }
  
  void updateAngle() {
    cannonAngle = map(mouseY, 0, height, -90, 0);
  
  }
  
  void render() {
    stroke(255);
    fill(255);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(radians(cannonAngle));
    rect(0, 0, 70, 20);
    popMatrix();
  }
  
  
  
}
