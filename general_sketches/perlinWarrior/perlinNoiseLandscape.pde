PImage tilemap;
PImage[] tiles = new PImage[48];

OpenSimplexNoise noise;

int[] landtiles = {2, 8, 24, 24, 24, 8, 2, 3, 4, 5};
int tilesize = 17;
int mouseIndex = 0;

float inc = .1;
float zoff = 0;
float permxoff = 0;
float permyoff = 0;

void setup() {
  size(512, 512);
  tilemap = loadImage("sprites.png");
  PImage tmpimage;
  int tileIndex = 0;
  for (int y = 0; y < 2 * tilesize; y += tilesize) {
    for (int x = 0; x < 24 * tilesize; x += tilesize) {      
      tmpimage = tilemap.get(x + 1, y + 1, tilesize - 1, tilesize - 1);      
      tiles[tileIndex] = tmpimage;
      tileIndex++;
    }
  }  
  noise = new OpenSimplexNoise((long) random(0, 255)); 
  frameRate(15);
}

void draw() {
  //flatRandomPlace();
  simplexPlace(width, height);
  if (mousePressed) {
    zoff += inc;
  }
}

void flatRandomPlace(int w, int h) {
  for (int x = 0; x < w; x += tilesize - 1) {
    for (int y = 0; y < h; y += tilesize - 1) {
      int idx = landtiles[(int) random(0, landtiles.length)];      
      image(tiles[idx], x, y);
    }
  }
}

void simplexPlace(int w, int h) {
  float xoff = permxoff; 
  for (int x = 0; x < w; x += tilesize - 1) {
    float yoff = permyoff;
    for (int y = 0; y < h; y += tilesize - 1) {
      float n = (float) noise.eval(xoff, yoff, zoff);       
      int idx = (int) map(n, -1, 1, 0, landtiles.length);
      int tileIndex = landtiles[idx];
      image(tiles[tileIndex], x, y);
      yoff += inc;
    }
    xoff += inc;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      permyoff -= inc;
    } else if (keyCode == DOWN) {
      permyoff += inc;
    } else if (keyCode == LEFT) {
      permxoff -= inc;
    } else if (keyCode == RIGHT) {
      permxoff += inc;
    }
  }

  //zoff += inc;
}
