private void blade(float x) {
  float flowerHeight = random(random(100, 200), random(550, 650));
  float size = random(10, 50);
  float curveFactor = height * size / 500;
  PVector p0 = new PVector(x, height);
  PVector p1 = new PVector(x + .25f * curveFactor, height - random(.15f,.35f) * flowerHeight);
  PVector p2 = new PVector(x + .5f * curveFactor, height - random(.75f, .75f) * flowerHeight);
  PVector p3 = new PVector(x + curveFactor, height - flowerHeight);

  stroke(0, 25.5f);
  drawBezier(p0, p1, p2, p3, size);
}

private void drawBezier(final PVector p0, final PVector p1, final PVector p2, final PVector p3, float weight) {
  int stemCInt = (int) random(stemC.length); 
  color stemColor = stemC[stemCInt];         
  float hu = hue(stemColor);
  float sa = saturation(stemColor);
  float br = brightness(stemColor);
  float tr = .5;
  for (float t = 0f; t <= 1f; t += 0.001f) {
    PVector p = PVector.mult(p0, (1 - t) * sq(1 - t));
    p.add(PVector.mult(p1, 3 * t * sq(1 - t)));
    p.add(PVector.mult(p2, 3 * sq(t) * (1 - t)));
    p.add(PVector.mult(p3, t * sq(t)));
    float sw = lerp(map(weight, 10, 50, 5, 10), map(weight, 10, 50, 1, 3), t);            
    Brush b = new Brush(sw, p.x, p.y, color(hu, sa, br, tr));
    b.render();
  }
}
    
