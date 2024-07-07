String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

IntVec[][] board;

color[] pal = {#FF0000, #0BA235, #0000FF};
int rows = 10;
int cols = 10;
int tileSize;
int boardWidth = 900;
int boardHeight = 900;



void setup() {
  size(1025, 1025);
  tileSize = boardWidth/rows;  
  board = new IntVec[rows][cols];
  colorMode(HSB, 360, 100, 100, 1);
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      if (random(1) > .97) {
        IntVec target = null;
        while (target == null) {
          IntVec possibleTarget = new IntVec((int)random(rows), (int)random(cols));
          if (possibleTarget.x != x && possibleTarget.y != y) {
            target = possibleTarget;  
          }
        }
        board[x][y] = target;
      }
    }  
  }
  noiseDetail(8, .3);
  
}


void draw() {
  background(#6A1616);
  stroke(0);
  fill(0);
  // noise layer 1
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float n = noise(.45646 + x * 0.01, y * 0.001);
      float n2 = noise(100 + x * 0.02, 900 + y * 0.005);
      float modBright = (.5 + .5 *sin(n2 * n*4.0*TAU)) * 100; 
      
      stroke(0, 0, modBright, .25);
      point(x, y);
    }
  }
 
  
  
  // noise layer 2
  /*
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float n = noise(100 + x * 0.02, 900 + y * 0.005);
      float modBright = (.5 + .5 *sin(n*4.0*TAU)) * 100; 
      
      stroke(0, 0, modBright, .25);
      point(x, y);
    }
  }*/
  
  // noise layer 3
 
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y+=(int)random(30)) {
      strokeWeight(.5);
      stroke(0, 0, 0, random(.25));
      line(x, y, x, y + random(25));
      
    }
  }
  
  
  
  noStroke();
  square(50, 50, boardWidth + 25);
  textSquare(50, 50, boardWidth + 25, color(100, 0, 100));
  block(50, 50, boardWidth + 25, 0);
  noFill();
  float cpx1 = 0;
  float cpy1 = height;
  float cpx2 = width;
  float cpy2 = height;
  
  for (int x = 0; x < rows; x++) {
    for (int y = 0; y < cols; y++) {
      strokeWeight(4);
      //stroke(100);
      noStroke();
      fill(0);
      circle(x * tileSize + 100, y * tileSize + 100, tileSize/1.5);
      plug(x * tileSize + 100, y * tileSize + 100, tileSize/1.5);
    }
  }
  
  for (int x = 0; x < rows; x++) {
    for (int y = 0; y < cols; y++) {

      if (board[x][y] != null) {
        
        //circle(board[x][y].x * tileSize + 50, board[x][y].y * tileSize + 50, tileSize);
        fill(#D3D1A0);
        noStroke();
        circle(x * tileSize + 100, y * tileSize + 100, tileSize/1.5);
        circle(board[x][y].x * tileSize + 100, board[x][y].y * tileSize + 100, tileSize/1.5);
        strokeWeight(4);
        //stroke(p[(int)random(p.length)]);
        noFill();
        
      }
    }
  }
  
  
  for (int x = 0; x < rows; x++) {
    for (int y = 0; y < cols; y++) {
      //
      strokeWeight(.1);
      stroke(100);      
      if (board[x][y] != null) {
        
        //circle(board[x][y].x * tileSize + 50, board[x][y].y * tileSize + 50, tileSize);                
        strokeWeight(10);
        //stroke(p[(int)random(p.length)]);
        noFill();
        stroke(0);
        bezier(x * tileSize + 100, y * tileSize + 100,
               cpx1, cpy1, cpx2, cpy2,
               board[x][y].x * tileSize + 100, board[x][y].y * tileSize + 100);
        
        color c = pal[(int) random(pal.length)];
        Brush b = new Brush(4, x * tileSize + 100, y * tileSize + 100, c);
        int steps = 7000;
        
        for (int i = 0; i < steps; i++) {
          float t = i / float(steps);
          float nx = bezierPoint(x * tileSize + 100, cpx1, cpx2, board[x][y].x * tileSize + 100, t);
          float ny = bezierPoint(y * tileSize + 100, cpy1, cpy2, board[x][y].y * tileSize + 100, t);
          b.cx = nx;
          b.cy = ny;
          b.render();
          
        
        }
        
        
      }
    }
  }
  
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


void textSquare(float x1, float y1, float sz, color fg) {
  rectMode(CORNER);
  noStroke();

  
  for (int ln = 0; ln < sz * 15; ln++) {
    IntList sides = new IntList();
    
    for (int i = 0; i < 4; i++) {
      sides.append(i);
    }
    sides.shuffle();
    
    int[] chosenSides =  new int[2];
    chosenSides[0] = sides.get(0);
    chosenSides[1] = sides.get(1);
    
    
    
    stroke(0);
    
    PVector[] points = new PVector[2];
    for (int i = 0; i < chosenSides.length; i++) {
      PVector p = new PVector();
      float adj = map(random(.5), 0, .5, 0, sz);
      switch(chosenSides[i]) {
        case 0:
          p.x = x1 + adj;
          p.y = y1;
          break;
        case 1:
          p.x = x1;
          p.y = y1+ adj;
          break;
        case 2:
          p.x = x1 + adj;
          p.y = y1 + sz;
          break;
        case 3:
          p.x = x1 + sz;
          p.y = y1 + adj;  
          break;
      }
      points[i] = p;
    }
    strokeWeight(.05);
    stroke(fg, .05);
    
    line(points[0].x + randomGaussian() * 2, points[0].y + randomGaussian() * 2, points[1].x + randomGaussian() * 2, points[1].y + randomGaussian() * 2);

    //noStroke();
  }
  

}


void block(float x, float y, float sz, color c) {
  noFill();
  noStroke();
  square(x, y, sz);
  float borderWidth = 4;
  
  // top border 
  for (float i = 0; i < borderWidth; i+=.1) {
    float d = map(i, 0, borderWidth, 100, 20);
    stroke(0, 0, d, .5);
    strokeWeight(.1);
    line(x + i, y + i, x - i + sz, y + i);    
  }
 
  // bottom border 
  float stgap = borderWidth;
  for (float i = 0; i < borderWidth; i+=.1) {
    float d = map(i, 0, borderWidth, 50, 0);
    stroke(0, 0, d, .5);
    strokeWeight(.1);
    line(x + stgap, y + sz - borderWidth + i, x + sz - stgap, y + sz - borderWidth + i);
    stgap -= .1;
  }
  
  // left border
  for (float i = 0; i < borderWidth; i+=.1) {
    float d = map(i, 0, borderWidth, 25, 50);
    stroke(0, 0, d, .5);
    strokeWeight(.1);
    line(x + i, y  + i, x + i, y + sz - i);
  }
  
  //right border
  stgap = borderWidth;
  for (float i = 0; i < borderWidth; i+=.1) {
    float d = map(i, 0, borderWidth, 50, 25);
    stroke(0, 0, d, .5);
    strokeWeight(.1);
    line(x + i + sz - borderWidth, y + stgap, x + i + sz - borderWidth, y + sz - stgap);
    stgap -= .1;
  }  
}

class Brush {
  float rad, cx, cy;
  color col;
  BrushTip[] brushEnds;
  
  Brush(float r, float x, float y, color c) {
    rad = r;
    cx = x;
    cy = y;
    col = c;
    int cap = ((int) rad * (int) rad) * 4;
    brushEnds = new BrushTip[cap];
    for (int i = 0; i < cap; i++) {
      brushEnds[i] = getBrushTip();      
    }
  }
  
  void render() {
    pushMatrix();
    translate(cx, cy);
    for (BrushTip bt : brushEnds) {
      if (random(1) > .1) {
        strokeWeight(bt.sz);
        stroke(col, random(.4));      
        point(bt.pos.x, bt.pos.y);
      }
    }
    popMatrix();
  }
  
  BrushTip getBrushTip() {
    float r = rad * sqrt(random(0, 1));
    float theta = random(0, 1) * 2 * PI;
    float x = r * cos(theta) + randomGaussian();
    float y = r * sin(theta) + randomGaussian();
    return new BrushTip(new PVector(x, y), .2 + abs(randomGaussian()));    
  }
}


class BrushTip {
  float sz;
  PVector pos;
  
  BrushTip(PVector xy, float isz) {
    pos = xy;
    sz = isz;
  }
}

void plug(float x, float y, float sz) {
  noFill();
  noStroke();
  square(x, y, sz);
  float borderWidth = 7;
  
  float r = sz;
  for (float i = 0; i < borderWidth; i+=.1) {
    float d = map(i, 0, borderWidth, 0, 99);
   
    stroke(53, 47, d, .5);
    strokeWeight(.1);

    circle(x, y, r + i);    
  }
}
