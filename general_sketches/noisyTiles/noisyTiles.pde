OpenSimplexNoise noise;
float tileSize = 10;
int gridResolutionX, gridResolutionY;
boolean drawGrid = true;
Tile[][] tiles;
color[] p = {color(355, 63, 96), color(100, 66, 73)};

void setup() {
  smooth(8);
  noise = new OpenSimplexNoise((long) random(0, 20000000));
  noiseSeed((long)random(0, 255555));
  size(3000, 3000);
  colorMode(HSB,360,100,100);
  cursor(CROSS);
  gridResolutionX = round(width/tileSize)+2;
  gridResolutionY = round(height/tileSize)+2;
  tiles = new Tile[gridResolutionX][gridResolutionY];

  initTiles();
  
}


void draw() {
  background(0);
  if (drawGrid) drawGrid();
  save("test.png");
  noLoop();
}


void drawGrid() {
  rectMode(CENTER);
  for (int gridY=0; gridY< gridResolutionY; gridY++) {
    for (int gridX=0; gridX< gridResolutionX; gridX++) {  
      float posX = tileSize*gridX - tileSize/2;
      float posY = tileSize*gridY - tileSize/2;
      tiles[gridX][gridY].render(posX, posY, tileSize);
      strokeWeight(0.15);
      fill(360);
     stroke(0);
     noFill();
     //rect(posX, posY, tileSize, tileSize);
     
    }
  }
}

void initTiles() {
  float theta = random(0, 2555555);
  for (int gridY=0; gridY< gridResolutionY; gridY++) {
    for (int gridX=0; gridX< gridResolutionX; gridX++) {  
      GridLocation loc = new GridLocation(gridX, gridY);
      Tile tile = new Tile(loc);
      if (gridX > 1 && gridX< gridResolutionX - 2 && gridY > 1 && gridY < gridResolutionY - 2) {
        float posX = tileSize*gridX - tileSize/2;        
        float posY = tileSize*gridY - tileSize/2;
        
        float d = dist(posX, posY, width/2, height/2);
        float nf = map(d, 0, width, .00000001, .1);
        
        
        
        float n = (float) noise.eval(posX * nf, posY * nf);
        int choice = (int) map(n, 1, -1, 0, p.length);         
        tile.occupy(p[choice]);
      }
       
      
      tiles[gridX][gridY] = tile;     
    }
  }
  
  for (int gridY=1; gridY< gridResolutionY - 1; gridY++) {
    for (int gridX=1; gridX< gridResolutionX - 1; gridX++) {
      tiles[gridX][gridY].setTileIndex(tiles);
    
    }
  }
  
  
}
