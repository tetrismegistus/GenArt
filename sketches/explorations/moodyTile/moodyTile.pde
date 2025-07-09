String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

color[] p = {#EB5160, #B7999C, #AAAAAA, #DFE0E2}; 

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
  blendMode(MULTIPLY);
}


void draw() {
  color c = #FFC4CCC7;
  background(#DFE0E2);
  println(hex(c));
  noFill();
  int tileSize = 50;
  textSquare(25, 25, 750, #071013);
  //textSquare(25, 25, 750, #071013);
  for (int y = tileSize; y < height; y+= tileSize) {
    for (int x = tileSize; x < width; x+= tileSize) {
      drawTile(x, y, tileSize);    
    }  
  }
  
  
  
  noLoop();
}

void drawTile(float x, float y, float r) {
  float cornerR = r/4;
  float cornerAdj = cornerR/2;
  float rHalved = r/2;
  float tSCenterX = x - rHalved;
  float tSCenterY = y - rHalved;
  float n = noise(x * .001, y * .001);
  float mn = map(n, 0, 1, 0, .4);
  
  ellipseMode(CENTER);
  noStroke();
  
  if (mn > .1) {  
    myCircle c = new myCircle(x, y, r, p[(int) random(p.length)]);
    c.render();
    //textCircle(x, y, r, p[1]);
  }
  
  
  
  if (mn > .2) {    
    myCircle c1 = new myCircle(x - rHalved + cornerAdj, y - rHalved, cornerR, p[(int) random(p.length)]);
    c1.render();
    
    myCircle c2 = new myCircle(x - rHalved + cornerAdj, y + rHalved, cornerR, p[(int) random(p.length)]);
    c2.render();
    
    myCircle c3 = new myCircle(x + rHalved - cornerAdj, y + rHalved, cornerR, p[(int) random(p.length)]);
    c3.render();
        
    myCircle c4 = new myCircle(x + rHalved - cornerAdj, y - rHalved, cornerR, p[(int) random(p.length)]);
    c4.render();  
}
  
  if (mn > .3) {
    myCircle c1 = new myCircle(x - rHalved, y - rHalved + cornerAdj, cornerR, p[(int) random(p.length)]);
    myCircle c2 = new myCircle(x - rHalved, y + rHalved - cornerAdj, cornerR, p[(int) random(p.length)]);
    myCircle c3 = new myCircle(x + rHalved, y + rHalved - cornerAdj, cornerR, p[(int) random(p.length)]);
    myCircle c4 = new myCircle(x + rHalved, y - rHalved + cornerAdj, cornerR, p[(int) random(p.length)]);
    
    c1.render();
    c2.render();
    c3.render();
    c4.render();
  }
  
  if (mn > .4) {
    myCircle c = new myCircle(x, y, r * .7, p[(int) random(p.length)]);
    c.render();
    //textCircle(x, y, r * .7, p[3]);
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
