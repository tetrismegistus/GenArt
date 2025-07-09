import com.krab.lazy.*;

LazyGui gui;
PImage img;

float sat = 1.0; // Default saturation (1.0 means no change)
float brt = 1.0; // Default brightness (1.0 means no change)
String imgName = "PXL_20231015_220449078.MP.jpg";

String applyDither = "none";

void settings() {
  img = loadImage(imgName);  // Load the image
  size(img.width, img.height, P2D);       // Set the size of the window to the image's dimensions
}

void setup(){
  gui = new LazyGui(this);

}


void draw() {
  // quantize image
  background(255);
  sat = gui.slider("Saturation", sat, 0.0, 2.0); // Slider from 0.0 to 2.0
  brt = gui.slider("Brightness", brt, 0.0, 2.0); // Slider from 0.0 to 2.0

  
  if (gui.button("whiteNoise")) {
        applyDither = "whiteNoise"; // Set flag to apply diffusion
    }
    
      if (gui.button("singleRowDiffusion")) {
        applyDither = "singleRowDiffusion"; // Set flag to apply diffusion
    }


    switch(applyDither) {
        case "whiteNoise":
        adjustImageSaturationBrightness();
            whiteNoise(); // Your function to apply white noise dithering
            applyDither = ""; // Reset the flag after applying
            break;
        
        case "singleRowDiffusion":
        adjustImageSaturationBrightness();
            singleRowDiffusion(); // Your function to apply single row diffusion
            applyDither = ""; // Reset the flag after applying
            break;

        default:
            // Handle the case where no dithering is applied
            break;
    }

  
  image(img, 0, 0);
}




void adjustImageSaturationBrightness() {
   
  colorMode(HSB, 360, 100, 100, 1);
  img = loadImage(imgName);
  img.filter(GRAY);
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    color c = img.pixels[i];
    float h = hue(c);
    float s = sat * saturation(c);
    float b = brt * brightness(c);
    img.pixels[i] = color(h, s, b);
  }  
  img.updatePixels();
  
}


float linearize(float srgb) {
    if (srgb <= 0.04045) {
        return srgb / 12.92;
    } else {
        return pow((srgb + 0.055) / 1.055, 2.4);
    }
}
