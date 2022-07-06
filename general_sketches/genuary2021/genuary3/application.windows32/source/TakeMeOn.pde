import processing.video.*;

Capture video;

void setup() {
  size(640, 480);  

  // Step 3. Initialize Capture object via Constructor
  video = new Capture(this, 640, 480);  
  video.start();
}

void captureEvent(Capture video) {  
  // Step 4. Read the image from the camera.  
  video.read();
}

void draw() {
  background(0);
  loadPixels();
  video.loadPixels();  
  for (int x = 0; x < video.width - 1; x += 1) {    
    for (int y = 0; y < video.height - 1; y += 1) {      
      // Calculate the 1D location from a 2D grid
      int loc1 = x + y * width;
      int loc2 = x + (y + 1) * width;
      int loc3 = (x + 1) + y * width;    
      float b1 = brightness(video.pixels[loc1]);
      float b2 = brightness(video.pixels[loc2]);
      float b3 = brightness(video.pixels[loc3]);
      float diff1 = abs(b1-b2);
      float diff2 = abs(b1-b3);
      
      if (diff1 < 10 && diff2 < 10) {
        pixels[loc1] = color(255);
      } else {
        pixels[loc1] = color(0);
      }
    }
  }
  updatePixels();  
}
