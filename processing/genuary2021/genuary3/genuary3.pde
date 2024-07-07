PImage card;

import processing.video.*;

Capture video;

void setup() {
  size(640, 480);  
  video = new Capture(this, 640, 480);  
  video.start();


}

void captureEvent(Capture video) {  
  // Step 4. Read the image from the camera.  
  video.read();
}

void keyPressed() {
  save("cap.png");
}

void draw() {
  background(255);
  //loadPixels();
  video.loadPixels();  
  for (int x = 0; x < width - 1; x += 1) {    
    for (int y = 0; y < height - 1; y += 1) {      
      // Calculate the 1D location from a 2D grid
      int loc1 = x + y * width;
      int loc2 = x + (y + 1) * width;
      int loc3 = (x + 1) + y * width;    
      float b1 = brightness(video.pixels[loc1]);
      float b2 = brightness(video.pixels[loc2]);
      float b3 = brightness(video.pixels[loc3]);
      float diff1 = abs(b1-b2);
      float diff2 = abs(b1-b3);
      
      noFill();
      stroke(video.pixels[loc1]);
      
      if (diff1 < 1 && diff2 < 1) {
        stroke(video.pixels[loc1]);
        square(x, y, random(1, 50));
      } else {
        stroke(video.pixels[loc1], 25);
        square(x, y, random(1, 5));
      }
    }
  }


  //updatePixels();  
}
