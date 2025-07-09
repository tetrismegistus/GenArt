void setup() {
  size(1000, 1000);
  background(#fdf0d5);
  drawGrid();
  drawAxes();
  drawCurve();
}

void drawGrid() {
  stroke(#669bbc);  // Light gray for grid
  strokeWeight(.5);
  
  // Vertical grid lines
  for (int x = 50; x < width; x += 50) {
    line(x, 0, x, height);
  }
  
  // Horizontal grid lines
  for (int y = 50; y < height; y += 50) {
    line(0, y, width, y);
  }
}

void drawAxes() {
  stroke(#003049);
  strokeWeight(2);
  
  // Y-axis
  line(50, 50, 50, height-50);
  // Y-axis arrow
  line(50, 50, 45, 60);
  line(50, 50, 55, 60);
  
  // X-axis
  line(50, height-50, width-50, height-50);
  // X-axis arrow
  line(width-50, height-50, width-60, height-55);
  line(width-50, height-50, width-60, height-45);
}

void drawCurve() {
  stroke(255, 0, 0);  // Blue curve
  strokeWeight(2);
  noFill();
  
  beginShape();
  float amplitude = 50;
  float frequency = 0.05;
  float downwardSpeed = 0.9;
  
  for (float x = 50; x < width-50; x++) {
    // Calculate y position combining sine wave and downward trend
    float normalizedX = x - 50;  // Adjust for axis position
    float y = 100 - (  // Flip Y coordinates and adjust for axis
      amplitude * sin(frequency * normalizedX) - 
      (normalizedX * downwardSpeed)
    );
    
    vertex(x, y);
  }
  endShape();
}
