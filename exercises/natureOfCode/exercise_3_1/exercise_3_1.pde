Cannon cannon;
ArrayList<CBall> cannonvolleys;
float g = 0.4;
float power = 5;

void setup() {
  size(1000, 800);
  cannon = new Cannon(50, height - 50);
  cannonvolleys = new ArrayList<CBall>();
  rectMode(CENTER);
}

void draw() {
 background(0);
 textSize(32);
 text(power, 10, 30); 
 cannon.updateAngle();
  
 
 
 
 for (CBall ball : cannonvolleys) {
   
   if (ball.velocity.mag() > 0.0029) {
     float frictionC = 0.01;
     PVector friction = ball.velocity.copy();
     friction.mult(-1);
     friction.normalize();
     friction.mult(frictionC);
     ball.applyForce(friction);
     float m = 0.1*ball.mass;
     PVector gravity = new PVector(0, m);
     ball.applyForce(gravity);
     ball.update();
     ball.checkEdges();
     ball.display();
     
   }
     
 }
 cannon.render();
}


void mouseClicked() {
  fire();
}


void mouseWheel(MouseEvent event) {
  float wheelCount = event.getCount();
  if (wheelCount > 0) {
    power -= .5;
  } else {
    power += .5;
  }
  power = constrain(power, 5.0, 20.0);
  
}

void fire() {
  CBall ball = new CBall(1, 50, height - 50);  
  PVector shotForce = PVector.fromAngle(radians(cannon.cannonAngle));
  shotForce.mult(power);
  
  ball.applyForce(shotForce);
  ball.update();
  cannonvolleys.add(ball);
  
  
}
