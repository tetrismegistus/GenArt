import processing.svg.*;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float[][] grid;
float[][] averages2;
int left_x;
int right_x; 
int top_y; 
int bottom_y;
int resolution, num_columns, num_rows;
float scale = 1 / 100.;

color[] p = {#173753, #6daedb, #2892d7, #1b4353, #1d70a2};
ArrayList<Circle> circles = new ArrayList<>(); // To store packed circles

void setup() {
  size(2400, 1400);
  colorMode(HSB, 360, 100, 100, 1);
  
  left_x = 0;
  right_x = width; 
  top_y = int(height * -0.5); 
  bottom_y = int(height * 1.5);
  resolution = int(width * 0.01); 
  num_columns = (right_x - left_x) / resolution; 
  num_rows = (bottom_y - top_y) / resolution;
  
  grid = new float[num_columns][num_rows];
  
  // Calculate the flow field for the entire canvas
  ArrayList<Float> thetas = new ArrayList<>();
  
  for (int x = 0; x < num_columns; x++) {
    for (int y = 0; y < num_rows; y++) {            
      float theta = calculateTheta(x, y);
      thetas.add(theta);
    }
  } 
  
  int cidx = 0;
  for (int x = 0; x < num_columns; x++) {
    for (int y = 0; y < num_rows; y++) {            
      grid[x][y] = thetas.get(cidx);
      cidx++;
    }
  }
  
  // Circle packing
  int maxCircles = 1000; // Number of circles to generate
  for (int i = 0; i < maxCircles; i++) {
    Circle c = createPackedCircle();
    if (c != null) {
      circles.add(c);
    }
  }
}

void draw() {
  background(#edf7f6);
  strokeWeight(.25);
  
  // Visualize the packed circles (optional)
  for (Circle c : circles) {
    noFill();
    stroke(0, 0, 0, 0.1); // Light circle outline
    ellipse(c.x, c.y, c.r * 2, c.r * 2); // Visualize the packed circles
  }

for (int j = 0; j < 2000; j++) {
  PVector position = new PVector(random(0, width - 100), random(0, height - 100));

  noFill();
  stroke(p[(int) random(p.length)]);

  int cap = 1000;
  for (int i = 0; i < cap; i += 1) {
    // Check if the point is inside any packed circle for drawing
    boolean inAnyCircle = false;
    for (Circle c : circles) {
      if (dist(position.x, position.y, c.x, c.y) <= c.r) {
        inAnyCircle = true;
        break;
      }
    }

    if (inAnyCircle) {
      if (cap % 10 == 0) {
        line(position.x - randomGaussian() * 5, position.y, position.x + randomGaussian() * 5, position.y);
      }
    }

    // Flow field calculations continue regardless of the region
    float x_offset = position.x - left_x;
    float y_offset = position.y - top_y;
    int column_index = int(x_offset / resolution);
    int row_index = int(y_offset / resolution);

    if (column_index < 0 || column_index >= num_columns || row_index < 0 || row_index >= num_rows) {
      break; // Stop the loop if out of bounds
    }

    float angle = grid[column_index][row_index];
    position.add(PVector.fromAngle(TWO_PI * int(TWO_PI * position.x / width * angle) / (TWO_PI * position.x / width)).mult(.5));


    
  }
}

  save(getTemporalName(sketchName, saveFormat));
  noLoop();
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
}

String getTemporalName(String prefix, String suffix){
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}

float calculateTheta(int x, int y) {
  float progress = map(x, 0, width/4, 0, 1); // Map x to a 0-1 range across the grid
  float transitionScale = lerp(0.1, scale, progress); // Interpolate scale based on progress
  
  float pureNoise = noise(x * 0.1, y * 0.1); // Pure noise with scale 0.1
  float fancyNoise = noise(100. * noise(x * transitionScale, y * transitionScale), 
                           0.1 * noise(x * transitionScale, y * transitionScale, random(min(width, height)) * scale));
  
  // Blend pureNoise and fancyNoise based on progress
  return lerp(pureNoise, fancyNoise, progress);
}


// Circle class for packing
class Circle {
  float x, y, r;
  
  Circle(float x, float y, float r) {
    this.x = x;
    this.y = y;
    this.r = r;
  }
}

// Create a packed circle
Circle createPackedCircle() {
  for (int attempts = 0; attempts < 1000; attempts++) {
    float x = random(width);
    float y = random(height);
    float r = random(20, 150); // Circle radius range
    
    boolean overlapping = false;
    for (Circle c : circles) {
      if (dist(x, y, c.x, c.y) < c.r + r) {
        overlapping = true;
        break;
      }
    }
    
    if (!overlapping) {
      return new Circle(x, y, r);
    }
  }
  return null; // No valid circle found
}
