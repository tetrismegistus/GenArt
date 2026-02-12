/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

import java.util.List;
import java.util.Random;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

Grid grid;
ArrayList<Agent> agents = new ArrayList<>();

final float PADDING = .05;
final int NUM_AGENTS = 40;
final float CELL_SCALE = .025;

boolean[] occupiedEver;
int[] bag;
int cursor;

color[] p = {
  #210124, #750d37, #b3dec1, #dbf9f0
};

final int SS = 2;   
PGraphics drawing; 

int WIDTH = 1500;
int HEIGHT = 2000;

void settings() {
  size(WIDTH, HEIGHT, P2D);
}


void setup() {

  colorMode(HSB, 360, 100, 100, 1);


  drawing = createGraphics(WIDTH * SS, HEIGHT * SS, P2D);
  drawing.colorMode(HSB, 360, 100, 100, 1);
  grid = new Grid(drawing.width, drawing.height);

  occupiedEver = new boolean[grid.N];     // use grid.N
  bag = grid.makeIndexBagShuffled();
  cursor = bag.length;

  agents.clear();
  for (int agentID = 0; agentID < NUM_AGENTS; agentID++) {
    int idx = nextUnvisitedFromBag();
    if (idx == -1) break;

    Agent agent = new Agent(idx, grid, p[floor(random(p.length))]);
    agents.add(agent);
  }
  
  runSimulation();
  println("done simulating");
  noLoop();
}


void draw() {
  
  

  drawing.beginDraw();
  drawing.background(#F7F9F7);
  drawing.smooth(8);
  for (Agent a : agents) a.draw(drawing, grid);
  drawing.endDraw();

  image(drawing, 0, 0, width, height);
  
  save("out/" + getTemporalName(sketchName, saveFormat));

}


void runSimulation() {
  int safety = grid.N * 4; // fuse, not logic

  for (int step = 0; step < safety; step++) {

    boolean anyMoved = false;

    for (Agent a : agents) {
      if (!a.stuck) {
        int before = a.idx;
        a.step(grid, occupiedEver);
        if (a.idx != before) anyMoved = true;
      }
    }

    if (!anyMoved) break; // all stuck
  }
}


int nextUnvisitedFromBag() {
  while (cursor > 0) {
    int candidate = bag[--cursor];
    if (!occupiedEver[candidate]) {
      occupiedEver[candidate] = true;
      return candidate;
    }
  }
  return -1;
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
