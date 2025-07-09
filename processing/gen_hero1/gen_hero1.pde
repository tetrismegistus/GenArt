String sketchName = "mySketch";
String saveFormat = ".png";
int calls = 0;
long lastTime;
int iterations = 360000;
float scale = 200;
color[] pal = new color[] {
 #B55239,
 #221E11,
 #7DB295,
 #603A2B,
};

float A = -1.4;
float B = 1.0;
float C = 1.6;
float D = sin(0.5); // Using a constant approximation for global time-based sine
float E = .5;
float F = sin(.8);

float b = 2.71;
float d = -1.05;

void setup() {
int width = 3840; // Reduce width 
int height = 2160; 

PGraphics pg = createGraphics(width, height);
float b = PI;
float d = TWO_PI;
float[][] coefficients = {
  {1.2, -1.5},
  {-2.1, 0.9},
  {0.5, -0.7},
  {1.7, 2.4},
  {-0.9, -1.8},
  {3.1, 0.6},
  {1.1, 0.6}
};

pg.smooth(4);
pg.beginDraw();
pg.colorMode(HSB, 360, 100, 100, 1);
pg.background(0, 0, 100);

int numAttractors = coefficients.length; 
float margin = width / 10;  // Reduce margin proportionally
float xpage = width - 2 * margin;
float spacing = xpage / numAttractors; // Keep even spacing
float tileSize = spacing * 0.9; // Slightly shrink tile to prevent overlap

for (int j = 4; j < numAttractors; j++) {
  int tileW = floor(tileSize);
  int tileH = tileW;
  PGraphics tile = createGraphics(tileW, tileH);
  tile.smooth(8);
  tile.beginDraw();
  tile.colorMode(HSB, 360, 100, 100, 1);
  tile.background(0, 0, 100); 
  float a = coefficients[j][0];
  float c = coefficients[j][1];
  color currentColor = pal[j % pal.length];
  println("Attractor " + j + " a: " + a + " c: " + c);     

  // Adjust scale dynamically
  float newScale = tileW / 3.5; // Keeps attractor size in proportion

  renderAttractorTile(tile, a, b, c, d, tileW/2, tileH/2, currentColor, newScale);
  tile.endDraw();
  
  float x = margin + (spacing * j);
  float y = (height - tileSize) / 2;
  pg.image(tile, x, y, tileSize, tileSize);
}

pg.endDraw();

String fileName = getTemporalName(sketchName, saveFormat, b, d, 0, 0);
pg.save("jane/" + fileName);
exit();

}



void renderAttractorTile(PGraphics pg, float a, float b, float c, float d, float xOffset, float yOffset, color currentColor, float scale) {
  pg.pushMatrix();
  pg.translate(xOffset, yOffset);
  pg.noFill();
  pg.stroke(currentColor);
  pg.strokeWeight(.3);
  iterations = 1500000;

  PVector position = new PVector(0, 0);
  for (int i = 0; i < iterations; i++) {
    float dx = sin(a * position.y) - cos(b * position.x);
    float dy = sin(c * position.x) - cos(d * position.y);
    position.x = dx + randomGaussian() * .003;
    position.y = dy + randomGaussian() * .003;
    pg.point(scale * position.x, scale * position.y);
  }
  pg.popMatrix();
}


PVector clifford(PVector p, float A, float B, float C, float D, float E, float F) {
  return new PVector(
    sin(A * p.y) + B * cos(A * p.x),
    sin(C * p.x) + D * cos(C * p.y),
    sin(E * p.x) + F * cos(E * p.y)
  );
}

String getTemporalName(String prefix, String suffix, float a, float b, float c, float d) {
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls++;
  } else {
    lastTime = time;
    calls = 0;
  }
  // Format coefficients into the filename
  String coefficients = String.format("_a%.2f_b%.2f_c%.2f_d%.2f", a, b, c, d);
  return prefix + coefficients + time + (calls > 0 ? "-" + calls : "") + suffix;
}
