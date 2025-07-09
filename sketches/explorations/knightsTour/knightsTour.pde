
String sketchName = "knightsTour";
String saveFormat = ".png";

int calls = 0;
long lastTime;

Board board;
int rows = 5;
int cols = 5;

int curX = 1;
int curY = 1;

float s, h, b;



void setup() {
  size(1000, 1000);
  colorMode(HSB, 360, 100, 100, 1);
  board = new Board(rows, cols, 200);
  board.render();
  s = saturation(#ADBDFF);
  h = hue(#ADBDFF);
  b = brightness(#ADBDFF);
  //blendMode(ADD);
}


void draw() {
  background(#35281D);
  strokeWeight(1);
  
  board.warnsdorff((int) random(0, rows - 1), (int) random(0, cols - 1));
  
  /*
  board.squares[curY][curX].visited = true;
  
  board.setAllCounts();
  if(board.squares[curY][curX].targets > 0) {    
    
    Square target = board.getMostRestrictedNeighbor(curY, curX);
    
    //board.render();
    
    //board.squares[curY][curX].render();
    stroke(100, 100, 100);
    strokeWeight(5);
    circle((curX * board.size) + board.size/2, (curY * board.size) + board.size/2, 10);
    line((curX * board.size) + board.size/2, (curY * board.size) + board.size/2, 
         (target.x * board.size) + board.size/2, (target.y * board.size) + board.size/2);
    curY = target.y;
    curX = target.x;
  } else {
    stroke(100, 100, 100);
    strokeWeight(5);
    circle((curX * board.size) + board.size/2, (curY * board.size) + board.size/2, 10);
    line((curX * board.size) + board.size/2, (curY * board.size) + board.size/2, 
         (3 * board.size) + board.size/2, (4 * board.size) + board.size/2);
  }
  //board.render();
  */
  saveFrame("output/####.png");
  
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

class IntVec {
  int x, y;
  IntVec(int x, int y) {
    this.x = x;
    this.y = y;
  }
  IntVec() {
    this(0, 0);
  }
}

@SafeVarargs final <T> T[] shuffle(final T... arr) {
  if (arr == null)  return null;

  int idx = arr.length;

  while (idx > 1) { 
    final int rnd = (int) random(idx--);
    final T tmp = arr[idx];

    arr[idx] = arr[rnd];
    arr[rnd] = tmp;
  }

  return arr;
}
