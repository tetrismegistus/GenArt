class Tile {
  int tileIndex;
  color col;
  GridLocation loc;
  boolean occupied;
  
  Tile(GridLocation l) {    
    tileIndex = 0;
    loc = l;
    occupied = false;
  }
  
  
 void setTileIndex(Tile[][] tiles) {
   String binaryResult = "";
   if (occupied) {
     if (tiles[loc.x][loc.y - 1].occupied && tiles[loc.x][loc.y - 1].col == col) binaryResult = "1";
       else binaryResult = "0";
     if (tiles[loc.x - 1][loc.y].occupied && tiles[loc.x - 1][loc.y].col == col) binaryResult += "1";
        else binaryResult += "0";
     if (tiles[loc.x][loc.y + 1].occupied && tiles[loc.x][loc.y + 1].col == col) binaryResult += "1";
        else binaryResult += "0";
     if (tiles[loc.x + 1][loc.y].occupied && tiles[loc.x + 1][loc.y].col == col) binaryResult += "1";
        else binaryResult += "0";
     tileIndex = unbinary(binaryResult); 
   }
   
          
 }
 
 void occupy(color c) {
   occupied = true;
   col = c;
 }
 
 void render(float x, float y, float w) {
   if (occupied) {
     fill(col);
     stroke(col);
     strokeWeight(4);
     if (occupied) {
       shapeMode(CENTER);
       switch (tileIndex) {
         case 0:
           tile0(x, y);
           break;
         case 1:
           tile1(x, y, w);
           break;
         case 2:
           tile2(x, y, w);
           break;
         case 3:
           tile3(x, y, w);
           break;
         case 4:
           tile4(x, y, w);
           break;
         case 5:
           tile5(x, y, w);
           break;
         case 6:
           tile6(x, y, w);
           break;
         case 7:
           tile7(x, y, w);
           break;
         case 8:
           tile8(x, y, w);
           break;
         case 9:
           tile9(x, y, w);
           break;
         case 10:
           tile10(x, y, w);
           break;
         case 11:
           tile11(x, y, w);
           break;
         case 12:
           tile12(x, y, w);
           break;  
         case 13:
           tile13(x, y, w);
           break;  
         case 14:
           tile14(x, y, w);
           break;             
         case 15:
           tile15(x, y, w);
           break; 
       }
       noFill();
       //square(x, y, w);
       
       
       
     }
   }
 }
}


class GridLocation {
  int x, y;
  
  GridLocation(int x1, int y1) {
    x = x1;
    y = y1;
  }
}

void tile0(float x, float y) {
  circle(x, y, 3);
}

void tile1(float x, float y, float sz) {  
  line(x, y, x + sz / 2, y);
}

void tile2(float x, float y, float sz) { 
  line(x, y, x, y + sz / 2);
}

void tile3(float x, float y, float sz) {  
  noFill();
  arc(x + sz/2, y + sz/2, sz, sz, PI, 3*PI/2);
}

void tile4(float x, float y, float sz) {
  line(x, y, x - sz/2, y);
}

void tile5(float x, float y, float sz) { 
  line(x + sz/2, y, x - sz/2, y);
}

void tile6(float x, float y, float sz) {    
  noFill();
  arc(x - sz/2, y + sz/2, sz, sz, 3*PI/2, TWO_PI);
}

void tile7(float x, float y, float sz) {
  noFill();
  arc(x - sz/2, y + sz/2, sz, sz, 3*PI/2, TWO_PI);
  arc(x + sz/2, y + sz/2, sz, sz, PI, 3*PI/2);
}

void tile8(float x, float y, float sz) {  
  line(x, y, x, y - sz/2);
}

void tile9(float x, float y, float sz) {  
  noFill();
  arc(x + sz/2, y - sz/2, sz, sz, HALF_PI, PI);
}

void tile10(float x, float y, float sz) {
  line(x, y - sz/2, x, y + sz/2);
}

void tile11(float x, float y, float sz) {  
  noFill();
  arc(x + sz/2, y - sz/2, sz, sz, HALF_PI, PI);
  arc(x + sz/2, y + sz/2, sz, sz, PI, 3*PI/2);
}

void tile12(float x, float y, float sz) {  
  noFill();
  arc(x - sz/2, y - sz/2, sz, sz, 0, HALF_PI);  
}

void tile13(float x, float y, float sz) {  
  noFill();
  arc(x - sz/2, y - sz/2, sz, sz, 0, HALF_PI);  
  arc(x + sz/2, y - sz/2, sz, sz, HALF_PI, PI);
}

void tile14(float x, float y, float sz) {  
  noFill();
  arc(x - sz/2, y - sz/2, sz, sz, 0, HALF_PI);  
  arc(x - sz/2, y + sz/2, sz, sz, 3*PI/2, TWO_PI);
}

void tile15(float x, float y, float sz) {  
  noFill();
  arc(x - sz/2, y - sz/2, sz, sz, 0, HALF_PI);  
  arc(x - sz/2, y + sz/2, sz, sz, 3*PI/2, TWO_PI);   
  arc(x + sz/2, y - sz/2, sz, sz, HALF_PI, PI);
  arc(x + sz/2, y + sz/2, sz, sz, PI, 3*PI/2);
}
