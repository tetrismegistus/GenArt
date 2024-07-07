PImage srcImage;

float tileSize = 8;
float origTileSize = 4;
float sw = 4; 

int origPicHeight = 480;

int imgIdx = 1;

OpenSimplexNoise noise;
int gridResolutionX, gridResolutionY;
boolean drawGrid = true;
color[][] srcImageColors;


Tile[][] tiles;
/* 
   0 = black 
   1 = white
   2 = light tan
   3 = dark tan
*/



void setup() {
  smooth(8);
  
  noise = new OpenSimplexNoise((long) random(0, 20000000));
  noiseSeed((long)random(0, 255555));
  size(960, 960);
  colorMode(HSB,360,100,100);
  cursor(CROSS);
  gridResolutionX = round(width/tileSize)+2;
  gridResolutionY = round(height/tileSize)+2;
  
  
  tiles = new Tile[gridResolutionX][gridResolutionY];
  
  
}

void draw() {
  background(123);
  srcImage = loadImage("decompose/" +  imgIdx + ".png");
  initTiles();
  if (drawGrid) drawGrid();
  saveFrame("frames/####.png");
  imgIdx++;
  if (imgIdx == 21) {
    
    noLoop();
  }
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
  
  srcImage.loadPixels();
  for (int gridY=0; gridY< gridResolutionY; gridY++) {
    for (int gridX=0; gridX< gridResolutionX; gridX++) {  
      GridLocation loc = new GridLocation(gridX, gridY);
      Tile tile = new Tile(loc);
      if (gridX > 1 && gridX< gridResolutionX - 2 && gridY > 1 && gridY < gridResolutionY - 2) {
        //int choice = toad[gridY][gridX];
        
        int srcX = (int) gridX * (int)origTileSize;
        int srcY = (int) gridY * (int)origTileSize;
        int srcLoc = srcX + srcY * origPicHeight;
        
        tile.occupy(srcImage.pixels[srcLoc]);
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
