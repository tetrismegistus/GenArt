PImage inputImage;
int skipSize = 10;
int skipSize2 = 100;
int calls = 0;
long lastTime;

void setup() {
  size(900, 1800);
  inputImage = loadImage("a13.png");
  colorMode(HSB, 360, 100, 100, 1);
  //blendMode(SUBTRACT);
  //kitten.filter(GRAY);
  rectMode(CENTER);
  ellipseMode(CENTER);
  noLoop();
  noFill();  
}


void draw() {
  background((20 + 180) % 360, 20, 49);
  
  for (int y = 100; y < inputImage.height - 100; y+=skipSize2) {
    for (int x = 100; x < inputImage.width - 100; x+=skipSize2) {      
      color pix = inputImage.pixels[index(x, y)];
      float hue = hue(pix);
      float brt = brightness(pix);
      float sat = saturation(pix);
      stroke(pix);
      fill(pix);
      
      float cAmt = 5;
      float mag = 1;
      float c1X = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c1Y = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c2X = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c2Y = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c3X = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c3Y = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c4X = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c4Y = constrain(randomGaussian() * mag, -cAmt, cAmt);
      
      
      quad(x + c1X, y + c1Y, x+skipSize2+c2X, y+c2Y, x+skipSize2+c3X, y+skipSize2 + c3Y, x + c4X, y+skipSize2 + c4Y);
      endShape();
      //uare(x, y, skipSize2);
      
      //point(x, y);      
       
    
    }
    
  }
  
  for (int y = 100; y < inputImage.height - 100; y+=skipSize) {
    for (int x = 100; x < inputImage.width - 100; x+=skipSize) {
      
      color pix = inputImage.pixels[index(x, y)];
      float hue = hue(pix);
      float brt = brightness(pix);
      float sat = saturation(pix);
      stroke(pix); 
      if (((hue > 63 && hue < 83))) {       
      fill(hue, brt, sat, .5);
      noStroke();
      float cAmt = 30;
      float mag = skipSize;
      float c1X = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c1Y = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c2X = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c2Y = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c3X = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c3Y = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c4X = constrain(randomGaussian() * mag, -cAmt, cAmt);
      float c4Y = constrain(randomGaussian() * mag, -cAmt, cAmt);
      
      beginShape();
      vertex(x + c1X, y + c1Y);
      vertex(x+skipSize+c2X, y+c2Y);
      vertex(x+skipSize+c3X, y+skipSize + c3Y);
      vertex(x + c4X, y+skipSize + c4Y);
      //quad(x + c1X, y + c1Y, x+skipSize+c2X, y+c2Y, x+skipSize+c3X, y+skipSize + c3Y, x + c4X, y+skipSize + c4Y);
      endShape();
      }
    
    }
  }
  save(getTemporalName("output/scrib_",".png"));
}


int index(int x, int y) {
  return x + y * inputImage.width;
}

String getTemporalName(String prefix, String suffix){
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if(lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}
