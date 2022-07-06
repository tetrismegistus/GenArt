Ship ship;

void setup() {
  size(800, 800);
  ship = new Ship(width/2, height/2);
}

void draw() {
  background(0);
  
  ship.update();
  ship.checkEdges();
  ship.display();
}


void keyPressed() {
  
  if (key == CODED) {
    if (keyCode == LEFT) {
      float angle = ship.heading.heading() - .05;
      PVector heading = PVector.fromAngle(angle);
      ship.heading = heading;
      
      
      
    } else if (keyCode == RIGHT) {
      float angle = ship.heading.heading() + .05;
      PVector heading = PVector.fromAngle(angle);
      ship.heading = heading;      
      
    } else if (keyCode == UP) {
      PVector thrust = ship.heading.copy();           
      thrust.mult(.1);
      ship.applyForce(thrust);

            
      
    }
  }
  
}
