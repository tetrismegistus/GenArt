int cellWidth = 20;
int cellHeight = 20;
int tileCols = 3;
int tileRows= 4;
int tileWidth = tileCols * cellWidth;
int tileHeight = tileRows * cellWidth;
int hmargin = 10;
int vmargin = 10;
int[] tones = {#B22727, #FFFFFF, #2389DA, #006666};


void setup() {
  size(1400, 1740);
  colorMode(HSB, 360, 100, 100, 1);
  noStroke();
  rectMode(CENTER);
}

void draw() {
  background(#667b98);

  for (int y = 0; y < 17; y++) {
    for (int x = 0; x < 17; x++) {
      if (y > 0 && x > 0) {
        drawNumber((x * cellWidth * 4) + cellWidth * 3, (y * cellHeight * 5) + cellWidth * 3 + vmargin, (x - 1) ^ (y - 1), false);
        
      } else if (x > 0 && y == 0) {
        drawNumber((x * cellWidth * 4) + cellWidth * 3, (y * cellHeight * 5) + cellWidth * 3 + vmargin, x - 1, true);        
      } else if (x == 0 && y > 0) {
        drawNumber((x * cellWidth * 4) + cellWidth * 3, (y * cellHeight * 5) + cellWidth * 3 + vmargin, y - 1, true);
      }
    }
  }
  saveFrame("1.png");
  noLoop();
}

void drawNumber(int x, int y, int num, boolean header) {
  

  noFill();
  if (!header) {
    fill(#E0C9A6);
    //noStroke();
    rect(x - 1, y - 1, cellWidth * tileCols + 2, (cellHeight * tileRows) + 5);
  } else {
    fill(#FFFFFF);
    //noStroke();
    rect(x - 1, y - 1, cellWidth * tileCols + 2, (cellHeight * tileRows) + 5);  
  }
  String tile = binary(num);
  int place = 32 - 4; 
  noFill();

  y -= 2;
  
  for (int i = 0; i < 4; i++) {
    if (!header) {
      fill(tones[i]);
    } else { 
      fill(#000000);
    }
    noStroke();
    char passive = tile.charAt(place);
 
    if (passive == '0') {
      
      pushMatrix();
      translate(x + 10 , (y - cellHeight * 1.5) + (cellHeight * i));
      rotate(radians(45));
      square(0, 0, cellWidth*.5);
      popMatrix();
      
      pushMatrix();
      translate(x - 10 , (y - cellHeight * 1.5) + (cellHeight * i));
      rotate(radians(45));      
      square(0, 0, cellWidth*.5);
      popMatrix();
   
    } else {
      pushMatrix();
      translate(x, (y - cellHeight * 1.5) + (cellHeight * i));
      rotate(radians(45));
      square(0, 0, cellWidth*.5);    
      popMatrix();
    }
    place++;
  
  }

}
