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
      color ref = #E7DFC6;
      strokeWeight(.5);
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
  
          for (float x = lX + actualPadding; x < lX + lW - 2*actualPadding; x++) {
          //float n = evalNoiseWithOctaves(lX, lY, OCTAVES, PERSISTENCE, NOISE_SCALE);  
            for (Float y = lY + actualPadding; y < lY + lH; y++) {

              float n = fbm_warp(x, y, 3, .2, .9);

              float brt = map(n, -1, 1, 75, 100);

              outputBuffer.stroke(hue(ref), saturation(ref), brt, 1);
              outputBuffer.point(x, y);
            }
          }
          outputBuffer.stroke(#000000);
          outputBuffer.noFill();
          outputBuffer.strokeWeight(2);
          outputBuffer.rect(lX + actualPadding, lY + actualPadding, lW - 2*actualPadding, lH - 2*actualPadding);
      }
      
      
  }


}
