class Particle extends VerletParticle2D {
  Vec2D prevPos;

  Particle(float x, float y) {
    super(x, y, particleMass);
  }


  void display() {
    fill(255);
    ellipse(x, y, 10, 10);
  }
}
