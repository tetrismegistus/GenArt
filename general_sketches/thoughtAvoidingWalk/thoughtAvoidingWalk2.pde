/* //<>//
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

import java.util.*;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

int cols;
int rows;
float cellSize = 50;
float padding = 100;
Spot[][] grid;
ArrayList<Spot> path = new ArrayList<>();
Spot spot;

PFont font;
int fontHeight = 16;
float fontWidth;

color[] p = {#e3170a, #a9e5bb, #fcf6b1, #f7b32b};
int cidx = 0;

String[] lines;
char[] characters;
PGraphics squares;

void setup() {
  size(1200, 1200);
  colorMode(HSB, 360, 100, 100, 1);
  
  font = createFont("LexendDeca-Regular.ttf", 30);
  textFont(font);
  textSize(50);
  textAlign(CENTER, CENTER);
  textSize(calculateFontSize("A", cellSize/2.5));  
  
  lines = loadStrings("output.txt");
  String text = join(lines, "").toUpperCase(); // Combine all lines into a single string
  characters = text.toCharArray(); // Convert the string to a char arr
        
  cols = 15;
  rows = 15;
  
  initGrid();  
  solveWalk();
  addSpotAttributes();
  noLoop();
}


void draw() {    
  background(0);

  for (int i = 0; i < path.size() - 1; i++) {    
    Spot s = path.get(i);
    Spot ns = path.get(i + 1);    
    s.display(ns);    
  }  
  
  Spot s = path.get(path.size() - 1);
  s.display(null);
  println(s.letter);
  save(getTemporalName(sketchName, saveFormat)); //<>//
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
}

void solveWalk() {
  spot = grid[0][0];
  path.add(spot);
  spot.visited = true;
  float i = 0;
  while (i < 195) {
    //translate(cellSize * 0.5, cellSize * 0.5);
    spot = spot.nextSpot();
    
    if (spot == null) {      
      Spot stuck = path.get(path.size() - 1);
      path.remove(path.size() - 1);
      stuck.clear();
      spot = path.get(path.size() - 1);
      i--;
      
    } else {
      path.add(spot);
      spot.visited = true;
      i++;      
    }    
    
    if (path.size() == 194) {
      println("broke");
      break;
    }
  }
  println(i);
}

void initGrid() {
  grid = new Spot[rows][cols];
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      grid[c][r] = new Spot(r, c);
    }
  }
}

void addSpotAttributes() {
  int ca = 0;
  int cidx = 0;
  for (int i = 0; i < path.size() - 1; i++) {
    Spot s = path.get(i);
    Spot nspot = path.get(i + 1);
    PVector pv = PVector.sub(nspot.realPos, s.realPos);

    s.letter = characters[ca];
    s.clr = p[cidx];
    s.dir = pv.copy().setMag(cellSize/2.2);
    s.connector = pv.copy().setMag(cellSize/1.6).add(s.realPos).add(cellSize/2, cellSize/2);

    if (i < path.size() - 2) {
      Spot nnspot = path.get(i + 2);
      nspot.fromDir = PVector.sub(nspot.realPos, nnspot.realPos).setMag(cellSize/4);
    }
      
    if (characters[ca + 1] == ' ') 
      cidx++;      
    if (cidx >= p.length)
      cidx = 0;      
    ca++;  
  }
  Spot s = path.get(path.size() - 1);
  s.letter = characters[ca];
  s.clr = p[cidx];
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

float calculateFontSize(String letter, float targetSize) {
  float currentFontSize = 1;
  float currentWidth = 0;

  while (true) {
    textSize(currentFontSize);
    currentWidth = textWidth(letter);

    if (currentWidth >= targetSize) {
      break;
    }
    currentFontSize++;
  }

  return currentFontSize;
}
