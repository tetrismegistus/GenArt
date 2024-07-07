import java.util.Collections;
int[] morning = {#B86B77, #EABFB9, #F6CFCA, #FFE8E5, #F3C3D9, #97D5DB};

ArrayList<PImage> tiles = new ArrayList<PImage>();
int rows = 5;
int cols = 5;
int twidth = 100;

void setup() {
  size(560, 560);
  background(0);  
}

void draw() {
  noStroke();
  for (int i = 0; i < rows * cols; i ++) {
    int seed = (int) random(0, 2147483647);
    noiseSeed(seed);
    randomSeed(seed);
    tiles.add(getTile());
  }
  background(0);    
  int idx = 0;
  Collections.shuffle(tiles);
  
  for (int x = 10; x < width; x = x + twidth + 10) {
    for (int y = 10; y < height; y = y + twidth + 10) {      
      image(tiles.get(idx), (float)x, (float)y, twidth, twidth);
      idx += 1;
    }
  }
  save("mountains.png");
  print("ding");
  noLoop();
}

PImage getTile() {
  
  background(0);
  
  fill(255);
  ellipse(width/2, height - 201, 200, 200);
  PImage mask = createImageFromScreen(width, height, 0, 0);  
  int backgroundIdx = (int) random(0, morning.length); 
  int skycolor = morning[backgroundIdx];
  background(skycolor);

  int rows = (int) random(1, 10);
  
  LayerPeaks(0, height - 200, width, 100, rows, 10);
  PImage img = createImageFromScreen(width, height, 0, 0);
  background(255);
  img.mask(mask);
    background(0);
  image(img, 0, 0);

  PImage tileImg = createImageFromRect(201, 201, width/2 - 100, height - 301);
  background(255);
  return tileImg; 
}

PImage createImageFromScreen(int w, int h, int x, int y){
  PImage img = createImage(w, h, RGB);
  img.loadPixels();
  int loc = x + y * width;
  loadPixels();
  for (int i = loc; i < img.pixels.length; i++) {
    img.pixels[i] = pixels[i];
  }
  img.updatePixels();
  return img;  
}

PImage createImageFromRect(int w, int h, int x, int y){
  PImage img = createImage(w, h, RGB);
  img.loadPixels();
  loadPixels();

  for (int cx = x; cx < x + w; cx++){
    for (int cy = y; cy < y + h; cy++) {
      int refLoc = cx + cy * width;
      int drawLoc = (cx - x) + (cy - y) * w;
      img.pixels[drawLoc] = pixels[refLoc];
      drawLoc++;
    }   
  }
  img.updatePixels();    
  return img;  
}

void LayerPeaks(int x, int y, int w, int peakHeight, int rows, int rowgap) {
  int r = 197;
  int g = 226;
  int b = 247;     
  fill(r,g,b);
  int rdelta  = (int) random(-40, -10); 
  int gdelta  = (int) random(-40, -10);
  int bdelta  = (int) random(-40, -10);  
  
  for (int i = y; i < y + (rows * rowgap); i+=rowgap) {
    fill(r,g,b);
    r += rdelta;
    g += gdelta;
    b += bdelta;
    
    int octaves = (int) random(1, 100); 
    float interval = random(0.05, 0.09);
    int variance = (int) random(1, 40);
    PerlinPeaks(x, i, interval, w, peakHeight,  octaves, variance);
    peakHeight -= rowgap;
  }
}


void PerlinPeaks(int x1, int y1, float inc, int w, int h, int octaves, int variance) {  
  noiseDetail(octaves);
  float xoff = x1;
  beginShape();
  for (int x = x1; x <= x1 + w; x ++) {    
    float y = map(noise(xoff), 0, 1, y1+variance, y1-variance);
    vertex(x, y);
    xoff += inc;
  }
  vertex(x1 + w, y1 + h);
  vertex(x1, y1 + h);
  vertex(x1, map(noise(0), 0, 1, y1+variance, y1-variance));
  endShape();
}
