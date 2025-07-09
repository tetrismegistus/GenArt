class Walker {
  PVector pos;
  int numberOfAngles;
  
  Walker(float x, float y, int n) {
    pos = new PVector(x, y);
    numberOfAngles = n;
  }
  
  void move() {
    float nv = map((float) noise.eval(pos.x * scale, pos.y * scale), -1, 1, 0, 1);
    float angleMultiplier = floor(numberOfAngles * nv) / float(numberOfAngles);
    float angle = TWO_PI * angleMultiplier;
    //pos.add(PVector.fromAngle(TWO_PI * (pos.x / width * angle) / (2 + 5 * pos.y / height)).mult(.5));  
    pos.add(PVector.fromAngle(angle).mult(.5));
  }
  
  void draw() {
    point(pos.x, pos.y);
  }
}
