public class Tile {
    int x, y;
    float tileSize;
    Tile (int x, int y, float ts) {
        this.x = x;
        this.y = y;
        this.tileSize = ts;
    }
}




public class TileRect {
    float x, y, tileSize,gap;
    int w, h;
    int c;
    ColorPalette paletteA, paletteB;
    String word;
    PGraphics pg;

    TileRect(float x, float y, int w, int h, ColorPalette paletteA, ColorPalette paletteB, float sw, float tSize) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.tileSize = tSize;
        this.paletteA = paletteA;
        this.paletteB = paletteB;
        this.gap = 1;
    }

    public void setPGraphics(PGraphics pg) {
        this.pg = pg;
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

    void render(float paddingPercentage, PApplet pa, HashMap<Character, ArrayList<PVector>> asciiMap) {
        float lX = x * tileSize;
        float lY = y * tileSize;
        float lW = w * tileSize;
        float lH = h * tileSize;

        float actualPadding = Math.min(lW, lH) * paddingPercentage;

        if (lW - 2 * actualPadding <= 1 || lH - 2 * actualPadding <= 1) {
            return;  // If after subtracting padding the rectangle would disappear, we don't render it.
        }

        if (this.word != null) {
            // Convert TileRect coordinates to pixel coordinates
            float pixelX = this.x * this.tileSize;
            float pixelY = this.y * this.tileSize;

            // Calculate the width of the word in pixels
            int wordLength = this.word.length();
            float wordWidth = wordLength * this.tileSize + (wordLength - 1) * this.gap;  // word tiles + gaps

            // Calculate the total width and height of the TileRect in pixels
            float rectWidth = this.w * this.tileSize;
            float rectHeight = this.h * this.tileSize;

            // Calculate the starting point to center the word in the rectangle
            float centeredX = pixelX + (rectWidth - wordWidth) / 2;

            // Draw the word at the calculated pixel position
            drawWord(this.word, centeredX, pixelY, this.tileSize, this.gap, pa, asciiMap, false);


        }
        if (this.pg != null) {
            // Render the PGraphics at this rectangle's position
            pa.image(this.pg, lX, lY);
        }

    }

    private void drawWord(String word, float x, float y, float tileSize, float gap, PApplet pa, HashMap<Character, ArrayList<PVector>> asciiMap, boolean isCursive) {
        pa.noFill();
        pa.stroke(0);
        if (pa.random(1) > .9f) {
            pa.strokeWeight(2.5f);
        } else {
            pa.strokeWeight(1.5f);
        }

        float xPos = x;

        if (isCursive) { // Draw in cursive style
            pa.beginShape();
            for (char c : word.toCharArray()) {
                ArrayList<PVector> vectors = getTranslatedVectorsForChar(c, xPos, y, tileSize, asciiMap);
                for (PVector vec : vectors) {
                    // Rotate around (xPos, y) instead of (0,0)
                    PVector rotated = rotatePVectorAroundOrigin(vec, radians(pa.random(20, 30)), new PVector(xPos, y));
                    pa.curveVertex(rotated.x, rotated.y);
                }
                xPos += tileSize + gap;
            }
            pa.endShape();
        } else { // Draw each letter separately
            for (char c : word.toCharArray()) {
                pa.beginShape();
                ArrayList<PVector> vectors = getTranslatedVectorsForChar(c, xPos, y, tileSize, asciiMap);
                PVector rotated = rotatePVectorAroundOrigin(vectors.get(0), radians(pa.random(20, 30)), new PVector(xPos, y));
                pa.curveVertex(rotated.x, rotated.y);
                for (PVector vec : vectors) {
                    // Rotate around (xPos, y) instead of (0,0)
                    rotated = rotatePVectorAroundOrigin(vec, radians(pa.random(20, 30)), new PVector(xPos, y));
                    pa.curveVertex(rotated.x, rotated.y);

                }
                rotated = rotatePVectorAroundOrigin(vectors.get(vectors.size() - 1), radians(pa.random(20, 30)), new PVector(xPos, y));
                pa.curveVertex(rotated.x, rotated.y);
                pa.endShape();
                xPos += tileSize + gap;
            }
        }
    }


    private ArrayList<PVector> getTranslatedVectorsForChar(char c, float x, float y, float tileSize, HashMap<Character, ArrayList<PVector>> asciiMap) {
        ArrayList<PVector> vectors = asciiMap.get(c);
        ArrayList<PVector> translatedVectors = new ArrayList<>();
        if (vectors == null)
            print(c);
        // Iterate through each vector, scale its position, and add the translation
        for (PVector vec : vectors) {
            float px = vec.x * tileSize + x;
            float py = vec.y * tileSize + y;
            translatedVectors.add(new PVector(px, py));
        }

        return translatedVectors;
    }


    PVector rotatePVectorAroundOrigin(PVector p, float angle, PVector origin) {
        // Move to origin
        float x = p.x - origin.x;
        float y = p.y - origin.y;

        // Rotate
        float newX = x * cos(angle) - y * sin(angle);
        float newY = x * sin(angle) + y * cos(angle);

        // Move back
        newX += origin.x;
        newY += origin.y;

        return new PVector(newX, newY);
    }

}

public class TileCircle {
    float cx, cy, r, tileSize;
    ColorPalette palA, palB;
    PApplet pa;
    MetaShape ms;


    TileCircle(float cx, float cy, float r, ColorPalette paletteA, ColorPalette paletteB, float tileSize, PApplet pa) {
        this.cx = cx;
        this.cy = cy;
        this.r = r;
        this.palA = paletteA;
        this.palB = paletteB;
        this.tileSize = tileSize;
        this.pa = pa;
    }

    boolean place(Tile[][] b) {
        if (checkIsValid(b)) {
            for (int y = 0; y < b.length; y++) {
                for (int x = 0; x < b[0].length; x++) {
                    float px = x * tileSize;
                    float py = y * tileSize;

                    if (Math.pow(px - cx, 2) + Math.pow(py - cy, 2) < r * r) {
                        b[y][x] = new Tile(x, y, tileSize);
                    }
                }
            }
            return true;
        }
        return false;
    }

    boolean checkIsValid(Tile[][] b) {
        for (int y = 0; y < b.length; y++) {
            for (int x = 0; x < b[0].length; x++) {
                float px = x * tileSize;
                float py = y * tileSize;

                if (Math.pow(px - cx, 2) + Math.pow(py - cy, 2) < r * r) {
                    if (b[y][x] != null) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    void render(float padding, HashMap<Character, ArrayList<PVector>> asciiMap) {
        float lX = cx - r;
        float lY = cy - r;

        if (this.ms != null) {
            //pa.image(this.pg, lX, lY);
            ms.metaShape(cx, cy, r * 2); // Example draw method, you can adjust parameters
        }
    }

    public void setMetaShape(MetaShape ms) {
        this.ms = ms;
    }
}
