import java.util.*;

Grid[] mazes = new Grid[4];

int calls = 0;
long lastTime;

color fc; 
float fhue;
float fbrt;
float fsat;


float r = radians(0); 

void setup() {
  size(900, 900);
  
  colorMode(HSB, 360, 100, 100, 1);
  blendMode(ADD);
  for (int i = 0; i < mazes.length; i++) {
    DistanceGrid maze = new DistanceGrid(20, 20);
    
    mazes[i] = Sidewinder(maze);   
    Cell start = maze.grid(1, 1);
    Distances distances = start.distances();
    maze.distances = distances;
    //<>//
  }  
  
  
}

void draw() {
  float startx = 50;
  float starty = 50;
  stroke(0);
  color sColor = color(random(360), random(20, 100), random(30, 70));
  color endColor = color(sColor, saturation(sColor) + 20 % 100, brightness(sColor)); 
  fc = color(random(360), random(20, 100), random(30, 70));
  fhue = hue(fc);
  fbrt = brightness(fc);
  fsat = saturation(fc);
  

  background(0);
  
  for (int i = 0; i < mazes.length; i++) {
    pushMatrix();
    translate(startx, starty);
    
    noStroke();
    fill(color(fhue + 160 % 360, fbrt, fsat));
    //rect(0, 0, 250, 250);
    mazes[i].render(25);
    
    if (startx == 350) {
      starty = 350;
      startx = 50;
    } else {
      startx += 300;
    }
    popMatrix();
        
  }
 //<>//
  save(getTemporalName("maze_",".png"));
  r += radians(1);
  noLoop();
  
  
}

Grid binaryTree(Grid grid) {
  for (Cell[] row : grid._grid) {
    for (Cell cell : row) {
      ArrayList<Cell> neighbors = new ArrayList<Cell>();
      if (cell.north != null) {
        neighbors.add(cell.north);
      }
      
      if (cell.east != null) {
        neighbors.add(cell.east);
      }
      int idx = int(random(neighbors.size()));
       
      Cell neighbor;
      
      if (neighbors.size() > 0) {
        neighbor = neighbors.get(idx);
      } else {
        neighbor = null;
      }
      
      if (neighbor != null) {
        cell.link(neighbor, true);
      } 
      
      
      
    }
  }
  return grid;
}


Grid Sidewinder(Grid grid) {
  for (Cell[] row : grid._grid) {
    ArrayList<Cell> run = new ArrayList<Cell>();
    for (Cell cell : row) {
      run.add(cell);
      boolean at_eastern_boundary = (cell.east == null);
      boolean at_northern_boundary = (cell.north == null);
      boolean coinToss = int(random(2)) == 0;
      boolean should_close_out = (at_eastern_boundary || (!at_northern_boundary && coinToss));
      if (should_close_out) {
        int idx = (int) random(run.size());
        Cell member = run.get(idx);
        if (member.north != null) {
          member.link(member.north, true);
          run.clear();
        }
       } else {
          cell.link(cell.east, true);
        }
      }
      
    }
    return grid;
  
}

float slope(float x1, float y1, float x2, float y2)
{
    return (y2 - y1) / (x2 - x1);
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
