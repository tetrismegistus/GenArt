/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

GameBoard game;

float squareSize = 1;

void setup() {
  size(800, 800, P2D);
  colorMode(HSB, 360, 100, 100, 1);
  game = new GameBoard(800, 800);
}


void draw() {
  background(#1F2F16);
  for (int x = 0; x < game.width; x++) {
    for (int y = 0; y < game.height; y++) {
      if (game.board[x][y].alive) {
        fill(game.board[x][y].getColor());
        stroke(game.board[x][y].getColor());
        rect(x * squareSize, y * squareSize, squareSize, squareSize); // 10 is the size of each cell
      }
    }
  }
  
  game.evolve();
  delay(100);
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
