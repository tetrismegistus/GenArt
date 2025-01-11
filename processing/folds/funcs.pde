PVector addF(PVector v1, PVector v2) { return new PVector(v1.x+v2.x, v1.y+v2.y); }
PVector subF(PVector v1, PVector v2) { return new PVector(v1.x-v2.x, v1.y-v2.y); }
PVector mulF(PVector v1, PVector v2) { return new PVector(v1.x*v2.x, v1.y*v2.y); }
PVector divF(PVector v1, PVector v2) { return new PVector(v2.x==0?0:v1.x/v2.x, v2.y==0?0:v1.y/v2.y); }

PVector sinusoidal(PVector v, float amount) {
  return new PVector(amount * sin(v.x), amount * sin(v.y));
}

PVector linear(PVector v, float amount) {
  return new PVector(amount * v.x, amount * v.y);
}


PVector hyperbolic(PVector v, float amount) {
  float r = v.mag() + 1.0e-10;
  float theta = atan2(v.x, v.y);
  float x = amount * sin(theta) / r;
  float y = amount * cos(theta) * r;
  return new PVector(x, y);
}

PVector polar(PVector v) {
    float theta = getTheta(v);
    float r = getR(v);
    float x = theta/PI;
    float y = r - 1.0;
    return new PVector(x, y);
}


PVector handkerchief(PVector v) {
  float theta = getTheta(v);
  float r = getR(v);
  float x = r * (sin(theta + r));
  float y = cos(theta - r);
  return new PVector(x, y);
}

PVector heart(PVector v) {
  float theta = getTheta(v);
  float r = getR(v);
  float x = r * (sin(theta * r));
  float y = -r * cos(theta * r);
  return new PVector(x, y);
}

float pdj_a = 0.1;
float pdj_b = 1.9;
float pdj_c = -0.8;
float pdj_d = -1.2;
PVector pdj(PVector v, float amount) {
  return new PVector( amount * (sin(pdj_a * v.y) - cos(pdj_b * v.x)),
                      amount * (sin(pdj_c * v.x) - cos(pdj_d * v.y)));
}


PVector rectt(PVector v, float amount) {
    float x = amount * (amount * ( 2.0 * floor(v.x/amount) + 1.0) - v.x);
    float y = amount * (amount * ( 2.0 * floor(v.y/amount) + 1.0) - v.y);
    return new PVector(x, y);
}

PVector swirl(PVector v, float amount) {
  float r = getR(v);
  float x = v.x * sin(r * r) - v.y * cos(r * r);
  float y = v.x * cos(r * r) - v.y * sin(r * r);
  return new PVector(amount * x, amount * y);
}

PVector horseshoe(PVector v, float amount) {
  float r = getR(v);
  float j = 1.0/r;
  float x = j * ((v.x - v.y) * (v.x + v.y));
  float y = j * (2.0 * v.x * v.y);
  return new PVector(amount * x, amount * y);
}

float popcorn_c = .1;
float popcorn_f = .09;
PVector popcorn(PVector v, float amount) {
  float x = v.x + popcorn_c * sin(tan(3.0 * v.y));
  float y = v.y + popcorn_f * sin(tan(3.0 * v.x));
  return new PVector(amount * x, amount * y);
}

PVector julia(PVector v, float amount) {
  float r = amount * sqrt(v.mag());
  float theta = 0.5 * atan2(v.x, v.y) + (int)(2.0 * random(0, 1)) * PI;
  float x = r * cos(theta);
  float y = r * sin(theta);
  return new PVector(x, y);
}

float cosh(float x) { return 0.5 * (exp(x) + exp(-x));}
float sinh(float x) { return 0.5 * (exp(x) - exp(-x));}

PVector sech(PVector p, float weight) {
  float d = cos(2.0*p.y) + cosh(2.0*p.x);
  if (d != 0)
    d = weight * 2.0 / d;
  return new PVector(d * cos(p.y) * cosh(p.x), -d * sin(p.y) * sinh(p.x));
}


PVector spherical(PVector p, float amount) {
  float r = 1/pow(getR(p), 2);
  float x = amount * p.x * r;
  float y = amount * p.y * r;
  return new PVector(x, y);
}


float getR(PVector p) {
  float xsq = p.x * p.x;
  float ysq = p.y * p.y;
  return sqrt(xsq + ysq);
}

float getTheta(PVector v) {
  return atan2(v.x, v.y);
}
