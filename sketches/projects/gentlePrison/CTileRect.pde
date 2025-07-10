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

void render(PGraphics pg, float padding, int fillMode) {
  if (!draw) return;

  if (fillMode == SOLID_FILL) {
    solidFill(pg, padding);
  } else if (fillMode == NOISE_FILL) {
    noiseFill(pg, padding);
  } else if (fillMode == THREAD_FILL) {
    fillWithThread(pg, padding);
  } else if (fillMode == COMBO_FILL) {
    solidFill(pg, padding);
    fillWithThread(pg, padding);
  }
}

  ColorPalette getActivePalette(float n) {
    if (useNoiseForPalette) {
      return (n > 0) ? paletteA : paletteB;
    } else {
      return (random(1) > 0.5) ? paletteA : paletteB;
    }
  }

  void solidFill(PGraphics pg, float paddingPercentage) {
    float actualPadding = min(lW, lH) * paddingPercentage;
    if (lW - 2 * actualPadding <= 1 || lH - 2 * actualPadding <= 1) return;

    ColorPalette palette = getActivePalette(noiseValue);
    color chosenColor = palette.getRandomColor();

    if (noiseValue > FILL_THRESHOLD) {
      pg.stroke(BACKGROUND_COLOR);
      pg.fill(chosenColor);
    } else {
      pg.stroke(chosenColor);
      pg.noFill();
    }

    pg.rect(lX + actualPadding, lY + actualPadding, lW - 2 * actualPadding, lH - 2 * actualPadding);
  }

  void noiseFill(PGraphics pg, float paddingPercentage) {
    float actualPadding = min(lW, lH) * paddingPercentage;
    if (lW - 2 * actualPadding <= 1 || lH - 2 * actualPadding <= 1) return;

    float x1 = lX + actualPadding + randomGaussian() * jitterAmt;
    float y1 = lY + actualPadding + randomGaussian() * jitterAmt;
    float x2 = lX + lW - actualPadding + randomGaussian() * jitterAmt;
    float y2 = y1 + randomGaussian() * jitterAmt;
    float x3 = x2 + randomGaussian() * jitterAmt;
    float y3 = lY + lH - actualPadding + randomGaussian() * jitterAmt;
    float x4 = x1 + randomGaussian() * jitterAmt;
    float y4 = y3 + randomGaussian() * jitterAmt;

    pg.strokeWeight(1);
    for (float x = x1; x < x2; x++) {
      for (float y = y1; y < y3; y++) {
        float n = fbm_warp(x, y, 3, .2, .9);

        ColorPalette palette = getActivePalette(n);
        color c = palette.colors[0];
        float brt = map(n, -1, 1, 0, 100);
        pg.stroke(hue(c), saturation(c), brt, 1);
        pg.point(x, y);
      }
    }

    pg.noFill();
    pg.strokeWeight(STROKEWEIGHT);
    pg.stroke(getActivePalette(noiseValue).getRandomColor());
    pg.beginShape();
    pg.vertex(x1, y1);
    pg.vertex(x2, y2);
    pg.vertex(x3, y3);
    pg.vertex(x4, y4);
    pg.endShape(CLOSE);
  }

void fillWithThread(PGraphics pg, float paddingPercentage) {
    float actualPadding = min(lW, lH) * paddingPercentage;
    if (lW - 2 * actualPadding <= 1 || lH - 2 * actualPadding <= 1) return;
    
    // Use consistent thread spacing globally
    float spacing = min(lW, lH) * 0.15;
    
    // Apply jitter to placement (but not to the actual threadbox dimensions)
    float jitterX = (float) randomGaussian() * spacing * 0.2;
    float jitterY = (float) randomGaussian() * spacing * 0.3;
    float px = lX + jitterX;
    float py = lY + jitterY;
    
    float boxW = lW - 2 * actualPadding;
    float boxH = lH - 2 * actualPadding;
    if (boxW <= 1 || boxH <= 1) return;
    
    float centerX = px + boxW / 2;
    float centerY = py + boxH / 2;
    
    // Global-style angle using shared noise field

    float angle = map(fbm_warp(lX, lY, OCTAVES, .1, .9), -1, 1, 0, 360);
    
    ColorPalette palette = getActivePalette(noiseValue);
    color chosenColor = palette.getRandomColor();


    threadbox(pg, px, py, boxW, boxH, angle, 1, chosenColor);
}

}
