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

void render(float paddingPercentage, float redBand, float greenBand, float blueBand, PGraphics buffer) {
    float lX = x * tileSize + padX;
    float lY = y * tileSize + padY;
    float lW = w * tileSize;
    float lH = h * tileSize;
    float n = evalNoiseWithOctaves(lX, lY, OCTAVES, PERSISTENCE, NOISE_SCALE);

    float actualPadding = Math.min(lW, lH) * paddingPercentage;

    if (lW - 2 * actualPadding <= 1 || lH - 2 * actualPadding <= 1) {
        return; // If after subtracting padding the rectangle would disappear, we don't render it.
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
        buffer.stroke(BACKGROUND_COLOR);
        buffer.fill(chosenColor);
    } else {
        buffer.stroke(chosenColor);
        buffer.noFill();
    }

    // Pixel-by-pixel rendering of the specified region
    int regionWidth = (int) (lW - 2 * actualPadding);
    int regionHeight = (int) (lH - 2 * actualPadding);

    if (regionWidth > 0 && regionHeight > 0) {
        // Extract the region from the original image
        PImage region = original.get((int) (lX + actualPadding), (int) (lY + actualPadding), regionWidth, regionHeight);

        // Load the pixels of the region
        region.loadPixels();

        // Create a transformed region
        PImage transformedRegion = createImage(regionWidth, regionHeight, RGB);
        transformedRegion.loadPixels();

        // Apply pixel-by-pixel transformations using the bands
        for (int y = 0; y < regionHeight; y++) {
            for (int x = 0; x < regionWidth; x++) {
                int index = x + y * regionWidth;
                color c = region.pixels[index];
                float r = constrain(red(c) + redBand, 0, 255);
                float g = constrain(green(c) + greenBand, 0, 255);
                float b = constrain(blue(c) + blueBand, 0, 255);
                transformedRegion.pixels[index] = color(r, g, b);
            }
        }

        // Update the transformed region
        transformedRegion.updatePixels();

        // Draw the transformed region to the buffer
        buffer.image(transformedRegion, lX + actualPadding, lY + actualPadding);
    }
}

}


}

class Tile {
  int x, y;
  float tileSize;
  Tile (int x, int y, float ts) {
    this.x = x;
    this.y = y;
    this.tileSize = ts;
  }
}
