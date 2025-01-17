import processing.core.PApplet;   
    
public static float omega() {
    return PI * floor(pApplet.random(2));
}

public static float lambda() {
    return 2 * floor(pApplet.random(2)) - 1f;
}

public static float psi() {
    return pApplet.random(1);
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
