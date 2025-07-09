class Hexagon {
  float x, y, radius;
  
  
  Hexagon(float x_, float y_, float r_) {
    x = x_;
    y = y_;
    radius = r_ + random(0, r_/2);
    
  }

  void render() {
    
    
    
    PVector c = new PVector(x, y);
    PVector[] vertices = new PVector[6];

    for (int i = 0; i < 6; i++) {
      PVector corner = flatHexCorner(c, radius, i);

      vertices[i] = new PVector(corner.x, corner.y);
    }
    


    
    color col = p[clrIdx];
    
    
    for (int t = 0; t < 5; t++) {
      Triangle tri = new Triangle(c, vertices[t], vertices[t+1], new PVector(x, y), radius, col);
      tri.render();    
    }    
    Triangle tri = new Triangle(c, vertices[5], vertices[0], new PVector(x, y), radius, col);
    tri.render();
    clrIdx = (clrIdx + 2) % p.length;
    
  }

  PVector pointyHexCorner(PVector center, float size,  float i) {
    float angle_deg = 60 * i - 30;
    float angle_rad = PI / 180 * angle_deg;
    PVector vector = new PVector(center.x + size * cos(angle_rad),
                               center.y + size * sin(angle_rad), -3);
    return vector; 
  }

  PVector flatHexCorner(PVector center, float size, float i) {
    float angle_deg = 60 * i;
    float angle_rad = PI / 180 * angle_deg;
    PVector vector = new PVector(center.x + size * cos(angle_rad),
                               center.y + size * sin(angle_rad));
    return vector;
  }
  
  PVector randomUniformPoint() {
    
    return new PVector(random(x + radius), random(y + radius));
  }
  
  void drawRandomUniformPoint() {
    PVector p = randomUniformPoint();
    point(p.x, p.y); 
  }
}


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
    for (int i = 0; i < (radius * radius) * 4; i ++) {
      PVector p = RandomUniformPoint();  
      float d = distance(p);
      float bsidx = map(d, 0, radius * 2, 100, 0);
      float h = hue(c);
      stroke(color(h, saturation(c), bsidx));
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
