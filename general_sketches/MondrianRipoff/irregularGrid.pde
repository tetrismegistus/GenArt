String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

int rows = 50;
int cols = 50;
float tileSize = 20;
Tile[][] board = new Tile[rows][cols];
ArrayList<TileRect> rects = new ArrayList<TileRect>();

color[] pal = {#fac901, #ffffff, #225095, #dd0100};

void setup() {

  colorMode(HSB, 360, 100, 100, 1);
  
  for (int i = 0; i < 10000000; i++) {
    color c = color(pal[(int)random(pal.length)]);
    float h = hue(c);
    float s = saturation(c);
    float b = brightness(c);
    float alpha = .75;
    color c2 = color(h,s,b,alpha);
    TileRect tr = new TileRect((int)random(rows), (int)random(cols), (int)random(1, 50), (int)random(1, 50), c2); 
    if (tr.place(board)) {
      rects.add(tr);
    }
  }
  
   
  
  size(1100, 1100);
  colorMode(HSB, 360, 100, 100, 1);
  ellipseMode(CENTER);
  
  
}


void draw() {
  background(0, 0, 100);
  grid();
  noStroke();
  fill(0, 0, 100, 1);
  rect(0, 0, width, tileSize*3);
  rect(0, 0, tileSize*3, height);
  rect(tileSize*3 + tileSize*(cols - 1), 0, tileSize*3, height);
  rect(0, tileSize*3 + tileSize*(rows - 1), width, tileSize*3);
  //background(0);

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (board[i][j] != null) {
        board[i][j].render();
      }      
    }  
  }
  
  for (TileRect tr : rects) {
    tr.render();
  }
  
  stroke(0, 0, 0, .75);
  strokeWeight(4);
  noFill();
  rect(tileSize * 3, tileSize * 3, (cols -1) * tileSize, (rows - 1) * tileSize);
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

class Tile {
  int x, y;
  color c;
  Tile (int x, int y, int c) {
    this.x = x;
    this.y = y;
    this.c = c;
  }
  
  void render() {
    noStroke();    
    fill(c);
    square(tileSize * 3 + x * tileSize, tileSize * 3 + y * tileSize, tileSize);
  }
}

class TileRect {
  int x, y;
  int w, h;
  color c;
  
  TileRect(int x, int y, int w, int h, color c) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;    
  }
  
  boolean place(Tile[][] b) {
    if (checkIsValid(b)) {
      for (int cx = x; cx < x + w; cx++) {
        for (int cy = y; cy < y + h; cy++) {
          b[cy][cx] = new Tile(cx, cy, c);
        }    
      }
      return true;
    }
    return false;
  }
  
  boolean checkIsValid(Tile[][] b) {    
    if (x + w > b[0].length - 1) {
      return false;
    }
    
    if (y + h > b.length - 1) {
      return false;
    }
    
    for (int cx = x; cx < x + w; cx++) {
      for (int cy = y; cy < y + h; cy++) {
        if (b[cy][cx] != null) {
          return false; 
        }
        
      }    
    }    
    return true;     
  }
  
  void render() {
    noFill();
    stroke(0, 0, 0, .75);
    strokeWeight(4);
    rect(tileSize * 3 + x * tileSize, tileSize * 3 + y * tileSize, w * tileSize, h * tileSize);
  }
}

void grid() {
  float spacing = 5;
  for (int i = -width; i < height + width; i+=spacing) {
    stroke(0, random(.1, .3));
    gridline(i, 0, i + height, height);
  }
  for (int i = height + width; i >= -width; i-=spacing) {
    stroke(0, random(.1, .3));
    gridline(i, 0, i - height, height);
  }
}


void gridline(float x1, float y1, float x2, float y2) {
  float tmp;
  /* Swap coordinates if needed so that x1 <= x2 */
  if (x1 > x2) { tmp = x1; x1 = x2; x2 = tmp; tmp = y1; y1 = y2; y2 = tmp; }

  float dx = x2 - x1;
  float dy = y2 - y1;
  float step = 1;

  if (x2 < x1)
    step = -step;

  float sx = x1;
  float sy = y1;
  for (float x = x1+step; x <= x2; x+=step) {
    float y = y1 + step * dy * (x - x1) / dx;
    strokeWeight(1 + map(noise(sx, sy), 0, 1, -0.5, 0.5));
    line(sx, sy, x + map(noise(x, y), 0, 1, -1, 1), y + map(noise(x, y), 0, 1, -1, 1));
    sx = x;
    sy = y;
  }
}
