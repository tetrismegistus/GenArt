String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

PImage elmo;

// Masked images cache to improve performance (optional)
HashMap<Float, PImage> maskedImages = new HashMap<Float, PImage>();

void setup() {
  size(2000, 2000);
  elmo = loadImage("elmo.png");
  noLoop();
}

void draw() {
  background(#DDECF9);
  
  // Start the spiral from the center with initial parameters
  float initialX = width / 2;
  float initialY = height / 2;
  float initialTheta = 0.0;
  float initialRadius = .01; // Starting radius
  int initialDepth = 100;
  
  displayElmos(initialX, initialY, initialTheta, initialRadius, initialDepth);
}

void displayElmos(float x, float y, float theta, float radius, int depth) {
  if (depth <= 0) return;
  
  // Calculate intensity based on depth
  float intensity = map(depth, 0, 100, 255, 50); // Adjusted for visibility
  tint(255, intensity, intensity, 150); // Adjusted alpha for transparency
  
  pushMatrix();
  translate(x, y);
  rotate(theta);
  
  // Scale the image based on depth
  float scaleFactor = map(depth, 0, 100, 1.0, 0.3); // From full size to smaller
  
  // Obtain the circular masked image (with caching)
  PImage circularImage = getCircularImage(elmo, scaleFactor);
  
  imageMode(CENTER);
  image(circularImage, 0, 0);
  popMatrix();
  
  // Increment parameters for the spiral
  float angleIncrement = 0.25; // Controls spiral tightness
  float radiusIncrement = 20; // Controls spiral spacing
  
  // Calculate new theta and radius
  float newTheta = theta + angleIncrement;
  float newRadius = radius + radiusIncrement * 0.075; // Gradually increase radius
  
  // Calculate new position using polar coordinates
  float newX = x + newRadius * cos(newTheta);
  float newY = y + newRadius * sin(newTheta);
  
  // Recursive call with updated parameters
  displayElmos(newX, newY, newTheta, newRadius, depth - 1);
}

// Helper function to create a circular masked image
PImage getCircularImage(PImage img, float scaleFactor) {
  // Check if a masked image with the same scaleFactor already exists
  if (maskedImages.containsKey(scaleFactor)) {
    return maskedImages.get(scaleFactor);
  }
  
  // Calculate the new size based on scaleFactor
  int diameter = (int)(img.width * scaleFactor);
  
  // Create a PGraphics object for the mask
  PGraphics pg = createGraphics(diameter, diameter);
  pg.beginDraw();
  pg.background(0); // Black background for mask
  pg.noStroke();
  pg.fill(255); // White circle for mask
  pg.ellipseMode(CENTER);
  pg.ellipse(diameter / 2, diameter / 2, diameter, diameter);
  pg.endDraw();
  
  // Create a copy of the original image and resize it
  PImage scaledImg = img.copy();
  scaledImg.resize(diameter, diameter);
  
  // Apply the mask
  scaledImg.mask(pg.get());
  
  // Cache the masked image
  maskedImages.put(scaleFactor, scaledImg);
  
  return scaledImg;
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

void keyReleased() {
  if (key == 's' || key == 'S') {
    saveFrame(getTemporalName(sketchName, saveFormat));
  }
}
