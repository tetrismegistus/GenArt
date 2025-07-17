import java.util.*;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime; 

int rows = 100;
int cols = 100;
boolean[][] board = new boolean[rows][cols];

float tileSize = 15;

ArrayList<Agent> agents = new ArrayList<Agent>();

IntList pal;


int[] endPoints = new int[20];

void setup() {
  for (int i = 0; i < endPoints.length; i++) {
    endPoints[i] = (i + 1) * 90;

  }
  pal = new IntList();
  pal.append(#DBCDC6);
  pal.append(#EAD7D1);
  pal.append(#DD99BB);
  pal.append(#7B506F);
  size(1640, 1640);
  colorMode(HSB, 360, 100, 100, 1);
  ellipseMode(CENTER);
  background(#1F1A38);
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      board[i][j] = true;  
    }  
  }
  
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      noStroke();
      fill(#1F1A38);
      square(50 + j * tileSize, 50 + i * tileSize, tileSize);      
      //board[i][j] = true;  
    }  
  }
  
  for (int i = 0; i <8; i++) {
    int px = (int) random(rows);
    int py =  (int) random(cols);
    if (board[py][px]) {
      pal.shuffle();
      Agent agent = new Agent(py, px, pal.get(0));
      agents.add(agent);
    }
  }
  
  //Agent agent = new Agent(4, 4, pal.get(0));
  //agents.add(agent);
  

}


void draw() {
  for (Agent a: agents) {
    a.move();
  }
  IntVec newAgentLoc = getRandomUnoccupied();
  if (newAgentLoc != null) {
      pal.shuffle();
      Agent agent = new Agent(newAgentLoc.y, newAgentLoc.x, pal.get(0));
      agents.add(agent);
  
  }
    
}

void mouseClicked() {
  int x = constrain(((int) (mouseX) / (int) tileSize) - 2, 0, rows);
  int y = constrain(((int) (mouseY) / (int) tileSize) - 2, 0, cols);
  if (board[y][x]) {
      pal.shuffle();
      Agent agent = new Agent(y, x, pal.get(0));
      agents.add(agent);
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


IntVec getRandomUnoccupied() {
  ArrayList<IntVec> targets = new ArrayList<IntVec>();
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      if (board[y][x]) {
        targets.add(new IntVec(x, y));
      }
      
    }
  }
  if (targets.size() > 0) {
    int idx = (int) random(0, targets.size() - 1);
    return targets.get(idx);
  } else {
    return null;
  }
}
