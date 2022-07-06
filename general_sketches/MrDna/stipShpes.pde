void stipCirc(float x1, float y1, float R, color c) {
  int cap = ((int) R * (int) R) * 4;
  for (int i = 0; i < cap; i++) {
    float r = R * sqrt(random(0, 1));
    float theta = random(0, 1) * 2 * PI;
    float x = (x1) + r * cos(theta);
    float y = (y1) + r * sin(theta);
    CompositePoint p1 = new CompositePoint(x, y);
    CompositePoint center = new CompositePoint(x1, y1);
    float d = p1.distance(center);
    float mapped_d = map(d, 0, R, 100, 1);
    float h = hue(c);
    

    stroke(color(h, saturation(c), mapped_d));
    strokeWeight(.5 + abs(randomGaussian()));
    point(x, y);
  }
 
}
