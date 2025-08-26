void draftsmanLine(float x1, float y1, float x2, float y2, color baseColor) {
  float distance = dist(x1, y1, x2, y2);
  int steps = max(1, int(distance * 1.5));

  float baseHue = hue(baseColor);
  float baseSat = saturation(baseColor);
  float baseBrt = brightness(baseColor);

  float hueScale = 0.01;
  float satScale = 0.2;
  float brtScale = 0.3;
  float weightScale = .05;
  float baseNoiseOffset = randomGaussian() * 10;

  for (int j = 0; j < 2; j++) {
    for (int i = 0; i <= steps; i++) {
      float t = i / float(steps);
      float x = lerp(x1, x2, t);
      float y = lerp(y1, y2, t);
      float n = baseNoiseOffset + t;

      float h = (baseHue + map(noise(x * hueScale, n), 0, 1, -100, 100) + 360) % 360;
      float s = constrain(baseSat + map(noise(x * satScale, n), 0, 1, -20, 20), 0, 100);
      float b = constrain(baseBrt + map(noise(x * brtScale, n), 0, 1, -20, 20), 0, 100);
      float w = map(noise(x * weightScale, n), 0, 1, .1, 2);

      stroke(h, s, b, .2);
      strokeWeight(w);
      point(x + randomGaussian() * .1, y + randomGaussian() * .1);
    }
  }
}

/* helper: draw a rectangle outline using draftsmanLine */
void rectOutline(float x, float y, float w, float h, color c) {
  draftsmanLine(x, y, x + w, y, c);
  draftsmanLine(x + w, y, x + w, y + h, c);
  draftsmanLine(x + w, y + h, x, y + h, c);
  draftsmanLine(x, y + h, x, y, c);
}
