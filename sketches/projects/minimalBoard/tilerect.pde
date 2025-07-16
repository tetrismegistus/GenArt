class TileRect {
  float x, y;
  int w, h;
  color c;
  float tileSize;
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
    float lX = x * tileSize + padX;
    float lY = y * tileSize + padY;
    float lW = w * tileSize;
    float lH = h * tileSize;
    float n = evalNoiseWithOctaves(lX, lY, OCTAVES, PERSISTENCE, NOISE_SCALE);
    
    float actualPadding = Math.min(lW, lH) * paddingPercentage;
          
    if (lW - 2 * actualPadding <= 1 || lH - 2 * actualPadding <= 1) {
      return;  // If after subtracting padding the rectangle would disappear, we don't render it.
    }
    float radius = map(n, -1, 1, 0, 20);
    
    ColorPalette activePalette;
    
    
    if (useNoiseForPalette) {
      activePalette = (n > COLOR_THRESH) ? paletteA : paletteB;
    } else {
      activePalette = (random(1) > .5) ? paletteA : paletteB;
    }
    
    // Use the noise value to get the color instead of selecting it randomly
    color chosenColor = activePalette.getColorFromNoise(n);
  
    if (n > FILL_THRESHOLD) {
        outputBuffer.stroke(BACKGROUND_COLOR);
        outputBuffer.fill(chosenColor);      
    } else {
        outputBuffer.stroke(chosenColor);         
        outputBuffer.noFill();
    }
    
    outputBuffer.rect(lX + actualPadding, lY + actualPadding, lW - 2*actualPadding, lH - 2*actualPadding, radius);
  }
}
