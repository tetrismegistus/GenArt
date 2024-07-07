int[][] tiles;
int twidth = 10;

void setup() {
  size(510, 510);
  tiles = new int[width/twidth][height/twidth];
}

void draw() {
  background(123);
  fill(255, 0, 0);
  
  // lost some work here, but keeping this for the binary 
  // tree implementation.  I can't believe how short this
  // file is.  Anyway, carry on.
  
  for (int y = 1; y < tiles.length - 1; y+=2) {
    for (int x = 1; x< tiles[0].length - 1; x+=2) {
      tiles[y][x] = 1;
      int choice = (int) random(0, 2);
      if ((y == 1) && x < tiles[0].length - 2){
        tiles[y][x + 1] = 1;
      } else if  (x == tiles[0].length - 2 && y > 1) {
        tiles[y - 1][x] = 1;
      } else if  (choice == 1 && y != 1) {
        tiles[y - 1][x] = 1;
      } else if (choice == 0 && x != tiles[0].length - 2){
        tiles[y][x + 1] = 1;
      }
    }
  }
  
    for (int y = 0; y < tiles.length; y++) {
    for (int x = 0; x < tiles[0].length; x++) {
      if (tiles[y][x] == 0) {
        square(x * twidth, y * twidth, 10);
      }
    }
  }
  noLoop();
}
