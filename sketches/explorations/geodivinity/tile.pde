void drawNumber(float x, float y, int num, boolean header) {
  

  
  if (!header) {
    fill(#E0C9A6);
    noStroke();
    //rect(x - 3, y - 3, cellWidth * tileCols + 2, (cellHeight * tileRows)  + 3);
  } else {
    fill(#FFFFFF);
    noStroke();
    rect(x - 1, y - 1, cellWidth * tileCols + 2, (cellHeight * tileRows) + 3);  
  }
  String tile = binary(num);
  int place = 32 - 4; 
  noFill();

  y -= 2;
  
  for (int i = 0; i < 4; i++) {
    if (!header) {
      fill(tones[i]);
    } else { 
      fill(0);
    }
    noStroke();
    char passive = tile.charAt(place);
    
    if (passive == '0') {
      
      pushMatrix();
      translate(x + cellWidth , (y - cellHeight * 1.05) + (cellHeight * i) * 2);
      rotate(radians(45));
      square(0, 0, cellWidth);
      popMatrix();
      
      pushMatrix();
      translate(x - cellWidth , (y - cellHeight * 1.05) + (cellHeight * i) * 2);
      rotate(radians(45));      
      square(0, 0, cellWidth);
      popMatrix();
   
    } else {
      pushMatrix();
      translate(x, (y - cellHeight * 1.05) + (cellHeight * i) * 2);
      rotate(radians(45));
      square(0, 0, cellWidth);    
      popMatrix();
    }
    place++;
  
  }

}
