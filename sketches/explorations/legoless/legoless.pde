String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;
PImage img;


void setup() {  
  size(2576, 1932);
  colorMode(HSB, 360, 100, 100, 1);
  img = loadImage("pg.jpg");
}


void draw() {
  background(0, 20, 50);
  img.loadPixels();
  for (int x = 0; x < width; x+=40) {
    for (int y = 0; y < height; y+=40) {
      
        int idx = ((x) + (y) * 1932);
        color c = img.pixels[idx];

        block(x, y,50, c);
            
      
    }
  }
  noLoop();
}


void block(float x, float y, float sz, color c) {
  fill(c);
  noStroke();
  square(x, y, sz);
  float borderWidth = 4;
  
  // top border 
  for (float i = 0; i < borderWidth; i+=.1) {
    float d = map(i, 0, borderWidth, 100, 20);
    stroke(0, 0, d, .5);
    strokeWeight(.1);
    line(x + i, y + i, x - i + sz, y + i);    
  }
 
  // bottom border 
  float stgap = borderWidth;
  for (float i = 0; i < borderWidth; i+=.1) {
    float d = map(i, 0, borderWidth, 50, 0);
    stroke(0, 0, d, .5);
    strokeWeight(.1);
    line(x + stgap, y + sz - borderWidth + i, x + sz - stgap, y + sz - borderWidth + i);
    stgap -= .1;
  }
  
  // left border
  for (float i = 0; i < borderWidth; i+=.1) {
    float d = map(i, 0, borderWidth, 25, 50);
    stroke(0, 0, d, .5);
    strokeWeight(.1);
    line(x + i, y  + i, x + i, y + sz - i);
  }
  
  //right border
  stgap = borderWidth;
  for (float i = 0; i < borderWidth; i+=.1) {
    float d = map(i, 0, borderWidth, 50, 25);
    stroke(0, 0, d, .5);
    strokeWeight(.1);
    line(x + i + sz - borderWidth, y + stgap, x + i + sz - borderWidth, y + sz - stgap);
    stgap -= .1;
  }  
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
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
