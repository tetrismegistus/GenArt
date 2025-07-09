void setup() {
  size(1000, 1000);
  background(20);
  
  // Set up typography
  PFont font = createFont("Helvetica-Bold", 32);
  textFont(font);
  textAlign(CENTER, CENTER);
  
  // Background gradient
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    int c = lerpColor(color(20, 20, 20), color(200, 50, 50), inter);
    stroke(c);
    line(0, y, width, y);
  }




  // Draw statement text
  
  String message = "Due to their removal of DEI programs,\n" +
                   "stopping fact checking,\n" +
                   "and donating to Trump administration.";
  

  // Add emphasis with dynamic shapes
  for (int i = 0; i < 200; i++) {
    float x = random(width);
    float y = random(height);
    float r = random(10, 30);
    noStroke();
    fill(random(200, 255), 0, 0, 100);
    ellipse(x, y, r, r);
  }

  // Highlight the message with lines
  stroke(255, 50, 50, 150);
  strokeWeight(2);
  
    // Draw title text
  fill(255);
  textSize(48);
  text("Deleting my instagram in 2 days", width / 2, height / 5);
  
    // Draw statement box
  fill(0, 0, 0);
  noStroke();
  rectMode(CENTER);
  rect(width / 2, height / 2, width * 0.8, height * 0.4);


  fill(255);
  textSize(32);
  text(message, width / 2, height / 2);
}
