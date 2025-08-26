String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float off = 0.01;   // spatial scale for field sampling
float PL  = 2;      // contour march step length

float border = .1;  // current iso target at seed
float ix, iy;

OpenSimplexNoise noise;

// ---- fBM params (tweak these for “trippy” contours) ----
int   FBM_OCTAVES    = 4;
float FBM_LACUNARITY = 2.0;
float FBM_GAIN       = 0.5;

void setup() {
  size(1500, 1500);
  colorMode(HSB, 360, 100, 100, 1);
  noise = new OpenSimplexNoise((long) random(0, 255));
}

void draw() {
  background(#c2f2f2);

  println("parachutes");
  for (int i = 50; i < width - 50; i += 10) {
    dropAgent(i, height - 50);
  }
  println("deployed");

  // margins
  fill(#E0E1E4); noStroke();
  rect(0, 0, width, 50);
  rect(0, height - 50, width, 50);
  rect(0, 0, 50, height);
  rect(width - 50, 0, 50, height);

  // grid (draftsman outlines)
  stroke(0, 0, 0, .5); strokeWeight(.1); noFill();
  for (int x = 50; x < width - 50; x += 50) {
    for (int y = 50; y < height - 50; y += 50) {
      rectOutline(x, y, 50, 50, color(0, 0, 0));
    }
  }

  // labels
  textSize(10); fill(0);
  int degreesLabel = (int) random(70);
  for (int x = 50; x < width - 50; x += 50) text(degreesLabel++ + "°", x, 48);

  degreesLabel = (int) random(70);
  pushMatrix(); translate(47, 950); rotate(radians(270));
  for (int x = 0; x < 900; x += 50) text(degreesLabel++ + "°", x, 0);
  popMatrix();

  // corner tick borders
  pushMatrix(); translate(50, 50);  drawBorder(); popMatrix();
  pushMatrix(); translate(50, 950); drawBorder(); popMatrix();
  pushMatrix(); translate(50, 50);  rotate(radians(90)); drawBorder(); popMatrix();
  pushMatrix(); translate(950, 50); rotate(radians(90)); drawBorder(); popMatrix();

  noLoop();
}

void drawBorder() {
  for (int x = 0; x < 900; x += 50) {
    fill(#ad776d); stroke(#ad776d); rect(x, 0, 25, 2);
    fill(0);       stroke(0);       rect(x + 25, 0, 25, 2);
  }
}

void dropAgent(float x, float y) {
  float agentX = x;
  float agentY = y;

  // rise until we enter the iso band vicinity (using fBM)
  float ISO = 0.5;
  while (fbm01(agentX * off, agentY * off) < ISO - 0.01 && noContourNear(agentX, agentY)) {
    agentY--;
    if (agentY <= 50) break;
  }

  // seed and render the contour at the landing point
  fill(#f5f3dc);
  strokeWeight(.1);
  if (noContourNear(agentX, agentY)) {
    stroke(#ad776d);
    renderContour(agentX, agentY);
  }

  // vertical trace (read pixels once for speed)
  noFill();
  loadPixels();
  float lastY = agentY;
  for (float ny = agentY; ny > 50; ny--) {
    int ixp = (int) agentX;
    int iyp = (int) ny;
    if (ixp < 0 || ixp >= width || iyp < 0 || iyp >= height) continue;
    int idx = ixp + iyp * width; // fixed: use width, not height
    if (pixels[idx] == #f5f3dc && noContourNear(agentX, ny)) {
      lastY = ny;
    } else {
      draftsmanLine(agentX, lastY, agentX, ny, color(0, 0, 0));
      lastY = ny;
    }
  }
}

boolean noContourNear(float x, float y) {
  boolean valid = true;
  loadPixels();
  for (int j = 1; j < 15; j++) {
    for (int nA = 0; nA < 360; nA += 1) {
      float nX = j * cos(radians(nA)) + x;
      float nY = j * sin(radians(nA)) + y;
      int ixp = (int) nX, iyp = (int) nY;
      if (ixp < 0 || ixp >= width || iyp < 0 || iyp >= height) continue;
      int idx = ixp + iyp * width;
      if (pixels[idx] == #ad776d) { valid = false; break; }
    }
    if (!valid) break;
  }
  return valid;
}

void renderContour(float nx, float ny) {
  ix = nx;
  iy = ny;

  // target iso value at seed (normalized fBM)
  border = fbm01(ix * off, iy * off);

  float d  = 0;
  float sx = ix, sy = iy;

  for (int i = 0; i < 50000; i++) {
    float od = d;
    float ox = ix, oy = iy;

    // angular search for next point on iso-contour
    for (d = od + HALF_PI; (d > od - HALF_PI && !nn()) || d == od + HALF_PI; d -= .17) {
      ix = ox + PL * cos(d);
      iy = oy - PL * sin(d);
    }

    draftsmanLine(ox, oy, ix, iy, color(#ad776d));

    if (dist(ix, iy, sx, sy) < PL && i > 1) {
      if (i > 4) draftsmanLine(ix, iy, sx, sy, color(#ad776d)); // close loop
      break;
    }
  }
  noLoop();
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));
}

String getTemporalName(String prefix, String suffix) {
  long time = System.currentTimeMillis();
  if (lastTime == time) { calls++; } else { lastTime = time; calls = 0; }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}

boolean nn() {
  // compare normalized fBM at current point to the seed iso-value “border”
  return abs(fbm01(ix * off, iy * off) - border) < 0.02;
}

/* -------------------------
   Helpers
   ------------------------- */

// Map your fbm_warp output to [0,1] for stable iso tests.
// For octaves=4, gain=0.5 the max amplitude ~ 1.875.
float fbm01(float x, float y) {
  float raw = fbm_warp(x, y, FBM_OCTAVES, FBM_LACUNARITY, FBM_GAIN);
  return (raw * 0.5 / 1.875) + 0.5;
}
