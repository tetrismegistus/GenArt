// Step 1. Import the video library
import processing.video.*;

// Step 2. Declare a Capture object
Capture video;
PFont mono;

int fontHeight = 16;
float fontWidth;

String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

void setup() {
  size(640, 480);  

  // Step 3. Initialize Capture object via Constructor
  video = new Capture(this, 640, 480);  
  video.start();

  mono = createFont("Akira-Regular.ttf", fontHeight);
  String testChar = "A";
  fontWidth = textWidth(testChar);
  textFont(mono);
}

// An event for when a new frame is available
void captureEvent(Capture video) {  
  // Step 4. Read the image from the camera.  
  video.read();
}
void draw() {
  background(0);
  loadPixels();
  video.loadPixels();  

  for (int x = 0; x < video.width; x += (fontWidth + 2)) {    
    for (int y = 0; y < video.height; y += 8) {      
      // Calculate the 1D location from a 2D grid
      int loc = x + y * video.width;      

      // Get the red, green, blue values from a pixel      
      float r = red  (video.pixels[loc]);      
      float g = green(video.pixels[loc]);      
      float b = blue (video.pixels[loc]);      

      // Make a new color and set pixel in the window      
      color c = color(r, g, b);    
      fill(c);
      char ch = chars.charAt((int) random(0, chars.length()));
      text(ch, x, y);
    }
  }
  
}

void mousePressed() {
  save("test.png");
}
