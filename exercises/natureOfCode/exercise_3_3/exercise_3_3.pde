Car car;

void setup() {
  size(800, 800);
  car = new Car(width/2, height/2);
}

void draw() {
  background(123);
  
  car.update();
  car.checkEdges();
  car.display();
}


void keyPressed() {
  
  if (key == CODED) {
    if (keyCode == LEFT) {
      float angle = car.velocity.heading() - degrees(3);
      PVector accel = PVector.fromAngle(angle);
      accel.normalize();
      car.applyForce(accel);
      
      
    } else if (keyCode == RIGHT) {
      float angle = car.velocity.heading() + degrees(3);
      PVector accel = PVector.fromAngle(angle);
      accel.normalize();
      car.applyForce(accel);
      
    }   
  }
  
}
