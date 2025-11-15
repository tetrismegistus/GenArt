class TileRect {
  float x, y;
  int w, h;
  float tileSize;
  boolean draw = true;
  ColorPalette paletteA, paletteB;
  float noiseValue;
  float lX, lY, lW, lH;

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
          b[(int) cy][(int) cx] = new Tile((int) cx, (int) cy, tileSize);
        }
      }
      return true;
    }
    return false;
  }

  boolean checkIsValid(Tile[][] b) {
    if (x + w > b[0].length || y + h > b.length) return false;

    for (int cx = (int) x; cx < x + w; cx++) {
      for (int cy = (int) y; cy < y + h; cy++) {
        if (b[cy][cx] != null) return false;
      }
    }
    return true;
  }

  ColorPalette getActivePalette(float n) {
    if (useNoiseForPalette) {
      return (n > 0) ? paletteA : paletteB;
    } else {
      return (random(1) > 0.5) ? paletteA : paletteB;
    }
  }


}
