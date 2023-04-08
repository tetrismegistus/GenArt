/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

import java.lang.Math;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;
UnivariateSolver solver;

color[] p = {#3b429f, #aa7dce, #f5d7e3, #f4a5ae, #a8577e};

void setup() {
  size(1000, 1000);
  colorMode(HSB, 360, 100, 100, 1);
  solver = new BrentSolver();
  noLoop();
}


void draw() {
  background(#000000);  
  int m = 0;
        
      tileDraw(0, 0, width, (int) random(50), (int) random(50));
  
  save(getTemporalName(sketchName, saveFormat));
}

void tileDraw(float x, float y, float sz, int m, int n){
  double min = 0;
  for (float cx = x; cx < x + sz; cx++) {
        for (float cy = y; cy < y + sz; cy++) {
          
          float currX = map(cx, x, x+sz, 1, -1);
          float currY = map(cy, y, y+sz, 1, -1);
          double w = getU(m, currX) * getU(n, currY) + getU(n, currX) * getU(m, currY);
          if (w < min)
            min = w;
          stroke(map((float)w, -.5, .5, 0, 360), 100, 100);
          
          if(Math.abs(w) <= 0.5) { //<>//
            int idx = (int)map((float)w, -.6, .6, 0, 5);
            stroke(p[idx]);
          
            point(cx, cy);      
          }
          
        }
      }   
  println(min);
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
