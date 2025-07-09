color baseColor = #1D3354;
color accentColor = #9ED8DB;
  float margin = width * 0.1;
  float boxX = margin;
  float boxY = margin;
  float boxW = width - 2 * margin;
  float boxH = height - 2 * margin;


void setup() {
  size(2500, 2500, P2D);
  colorMode(HSB, 360, 100, 100, 1);

}


void draw() {
  background(#FFFFFF);
  for (int i = 0; i < 5; i++) {
    jitter();   
  }
  save("grid-threadbox.png");
  noLoop();
}


void jitter() {
  float margin = width * 0.1;
  float boxX = margin;
  float boxY = margin;
  float boxW = width - 2 * margin;
  float boxH = height - 2 * margin;



  // Draw large base threadbox
  threadbox(boxX, boxY, boxW, boxH, 0, 3, baseColor);

  // Cell and grid layout
  float cellW = boxW * 0.05;
  float cellH = boxH * 0.05;
  float spacing = min(cellW, cellH) * 0.15;

  int cols = int((boxW + spacing) / (cellW + spacing));
  int rows = int((boxH + spacing) / (cellH + spacing));

  float totalGridW = cols * cellW + (cols - 1) * spacing;
  float totalGridH = rows * cellH + (rows - 1) * spacing;

  // Centered grid inside the large box
  float startX = boxX + (boxW - totalGridW) / 2;
  float startY = boxY + (boxH - totalGridH) / 2;

  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {

      // ORGANIC GAP using Gaussian distribution
      float drop = abs((float) randomGaussian());
      if (drop > 1.5) continue;

      // Position and distortions
      float jitterX = (float) randomGaussian() * spacing * 0.6;
      float jitterY = (float) randomGaussian() * spacing * 0.3;
      float px = startX + x * (cellW + spacing) + jitterX;
      float py = startY + y * (cellH + spacing) + jitterY;

      // Angle with some y-based drift
      float angle = map(noise(x * 0.1, y * 0.1), 0, 1, 0, 360);


      // Distance-based blend factor (optional hotspot targeting)
      float dx = x - cols / 2;
      float dy = y - rows / 2;
      float d = sqrt(dx * dx + dy * dy);
      float maxD = sqrt(sq(cols / 2) + sq(rows / 2));
      float blendAmt = constrain(map((float) randomGaussian() + map(d, 0, maxD, 0, 2), 0, 3, 0, 1), 0, 1);

      // Lerp between base and accent
      color c = lerpColor(baseColor, accentColor, blendAmt);

      // Draw the threadbox
      threadbox(px, py, cellW, cellH, angle, (int) 1, c);
    }
  }
}



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


void threadbox(float x, float y, float w, float h, float angleDegrees, float spacing, color c) {

  float angle = radians(angleDegrees);

  // Direction vector of the thread lines
  float dx = cos(angle);
  float dy = sin(angle);

  // Orthogonal sweep direction
  float ox = -dy;
  float oy = dx;

  // Sweep bounds
  float diag = dist(0, 0, w, h);

  for (float i = -diag; i <= diag; i += spacing) {
    float cx = x + w / 2 + i * ox;
    float cy = y + h / 2 + i * oy;

    // Start far away in both directions
    float x1 = cx - dx * diag;
    float y1 = cy - dy * diag;
    float x2 = cx + dx * diag;
    float y2 = cy + dy * diag;

    // Find clipped segment inside box bounds
    PVector[] clipped = clipLineToRect(x1, y1, x2, y2, x, y, w, h);
    if (clipped != null) {
      draftsmanLine(clipped[0].x, clipped[0].y, clipped[1].x, clipped[1].y, c);
    }
  }
}
PVector[] clipLineToRect(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {
  float xmin = rx;
  float xmax = rx + rw;
  float ymin = ry;
  float ymax = ry + rh;

  int code1 = computeOutCode(x1, y1, xmin, xmax, ymin, ymax);
  int code2 = computeOutCode(x2, y2, xmin, xmax, ymin, ymax);

  boolean accept = false;

  while (true) {
    if ((code1 | code2) == 0) {
      accept = true;
      break;
    } else if ((code1 & code2) != 0) {
      break;
    } else {
      float x = 0, y = 0;
      int outcodeOut = (code1 != 0) ? code1 : code2;

      if ((outcodeOut & 8) != 0) {           // top
        x = x1 + (x2 - x1) * (ymax - y1) / (y2 - y1);
        y = ymax;
      } else if ((outcodeOut & 4) != 0) {    // bottom
        x = x1 + (x2 - x1) * (ymin - y1) / (y2 - y1);
        y = ymin;
      } else if ((outcodeOut & 2) != 0) {    // right
        y = y1 + (y2 - y1) * (xmax - x1) / (x2 - x1);
        x = xmax;
      } else if ((outcodeOut & 1) != 0) {    // left
        y = y1 + (y2 - y1) * (xmin - x1) / (x2 - x1);
        x = xmin;
      }

      if (outcodeOut == code1) {
        x1 = x;
        y1 = y;
        code1 = computeOutCode(x1, y1, xmin, xmax, ymin, ymax);
      } else {
        x2 = x;
        y2 = y;
        code2 = computeOutCode(x2, y2, xmin, xmax, ymin, ymax);
      }
    }
  }

  if (accept) {
    return new PVector[]{new PVector(x1, y1), new PVector(x2, y2)};
  } else {
    return null;
  }
}

int computeOutCode(float x, float y, float xmin, float xmax, float ymin, float ymax) {
  int code = 0;
  if (x < xmin) code |= 1;
  else if (x > xmax) code |= 2;
  if (y < ymin) code |= 4;
  else if (y > ymax) code |= 8;
  return code;
}
