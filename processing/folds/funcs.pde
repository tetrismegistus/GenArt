PVector addF(PVector v1, PVector v2) { return new PVector(v1.x+v2.x, v1.y+v2.y); }
PVector subF(PVector v1, PVector v2) { return new PVector(v1.x-v2.x, v1.y-v2.y); }
PVector mulF(PVector v1, PVector v2) { return new PVector(v1.x*v2.x, v1.y*v2.y); }
PVector divF(PVector v1, PVector v2) { return new PVector(v2.x==0?0:v1.x/v2.x, v2.y==0?0:v1.y/v2.y); }
float cosh(float x) { return 0.5 * (exp(x) + exp(-x));}
float sinh(float x) { return 0.5 * (exp(x) - exp(-x));}

PVector d_pdj(PVector v, float amount) {
  float h = 0.1; // step
  float sqrth = sqrt(h);
  PVector v1 = pdj(v, amount);
  PVector v2 = pdj(new PVector(v.x+h, v.y+h), amount);
  return new PVector( (v2.x-v1.x)/sqrth, (v2.y-v1.y)/sqrth );
}

PVector dejongsCurtains(PVector v, float amount) {
    float b = 2.71;
    float d = -1.05;
    float a = -.47;
    float c = -0.8;
    float x = sin(a * v.y) - cos(b * v.x);
    float y = sin(c * v.x) - cos(d * v.y);
    return new PVector(x * amount, y * amount);
}


PVector leviathan(PVector v, float amount) {
     v = bent(horseshoe(v, 1.0), 1.0);
    for (int j = 0; j < 16; j++)v = addF(julia(v, 1.5), v);
    return new PVector(v.x * amount, v.y * amount); 
}
