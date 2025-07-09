class Triangle {
  PVector p1, p2, p3, cent;
  color c;
  float radius;
  
  Triangle(PVector pv1, PVector pv2, PVector pv3, PVector c1, float r, color c2) {
    p1 = pv1;
    p2 = pv2;
    p3 = pv3;
    c = c2;
    cent = c1;
    radius = r;
  }
  
  void render() {
    //triangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
    for (int i = 0; i < radius * radius * 2; i ++) {
      PVector p = RandomUniformPoint();  
      float d = distance(p);
      float bsidx = map(d, 0, radius * 2, 100, 0);
      float h = hue(c);
      //stroke(color(h, saturation(c), bsidx));
      stroke(c);
      strokeWeight(abs(randomGaussian()) + .2);
      point(p.x, p.y);
    }

      
  }
  
  PVector RandomUniformPoint() {
    float r1 = random(0, 1);
    float r2 = random(0, 1);
    float x = (1 - sqrt(r1)) * p1.x + (sqrt(r1) * (1 - r2)) * p2.x + (sqrt(r1) * r2) * p3.x;
    float y = (1 - sqrt(r1)) * p1.y + (sqrt(r1) * (1 - r2)) * p2.y + (sqrt(r1) * r2) * p3.y;
    return new PVector(x, y);
    
  }
  
  float distance(PVector point2){
    float xd = cent.x - point2.x;
    float yd = cent.y - point2.y;
    return sqrt(pow(xd, 2) + pow(yd, 2));  
  }
  
}
