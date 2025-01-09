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

float b = PI;
float d = TWO_PI;

float A = -1.4;
float B = 1.0;
float C = 1.6;
float D = sin(0.5); // Using a constant approximation for global time-based sine
float E = .5;
float F = sin(.8);

void setup() {

  noFill();
  

  generateTiles();
  //generateHero1();
  //generateHero2();
  exit(); // End the program explicitly
}

void generateTiles() {
  float[][] coefficients = {
    {2 * PI, PI},
    {PI, PI},
    {PI, 2 * PI},
    {4 * PI, 2 * PI}
  };

  String[] sizes = {"small", "medium", "large"};
  int[] resolutions = {300, 600, 900};

  for (int i = 0; i < coefficients.length; i++) { // Loop over each coefficient set
    float[] coeff = coefficients[i];
    float a = coeff[0];
    float c = coeff[1];

    for (int j = 0; j < sizes.length; j++) { // Loop over each size
      String size = sizes[j];
      int res = resolutions[j];

      // Construct the filename according to the pattern: setX_size.png
      String fileName = "set" + (i + 1) + "_" + size + ".png";
      println("Writing: " + fileName);

      PGraphics pg = createGraphics(res, res);
      renderTilesToBuffer(pg, a, c, res, pal[i % pal.length]); // Cycle palette based on index
      pg.save("jane/" +fileName);
    }
  }
}


void generateHero1() {
  int width = 1600; // Hero resolution width
  int height = 1066; // Hero resolution height
  int attractors = 15; // Number of attractors to tile

  String fileName = "jane/hero_" + getTemporalName(sketchName, saveFormat);
  println("Writing hero: " + fileName);
  iterations = 360000;
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.colorMode(HSB, 360, 100, 100, 1);
  pg.background(0, 0, 100);
  float xOffset = random(-width/2, width/2);
  float limit = 10;
  float targetLimit = PI; // Clamp target at PI
  for (int i = 0; i < attractors; i++) {
    limit = lerp(limit, targetLimit, 0.05);
    float a = random(-limit, limit);
    float c = random(-limit, limit);
    float b = random(-limit, limit);
    float d = random(-limit, limit);
    
    float yOffset = i * (height / attractors) + random(-20, 20);
    float rotation = random(-0.1, 0.1); // Slight tilt
    color currentColor = pal[(int)random(pal.length)];

    pg.pushMatrix();
    pg.translate(width / 2f + xOffset, yOffset);
    pg.rotate(rotation);
    renderHeroToBuffer(pg, a, b, c, d, currentColor);
    pg.popMatrix();
  }

  pg.endDraw();
  pg.save(fileName);
}



void generateHero2() {
  int width = 1600; // Hero resolution width
  int height = 1066; // Hero resolution height
  int gridRows = 4; // Number of rows in the grid
  int gridCols = 8; // Number of columns in the grid

  String fileName = "jane/hero_grid_" + getTemporalName(sketchName, saveFormat);
  println("Writing hero grid: " + fileName);

  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.colorMode(HSB, 360, 100, 100, 1);
  pg.background(0, 0, 100);

  float cellWidth = width / float(gridCols);
  float cellHeight = height / float(gridRows);

  for (int row = 0; row < gridRows; row++) {
    for (int col = 0; col < gridCols; col++) {
      float a = PI * row;
      float c = PI * col;
      float xOffset = cellWidth * col + cellWidth / 2;
      float yOffset = cellHeight * row + cellHeight / 2;
      color currentColor = pal[(int)random(pal.length)];

      renderAttractorTile(pg, a, c, xOffset, yOffset, currentColor);
    }
  }

  pg.endDraw();
  pg.save(fileName);
}

void renderHeroToBuffer(PGraphics pg, float a, float b, float c, float d, color currentColor) {

  pg.noFill();
  pg.strokeWeight(.5);

  PVector position = new PVector(0, 0);

  for (int i = 0; i < iterations; i++) {
    float dx, dy;
    PVector transformed = clifford(position, A, B, C, D, E, F);
    position.mult(transformed.x + transformed.y);

    dx = sin(a * position.y) - cos(b * position.x);
    dy = sin(c * position.x) - cos(d * position.y);
    position.x = dx;
    position.y = dy;

    pg.stroke(currentColor);
    pg.point(scale * position.x, scale * position.y);
  }
}


void renderTilesToBuffer(PGraphics pg, float a, float c, int res, color currentColor) {
  pg.beginDraw();
  pg.background(#FFFFFF);
  pg.stroke(currentColor);

  pg.noFill();
  //pg.strokeWeight(.5);

  pg.translate(res / 2f, res / 2f); // Center the drawing
  pg.scale(res / 1000f); // Scale proportionally to resolution

  PVector position = new PVector(0, 0);
  iterations = 1000000;
  for (int i = 0; i < iterations; i++) {
    PVector transformed = clifford(position, A, B, C, D, E, F);
    position.mult(transformed.x + transformed.y);

    float dx = sin(a * position.y) - cos(b * position.x);
    float dy = sin(c * position.x) - cos(d * position.y);
    position.x = dx;
    position.y = dy;


    pg.point(scale * position.x, scale * position.y);
  }
  pg.endDraw();
}

void renderAttractorTile(PGraphics pg, float a, float c, float xOffset, float yOffset, color currentColor) {
  pg.pushMatrix();
  pg.translate(xOffset, yOffset);
  pg.scale(0.2); // Scale attractor to fit better within grid cell
  pg.noFill();
  pg.stroke(currentColor);
  pg.strokeWeight(0.75);
  iterations = 1600000;
  

  PVector position = new PVector(0, 0);
  for (int i = 0; i < iterations; i++) {
    PVector transformed = clifford(position, A, B, C, D, E, F);
    position.mult(transformed.x + transformed.y);
    float dx = sin(a * position.y) - cos(b * position.x);
    float dy = sin(c * position.x) - cos(d * position.y);
    position.x = dx;
    position.y = dy;

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

String getTemporalName(String prefix, String suffix) {
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}
