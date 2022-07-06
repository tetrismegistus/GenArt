color tc;
String photoName = "pic4.jpg";
PImage photo;
float tileW;
float tileH;
float numTiles = 128;

void setup() {
  size(2048, 1536);
  colorMode(HSB, 360, 100, 100, 1);
  tc = color(50, 50, 50);
  photo = loadImage(photoName);
  tileW = (1024/numTiles);
  tileH = (768/numTiles);
}

void draw() {
  background(0);
  photo.loadPixels();
  for (int x=0; x<1024; x+=tileW) {
    for (int y=0; y<768; y+=tileH) {
      color c = photo.pixels[y*1024+x];
      fill(c, .5);
      noStroke();
      rect(x * 2, y * 2, tileW * 2, tileH * 2);
      drawTile(x * 2, y * 2, tileW * 2, tileH * 2, c);
    }  
  }
  
  for (int x=0; x<1024; x+=tileW) {
    for (int y=0; y<768; y+=tileH) {
      color c = photo.pixels[y*1024+x];      
      drawTile(x * 2, y * 2, tileW * 2, tileH * 2, c);
    }  
  }
  //noLoop();
  //drawTile(100, 100, 100, 100, tc);
  //save("test.png");
}


void drawTile(float x, float y, float w, float h, color c) {
  fill(c, .5);
  noStroke();
  //rect(x, y, w, h);
  float oHue = (hue(c) + 180) % 360;
  float oSat = saturation(c);
  float oBrt = brightness(c);
  color complement = color(oHue, oSat, oBrt);
  
  
  stroke(complement);
  if (random(1) > .5) {
      fill(complement);
    } else {
      noFill();
   }
  strokeWeight(random(1, 5));
  
  float toincoss = random(1); 
  if (toincoss > .7) {
    float sz = random(0, w * 1.5);
    circle(x + w/2, y+h/2, sz);
  } else if (toincoss > .5 && toincoss < .7) {
    float x1 = x + w/2;
    float y1 = y - random(0, h);    
    float y2 = y + random(h, h*2);
    
    line(x1, y1, x1, y2);
  } 
  
  
  
}
