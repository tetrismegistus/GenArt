/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

import java.lang.Math;
import java.util.function.IntUnaryOperator;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;
UnivariateSolver solver;

color[] p = {#D62828, #F77F00, #FCBF49, #EAE2B7};
float macroTileSize = 4600;  

int maxCount = 10;

void setup() {
  size(4600 * 3, 4600);
  //colorMode(HSB, 360, 100, 100, 1);
  solver = new BrentSolver();
  noLoop();
}


void draw() {
  background(#003049);  
  float imageMargin = macroTileSize / 10;
  macroTileDraw(imageMargin, imageMargin, macroTileSize - imageMargin*2, 
    col -> col < maxCount / 2 ? col : maxCount - col - 1, // Lambda for m calculation
    row -> row < maxCount / 2 ? row : maxCount - row - 1  // Lambda for n calculation
  );
  println("1");
  macroTileDraw(imageMargin + macroTileSize, imageMargin, macroTileSize - imageMargin*2, 
    col -> col < maxCount / 2 ? col : maxCount - col - 1, // Lambda for m calculation
    row -> row < maxCount / 2 ? row : maxCount - row - 1  // Lambda for n calculation
  );
  println("2");
  macroTileDraw(imageMargin + macroTileSize * 2, imageMargin, macroTileSize - imageMargin*2, 
    col -> col < maxCount / 2 ? col : maxCount - col - 1, // Lambda for m calculation
    row -> row < maxCount / 2 ? row : maxCount - row - 1  // Lambda for n calculation
  );
  println("3");
  save(getTemporalName(sketchName, saveFormat));
  println("done");
}

void macroTileDraw(float tx, float ty, float sz, IntUnaryOperator mFunc, IntUnaryOperator nFunc) {
    float tileSize = sz / maxCount;
    float tileMargin = tileSize / 10;
    for (int col = 0; col < maxCount; col += 1) {
        int m = mFunc.applyAsInt(col);          
        for (int row = 0; row < maxCount; row += 1) {
            int n = nFunc.applyAsInt(row);       
            float x = col * tileSize + tx;
            float y = row * tileSize + ty;
            fill(random(255));            
            tileDraw(x + tileMargin, y + tileMargin, tileSize - tileMargin * 2, m, n);    
        }
    }
}

void tileDraw(float x, float y, float sz, int m, int n){
  int aaFactor = 1;
  for (float cx = x; cx < x + sz; cx++) {
        
        for (float cy = y; cy < y + sz; cy++) {
          
          float currX = map(cx, x, x+sz, 1, -1);
          float currY = map(cy, y, y+sz, 1, -1);

          float strokeSum = 0;
          for (int i = 0; i < aaFactor; i++) {
            for (int j = 0; j< aaFactor; j++) {
              float offsetX = (float)i / aaFactor;
              float offsetY = (float)j / aaFactor;              
              double w = getU(m, currX + offsetX) * getU(n, currY + offsetY) + getU(n, currX + offsetX) * getU(m, currY + offsetY);
              float strokeColor = map((float)w, -.5, .5, 0, 255);
              strokeSum += strokeColor;
            }
          }          
          float avgStroke = strokeSum / (aaFactor * aaFactor);
          stroke(avgStroke);
          point(cx, cy);                               //<>//
        }
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
