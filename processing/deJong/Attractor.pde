class Attractor {
  PVector pos;
  PVector orig;
  ArrayList<PVector> trail = new ArrayList<PVector>();
  float scale;
  float limit = 8;
  
  float a = random(-limit, limit);
  float b = random(-limit, limit);
  float c = random(-limit, limit);
  float d = random(-limit, limit);
  
  color clr;
  
  
  Attractor (float x, float y, float s, color clr) {
    orig = new PVector(x, y);
    pos = new PVector(0, 0);
    scale = s;
    this.clr = clr;
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
    
    
    
    pushMatrix();
    translate(orig.x, orig.y);    
    for (int i = 0; i < trail.size(); i++) {
      float h = hue(clr);
      float s = saturation(clr);
      float b = map(i, 0, iterations, 0, 100);
      stroke(h, s, b, .8);
      
      point(trail.get(i).x * scale, trail.get(i).y * scale);
    }
    popMatrix();
  }
}
