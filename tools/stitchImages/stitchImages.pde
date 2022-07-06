String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

int rows = 2;
int cols = 2;

float imgMargin = 25;

PImage[] images = new PImage[4];

void setup() {
  size(1640, 1640);
  colorMode(HSB, 360, 100, 100, 1);
  for (int i = 0; i < images.length; i++) {    
    int fileNum = i + 1;
    images[i] = loadImage("inImages/" + nf(fileNum,4) + ".png");
    println("inImages/" + nf(fileNum,4) + ".png");
  }  
  
}


void draw() {
  background(#5b7c99);
  for (int i = 0; i < images.length; i++) {
    float x = i % 2;
    float y = i / 2;
    image(images[i], ((x * 820)), (y * 820));
  }
  save(getTemporalName("", saveFormat));
  noLoop();
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
