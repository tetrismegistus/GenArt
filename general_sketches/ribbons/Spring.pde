class Spring extends VerletSpring2D   {
  color c;
  
  Spring(VerletParticle2D a, VerletParticle2D b, color c, float strength) {
    super(a, b, dist(a.x, a.y, b.x, b.y), strength);
    this.c = c;
  }
  
  void display() {
    stroke(c);
    line(a.x, a.y, b.x, b.y);
  }
}
