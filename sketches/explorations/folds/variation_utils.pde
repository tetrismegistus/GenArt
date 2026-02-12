import processing.core.PApplet;   
    
public  float omega() {
    return PI * floor(random(2));
}

public  float lambda() {
    return 2 * floor(random(2)) - 1f;
}

public float psi() {
    return random(1);
}

public static float getR(PVector p) {
  float xsq = p.x * p.x;
  float ysq = p.y * p.y;
  return sqrt(xsq + ysq);
}

public static float getTheta(PVector v) {
  return atan2(v.x, v.y);
}

PVector sinusoidal(PVector v, float amount) {
  return new PVector(amount * sin(v.x), amount * sin(v.y));
}
