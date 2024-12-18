String sketchName = "mySketch";
String saveFormat = ".png";
int calls = 0;
long lastTime;
int iterations = 360000;
float scale = 200;
color[] pal = new color[] {
  #240115, #de3c4b, #2f131e
};

float b = PI;
float d = TWO_PI;

int gridRows = 4; // Number of rows in the grid
int gridCols = 4; // Number of columns in the grid
float[] aValues = {1 * PI, 2 * PI, 3 * PI, 4 * PI}; // Values for a
float[] cValues = {1 * PI, 2 * PI, 3 * PI, 4 * PI}; // Values for c

float A = -1.4;
float B = 1.0;
float C = 1.6;
float D = sin(0.5); // Using a constant approximation for global time-based sine
float E = .5;
float F = sin(.8);

float rotationAngle = sin(0.5); // Constant angle for rotation

void setup() {
  size(1000, 1000);
  colorMode(HSB, 360, 100, 100, 1);
  noFill();
  background(0, 0, 100);
  renderGrid();
  saveFrame(getTemporalName(sketchName, saveFormat));
}

void renderGrid() {
  float cellWidth = width / 4.25;
  float cellHeight = height / 4.25;

  for (int row = 0; row < gridRows; row++) {
    for (int col = 0; col < gridCols; col++) {
      float a = aValues[row % aValues.length];
      float c = cValues[col % cValues.length];
      
      pushMatrix();
      translate(col * cellWidth + cellWidth / 10, row * cellHeight + cellHeight /10); // Shift up and left
      scale(0.25); // Scale down attractor to fit within grid cell
      stroke(pal[int(random(pal.length))]);
      renderAttractor(a, c);
      popMatrix();
    }
  }
}

void renderAttractor(float a, float c) {
  PVector position = new PVector(0, 0);
  for (int i = 0; i < iterations; i++) {
    PVector transformed = clifford(position, A, B, C, D, E, F);
    position.x *= transformed.x;
    position.y *= transformed.y;

    float dx = sin(a * position.y) - cos(b * position.x);
    float dy = sin(c * position.x) - cos(d * position.y);
    position.x = dx;
    position.y = dy;


    point(scale * position.x + width / 2f, scale * position.y + height / 2f);
  }
}

PVector rotateVector(PVector p, float angle) {
  float cosA = cos(angle);
  float sinA = sin(angle);
  return new PVector(
    p.x * cosA - p.y * sinA,
    p.x * sinA + p.y * cosA
  );
}

PVector clifford(PVector p, float A, float B, float C, float D, float E, float F) {
  return new PVector(
    sin(A * p.y) + B * cos(A * p.x),
    sin(C * p.z) + D * cos(C * p.y),
    sin(E * p.x) + F * cos(E * p.z)
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
