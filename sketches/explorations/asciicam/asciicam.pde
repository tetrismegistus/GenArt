// Step 1. Import the video library
import processing.video.*;

// Step 2. Declare a Capture object

PFont mono;

int fontHeight = 16;
float fontWidth;

PImage testImage;

String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

void setup() {
  size(1050, 1050);
  testImage = loadImage("mySketch1676420693378.png");

  // Step 3. Initialize Capture object via Constructor

  mono = createFont("SpaceMono-Bold.ttf", 11);
  String testChar = "A";
  fontWidth = textWidth(testChar);
  textFont(mono);
}

// An event for when a new frame is available

void draw() {
  
  String[] lines = loadStrings("1321-0.txt");
  int l = 0;
  int ca = 0;

  background(0);
  loadPixels();
  testImage.loadPixels();  

  for (int y = 0; y < testImage.height; y += 8) {
  for (int x = 0; x < testImage.width; x += (fontWidth + 2)) {    
        
      // Calculate the 1D location from a 2D grid      
      int llength = lines[l].length();       
      while (llength == 0) {
        l++;
        llength = lines[l].length();      
      }
      int loc = x + y * testImage.width;      

      // Get the red, green, blue values from a pixel      
      float r = red  (testImage.pixels[loc]);      
      float g = green(testImage.pixels[loc]);      
      float b = blue (testImage.pixels[loc]);      

      // Make a new color and set pixel in the window      
      color c = color(r, g, b);    
      fill(c);      
      String line = lines[l];      
      
      text(line.charAt(ca), x, y);
      ca++;
      if (ca >= llength) {
        ca = 0;
        l++;
      }
    }
  }
  save("test.png");
  noLoop();
}

void mousePressed() {
  save("test.png");
}
