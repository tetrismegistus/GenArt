/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

String sketchName = "output/mySketch";
String saveFormat = ".png";

PFont font;

int calls = 0;
long lastTime;

int MAX_ATTEMPTS = 25;
int MIN_SIZE = 50;

color[] pal = {#222222, #ffffff, #1c5d99, #639fab, #bbcde5};

void setup() {
  colorMode(HSB, 360, 100, 100, 1);        
  size(1050, 1050); 
  ellipseMode(CORNER);
  font = createFont("data/News Gothic Bold.otf", 128);
  textFont(font);
  blendMode(DIFFERENCE);
}


void draw() {
  background(0);    
  noStroke();
  Grid grid = new Grid(50, 50, 10, 10, 0, 0, (int) 800/10, color(pal[(int)random(pal.length)]));
  grid.fillGrid();
  grid.render();
  //rect(100, 100, 300, 200);
  //text("test", 100, 200);
  println("done");
  save(getTemporalName(sketchName, saveFormat));
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
  return prefix + time + (calls>0?"-"+calls : "")  + suffix;
}
