class TileRect {
  float x, y;
  int w, h;  
  float tileSize;
  boolean draw = true;
  ColorPalette paletteA, paletteB;

  TileRect(float x, float y, int w, int h, ColorPalette paletteA, ColorPalette paletteB, float sw, float tSize) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;      
    this.tileSize = tSize;        
    this.paletteA = paletteA;
    this.paletteB = paletteB;
  }
  
  boolean place(Tile[][] b) {
    if (checkIsValid(b)) {
        for (float cx = x; cx < x + w; cx++) {
            for (float cy = y; cy < y + h; cy++) {
                              
                b[(int)cy][(int)cx] = new Tile((int)cx, (int)cy, tileSize);
            }    
        }
        return true;
    }
    return false;
  }
  
  boolean checkIsValid(Tile[][] b) {    
    if (x + w > b[0].length) {
      return false;
    }
    
    if (y + h > b.length) {
      return false;
    }
    
    for (int cx = (int) x; cx < x + w; cx++) {
      for (int cy = (int) y; cy < y + h; cy++) {
        if (b[cy][cx] != null) {
          return false; 
        }
        
      }    
    }    
    return true;     
  }
  
  void render(float paddingPercentage) {      
      if (draw) {
          float lX = x * tileSize;
          float lY = y * tileSize;
          float lW = w * tileSize;
          float lH = h * tileSize;
  
          // Calculate the padding based on the smallest dimension of the rectangle
          float actualPadding = Math.min(lW, lH) * paddingPercentage;
          
          if (lW - 2 * actualPadding <= 1 || lH - 2 * actualPadding <= 1) {
            return;  // If after subtracting padding the rectangle would disappear, we don't render it.
          }
  
          

          
          // Original corners of the padded rectangle
          float x1 = lX + actualPadding;
          float y1 = lY + actualPadding;
          float x2 = lX + lW - actualPadding;
          float y2 = lY + actualPadding;
          float x3 = lX + lW - actualPadding;
          float y3 = lY + lH - actualPadding;
          float x4 = lX + actualPadding;
          float y4 = lY + lH - actualPadding;
          
          // Apply gaussian displacement to each corner

          
          x1 += randomGaussian() * jitterAmt;
          y1 += randomGaussian() * jitterAmt;
          x2 += randomGaussian() * jitterAmt;
          y2 += randomGaussian() * jitterAmt;
          x3 += randomGaussian() * jitterAmt;
          y3 += randomGaussian() * jitterAmt;
          x4 += randomGaussian() * jitterAmt;
          y4 += randomGaussian() * jitterAmt;
          
          outputBuffer.strokeWeight(1);
          for (float x = x1; x < x2; x++) {
          //float n = evalNoiseWithOctaves(lX, lY, OCTAVES, PERSISTENCE, NOISE_SCALE);  
            for (Float y = y1; y < y3; y++) {

              float n = fbm_warp(x, y, OCTAVES, .1, .9);
              ColorPalette activePalette = getActivePalette(n);
              color randomColor = activePalette.colors[0];
              float brt = map(n, -1, 1, 0, 100);

              outputBuffer.stroke(hue(randomColor), saturation(randomColor), brt, 1);
              outputBuffer.point(x, y);
            }
          }
          
          float n = fbm_warp(x, y, 3, .2, .9);
          ColorPalette activePalette = getActivePalette(n);
          color randomColor = activePalette.getRandomColor();
          outputBuffer.stroke(randomColor);   

          outputBuffer.noFill();
          outputBuffer.strokeWeight(STROKEWEIGHT);
          
          outputBuffer.beginShape();
          outputBuffer.vertex(x1, y1);
          outputBuffer.vertex(x2, y2);
          outputBuffer.vertex(x3, y3);
          outputBuffer.vertex(x4, y4);
          outputBuffer.endShape(CLOSE);

      }
  }
  
  ColorPalette getActivePalette(float n) {
    ColorPalette activePalette = null;
    if (useNoiseForPalette) {
      activePalette = (n > 0) ? paletteA : paletteB;
    } else {
      activePalette = (random(1) > .5) ? paletteA : paletteB;
    }
    return activePalette;
  }
  
}
