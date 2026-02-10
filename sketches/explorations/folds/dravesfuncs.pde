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

PVector polar(PVector v, float amount) {
    float theta = getTheta(v);
    float r = getR(v);
    float x = amount * (theta/PI);
    float y = amount * (r - 1.0);
    return new PVector(x, y);
}

PVector handkerchief(PVector v, float amount) {
  float theta = getTheta(v);
  float r = getR(v);
  float x = r * (sin(theta + r));
  float y = cos(theta - r);
  return new PVector(amount * x, amount * y);
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

PVector heart(PVector v, float amount) {
  float theta = getTheta(v);
  float r = getR(v);
  float x = r * (sin(theta * r));
  float y = r * cos(theta * -r);
  return new PVector(x * amount, y * amount);
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

PVector disc(PVector v, float amount) {
  float theta = getTheta(v);
  float r = getR(v);
  float x = theta / PI * sin(PI * r);
  float y = theta / PI * cos(PI * r);
  return new PVector(amount * x, amount * y);
}

PVector spiral(PVector v, float amount) {
  float theta = getTheta(v);
  float r = getR(v);
  float fract_r = 1/r;
  float x = fract_r * cos(theta) + sin(r) * fract_r;
  float y = fract_r * sin(theta) - cos(r) * fract_r;
  return new PVector(amount * x, amount * y);
}

PVector diamond(PVector v, float amount) {
  float theta = getTheta(v);
  float r = getR(v);
  float x = sin(theta) * cos(r);
  float y = cos(theta) * sin(r);
  return new PVector(amount * x, amount * y);
}

PVector ex(PVector v, float amount) {
  float theta = getTheta(v);
  float r = getR(v);
  float p0 = sin(theta + r);
  float p1 = cos(theta - r);
  float x = r * pow(p0, 3) + pow(p1, 3) * r;
  float y = r * pow(p0, 3) - pow(p1, 3) * r;
  return new PVector(amount * x, amount * y);
}


PVector bent(PVector v, float amount) {
  PVector p = v.copy();
  if (v.x >= 0 && v.y >= 0) {
    p = new PVector(v.x * amount, v.y * amount);
  } else if (v.x < 0 && v.y >= 0) {
    p = new PVector(2.0 * v.x * amount, v.y * amount);
  } else if (v.x >= 0 && v.y < 0) {
    p = new PVector(v.x * amount, (v.y/2.0) * amount);
  } else if (v.x < 0 && v.y < 0) {
    p = new PVector(2.0 * v.x * amount, (v.y/2.0) * amount);
  }
  return p;
}


float waves_b = .3;
float waves_c = .5;
float waves_e = 1.0;
float waves_f = 1.0;
PVector waves(PVector v, float amount) {
  float x = v.x + waves_b * sin(v.y/pow(waves_c, 2));
  float y = v.y + waves_e * sin(v.x/pow(waves_f, 2));
  return new PVector(x * amount, y * amount);
}


PVector fisheye(PVector v, float amount) {
  float r = 2 / (getR(v) + 1);
  float x = r * v.x;
  float y = r * v.y;
  return new PVector(amount * x, amount * y);
}

PVector exponential(PVector v, float amount) {
  float factor = exp(v.x - 1.0);
  float x = factor * cos(PI * v.y);
  float y = factor * sin(PI * v.y);
  return new PVector(amount * x, amount * y);
}


PVector power(PVector v, float amount) {
  float r = getR(v);
  float theta = getTheta(v);
  float powR = pow(r, sin(theta));
  float x = cos(theta) * powR;
  float y = sin(theta) * powR;
  return new PVector(amount * x, amount * y);
}

PVector COS(PVector v, float amount)  {
      float x = cos(PI * v.x) * (float) Math.cosh(v.y);
      float y = -sin(PI * v.x) * (float) Math.sinh(v.y);
      return new PVector(amount * x, amount * y);
}

float rings_c = .5;
PVector rings(PVector v, float amount) {
  float r = getR(v);
  float theta = getTheta(v);
  float cSquare = pow(rings_c, 2);
  float factor = ((r + cSquare) % (2 * cSquare) - cSquare + r * (1 - cSquare));
  float x = cos(theta) * factor;
  float y = sin(theta) * factor;
  return new PVector(amount * x, amount * y);
  
}


float fan_c = .1;
float fan_f = .8;
PVector fan(PVector v, float amount) {
  float t = PI * pow(fan_c, 2);
  float theta = getTheta(v);
  float r = getR(v);
  float x = 0;
  float y = 0;
  if ((theta + fan_f) % t > t / 2) {
    x = r * (cos(theta - t/2));
    y = sin(theta - t/2);    
  } else if ((theta + fan_f) % t <= t / 2) {
    x = r * (cos(theta + t/2));
    y = sin(theta + t/2);   
  }

  return new PVector(amount * x, amount * y);
}


float blob_high = .9;
float blob_low = .1;
float blob_waves = 5;
PVector blob(PVector v, float amount) {
  float theta = getTheta(v);
  float r = getR(v);
  float factor = blob_low + ((blob_high - blob_low)/2) * (sin(blob_waves * theta) + 1);
  float x = r * factor * cos(theta);
  float y = r * factor * sin(theta);
  return new PVector(x * amount, y * amount);
}
