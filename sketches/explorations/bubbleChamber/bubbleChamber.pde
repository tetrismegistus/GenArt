String sketchName = "bubbleChamber";
String saveFormat = ".png";
long lastTime;
int calls = 0;

ArrayList<Mover> movers;
PVector gravity = new PVector(0, 0.1);
PVector magneticField = new PVector(0, 0, 0.07); // Simulate magnetic field strength
float maxVelocity = 5;  // Maximum velocity
float maxAcceleration = 10;  // Maximum acceleration

void setup() {
  size(1400, 1400);  // Create a canvas
  movers = new ArrayList<Mover>();
  
  // Create 20 random movers with random charges
  for (int i = 0; i < 20; i++) {
    float x = width / 2;
    float y = height / 2;
    float vx = random(-2, 2);
    float vy = randomGaussian() + 0.5;
    float mass = randomGaussian() * 10; // Random mass
    float charge = randomGaussian();  // Random charge
    movers.add(new Mover(x, y, vx, vy, mass, charge));
  }
}

void draw() {
  background(255);

  for (Mover mover : movers) {
    if (mover.active) {
      // Apply gravity
      mover.applyForce(gravity);
      
      // Apply the Lorentz force (magnetic field effect)
      PVector lorentzForce = mover.vel.cross(magneticField);
      lorentzForce.mult(mover.charge / mover.mass); // Force is proportional to charge/mass ratio
      mover.applyForce(lorentzForce);
      
      mover.update();

      // Deactivate mover if it exceeds screen boundaries
      if (mover.pos.y > height * 2 || mover.pos.y < -height * 2 || mover.pos.x > width * 2 || mover.pos.x < -width * 2) {
        mover.active = false;
      }
    }
    mover.show();
  }
}

String getTemporalName(String prefix, String suffix) {
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}

void keyReleased() {
  if (key == 's' || key == 'S') {
    saveFrame(getTemporalName(sketchName, saveFormat));
  }
}

class History {
  PVector pos;
  PVector vel;
  PVector acc;

  History(PVector pos, PVector vel, PVector acc) {
    this.pos = pos;
    this.vel = vel;
    this.acc = acc;
  }
}

class Mover {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  float r;
  float charge;
  boolean active;
  ArrayList<History> trail;

  Mover(float x, float y, float vx, float vy, float m, float c) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    acc = new PVector(0, 0);
    mass = m;
    r = sqrt(mass) * 10;
    charge = c;
    active = true;
    trail = new ArrayList<History>();
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acc.add(f);
  }

  void attract(Mover mover) {
    PVector force = PVector.sub(pos, mover.pos);
    float distanceSq = constrain(force.magSq(), 100, 1000);
    float G = 1;
    float strength = (G * (mass * mover.mass)) / distanceSq;
    strength *= charge * mover.charge;  // Adjust strength based on charge
    force.setMag(strength);
    mover.applyForce(force);
  }

  void update() {
    // Limit the acceleration
    if (acc.mag() > maxAcceleration) {
      acc.setMag(maxAcceleration);
    }

    vel.add(acc);

    // Limit the velocity
    if (vel.mag() > maxVelocity) {
      vel.setMag(maxVelocity);
    }

    pos.add(vel);
    acc.set(0, 0);

    trail.add(new History(pos.copy(), vel.copy(), acc.copy()));  // Store a copy of the current state in the trail
  }

  void show() {
    for (History h : trail) {
      float speed = h.vel.mag();
      float maxSpeed = maxVelocity;

      // Map speed to a color (e.g., from blue to red)
      int colorValue = (int) map(speed, 0, maxSpeed, 0, 255);
      fill(255 - colorValue, 0, colorValue, 100);

      // Map speed to thickness
      float thickness = map(speed, 0, maxSpeed, 1, 10);
      noStroke();
      ellipse(h.pos.x, h.pos.y, thickness, thickness); // Small bubbles to simulate bubble chamber effect
    }
  }
}
