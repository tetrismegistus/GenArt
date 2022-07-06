class Board {
  Square[][] squares;
  float size;
  
  Board (int rows, int cols, float sz) {
    boolean black = true;
    squares = new Square[rows][cols];
    size = sz;
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {        
        squares[y][x] = new Square(x, y, black, sz);
        if (black) {
          black = false;
        } else {
          black = true;
        }
      }



    }    
  }
  
  void render() {
    
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        textSize(64);
        
        squares[y][x].render();
        fill(360, 100, 100);
        //text(squares[y][x].targets, (x * size) + 32, (y * size) + 64);
      }
    }
  }
  
  int countTargets(int y, int x) {
    int targets = 0;
    PVector t1 = new PVector(x + 2, y + 1);
    PVector t2 = new PVector(x - 2, y + 1);
    PVector t3 = new PVector(x + 2, y - 1);
    PVector t4 = new PVector(x - 2, y - 1);
    PVector t5 = new PVector(x - 1, y - 2);
    PVector t6 = new PVector(x + 1, y - 2);    
    PVector t7 = new PVector(x - 1, y + 2);
    PVector t8 = new PVector(x + 1, y + 2);
    
    PVector[] neighbors = {t1, t2, t3, t4, t5, t6, t7, t8 };
    
    for (PVector n : neighbors) {
      if (n.x > -1 && n.x < cols && 
      n.y > -1 && n.y < rows) {
        if (!squares[(int)n.y][(int)n.x].visited) {          
          targets += 1;     
          //squares[(int)n.y][(int)n.x].visited = true;
          //squares[(int)n.y][(int)n.x].render();
        }    
      }      
    }
    
    
             
    return targets;
  }
  
  Square getMostRestrictedNeighbor(int y, int x) {
    int lastMax = 9;    
    IntVec t1 = new IntVec(x + 2, y + 1);
    IntVec t2 = new IntVec(x - 2, y + 1);
    IntVec t3 = new IntVec(x + 2, y - 1);
    IntVec t4 = new IntVec(x - 2, y - 1);
    IntVec t5 = new IntVec(x - 1, y - 2);
    IntVec t6 = new IntVec(x + 1, y - 2);    
    IntVec t7 = new IntVec(x - 1, y + 2);
    IntVec t8 = new IntVec(x + 1, y + 2);
    IntVec[] neighbors = {t1, t2, t3, t4, t5, t6, t7, t8 };
    Square finalResult = null;
    
    shuffle(neighbors);
    
    for (IntVec n : neighbors) {           
      if (n.x > -1 && n.x < cols && 
      n.y > -1 && n.y < rows) {       
        Square result = squares[n.y][n.x];
        if (!result.visited && result.targets < lastMax) {                     //<>//
          lastMax = result.targets;
          finalResult = result;
        }    
      }      
    }
    
    println("");
    
    return finalResult;
    
  }
  
  void setAllCounts() {
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        squares[y][x].targets = countTargets(y, x);
      }
    }  
  }
  
  void warnsdorff(int y, int x) {
    
    setAllCounts();
    squares[y][x].visited = true;
    squares[y][x].render();

    if(squares[y][x].targets > 0) {    
      squares[y][x].visited = true;
      Square target = getMostRestrictedNeighbor(y, x);
    
     //board.render();      
      stroke(h, s, b);
      strokeWeight(5);
      if (target != null) {
        //circle((x * board.size) + board.size/2, (y * board.size) + board.size/2, 10);
        myLine((x * board.size) + board.size/2, (y * board.size) + board.size/2, 
        (target.x * board.size) + board.size/2, (target.y * board.size) + board.size/2, .3, color(h, s, b));
        s -= .08;
        warnsdorff(target.y, target.x);
      }
      
    }
   }
  

}

class Square {
  int x, y;
  boolean visited = false;
  boolean black = false;
  float size;
  int targets = 0;
  
  Square (int xi, int yi, boolean bl, float sz) {
    x = xi;
    y = yi;
    black = bl;
    size = sz;
  }
  
  void render() {
    ellipseMode(CENTER);
    
    if (black) {
      fill(0, 0, 0, .2);
    } else {
      fill(0, 0, 100, .2);
    }
    noStroke();
    
    float gMax = 10;
    
    float x1 = x * size + randomGaussian() * random(2, gMax);
    float y1 = y * size + randomGaussian() * random(2, gMax);
    
    float x2 = (x * size + size) + randomGaussian() * random(2, gMax);
    float y2 = (y * size) + randomGaussian() * random(2, gMax);
    
    float x3 = (x * size + size) + randomGaussian() * random(2, gMax);
    float y3 = (y * size + size) + randomGaussian() * random(2, gMax);
    
    float y4 = (y * size + size) + randomGaussian() * random(2, gMax);
    float x4 = x * size + randomGaussian() * random(2, gMax);
    
    quad(x1, y1, x2, y2, x3, y3, x4, y4);
    if (visited) {
      fill(#B74F6F, .5);
      //circle((x * size) + size/2, (y * size) + size/2, random(size / 2 + random(-5, 10)));
    }
  }
}

/* 
for every tile of the board I need to count the possible of paths from that tile

to do so I go through the possible coordinate offsets and check

a. does tile exist
b. has tile been visited
*/
