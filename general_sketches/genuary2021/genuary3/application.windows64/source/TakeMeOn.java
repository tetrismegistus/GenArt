import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TakeMeOn extends PApplet {



Capture video;

public void setup() {
    

  // Step 3. Initialize Capture object via Constructor
  video = new Capture(this, 640, 480);  
  video.start();
}

public void captureEvent(Capture video) {  
  // Step 4. Read the image from the camera.  
  video.read();
}

public void draw() {
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
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TakeMeOn" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
