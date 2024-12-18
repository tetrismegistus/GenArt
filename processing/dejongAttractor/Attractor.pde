class Attractor {
  PVector pos;
  PVector orig;
  ArrayList<PVector> trail = new ArrayList<PVector>();
  float scale;
  float limit = TWO_PI;
  float noiseOffset;
  float rotation; // Rotation angle for this attractor
  
  float a = PI;
  float b = PI;
  float c = PI;
  float d = TWO_PI;
  
  color clr;
  
  Attractor(float x, float y, float s, color clr, float offset) {
    orig = new PVector(x, y);
    pos = new PVector(0, 0);
    scale = s;
    this.clr = clr;
    this.rotation = 0; // Slight random rotation
    this.noiseOffset = offset;
  }
  
  void update() {
    stroke(clr);
    trail.add(pos.copy());
    float dx = sin(a * pos.y) - cos(b * pos.x);
    float dy = sin(c * pos.x) - cos(d * pos.y);
    pos.x = dx;
    pos.y = dy;
  }
  
  void display() {
    stroke(this.clr);
    pushMatrix();
    translate(orig.x, orig.y);  
    rotate(rotation);          
    for (int i = 0; i < trail.size(); i++) {
      point(trail.get(i).x * scale, trail.get(i).y * scale);
    }
    popMatrix();
  }
}
