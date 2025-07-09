String sketchName = "mySketch";
String saveFormat = ".png";
int calls = 0;
long lastTime;
int iterations = 360000;
float scale = 125;
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

float b = PI * 10;
float d = 0.1;

void setup() {
  int width = 1100; 
  int height = 586; 
  int scaleFactor = 1; 
  int newWidth = width * scaleFactor;
  PGraphics pg = createGraphics(newWidth, height * scaleFactor);


  pg.smooth(4);
  pg.beginDraw();
  pg.colorMode(HSB, 360, 100, 100, 1);
  pg.background(0, 0, 100);
  pg.scale(scaleFactor); 
  int tileH = floor(height/1.5);
  int tileW = tileH * 2;

  PGraphics tile = createGraphics(tileW, tileH);
  
  tile.smooth(8);
  tile.beginDraw();
  tile.colorMode(HSB, 360, 100, 100, 1);
  tile.background(360, 0, 100); 
  
  float a = 21.88013; // Assign `a` from coefficients
  float c = -5.017582; // Assign `c` from coefficients
  
  color currentColor = pal[2];
  
  println("Attractor a: " + a + " b: " + b + " c: " + c + " d: " + d);     
  renderAttractorTile(tile, a, b, c, d, tileW/2, tileH/1.25, currentColor); // Pass `a` and `c`
  tile.endDraw();
  
  float x = (width - (width/32)) - tileW;
  float y = (height - tileH)/2;
  
  pg.image(tile, x, y, tileW, tileH);
  pg.endDraw();
  String fileName = getTemporalName(sketchName, saveFormat, b, d, 0, 0); // Coefficients not included
  pg.save("jane/" + fileName);
  exit();
}

void renderAttractorTile(PGraphics pg, float a, float b, float c, float d, float xOffset, float yOffset, color currentColor) {
  pg.pushMatrix();
  pg.translate(xOffset, yOffset);
  pg.noFill();
  pg.stroke(currentColor);
  
  pg.strokeWeight(.3);
  iterations = 1000000;

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
