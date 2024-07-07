class Attractor {
  PVector pos;
  float radius = 200;
  float strength = 1;
  float ramp = 1;
  
  Attractor(float x, float y) {
    pos = new PVector(x, y);
  }
  
  void attract(Particle particle) {
    float dx = pos.x - particle.pos.x;
    float dy = pos.y - particle.pos.y;
    float d = mag(dx, dy);
    if (d > 0 && d > radius) {
      float s = pow(d/radius, 1/ramp);
      float f = s*9*strength * (1/(s+1) + ((s - 3)/4)) / d;
      
      particle.velocity.add(dx * f, dy * f);
    }
  }

}
