package utils;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PVector;

import java.util.ArrayList;
import java.util.HashMap;

import utils.LineUtils;
import utils.LineStyle;

import static processing.core.PApplet.*;

public class TileRect {
    float x, y, tileSize, gap;
    int w, h;
    int c;
    ColorPalette paletteA, paletteB;
    String word;
    PGraphics pg;
    private LineUtils linesPen = null;
    private LineStyle lineStyle = null;
    private boolean useDraftsman = false;
    float boardTileSize = -1f;

    public TileRect(float x, float y, int w, int h, ColorPalette paletteA, ColorPalette paletteB, float sw, float tSize) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.tileSize = tSize;
        this.paletteA = paletteA;
        this.paletteB = paletteB;
        this.gap = 1;
    }

    public void setAsemicPen(LineUtils lines, LineStyle style, boolean useDraftsman) {
        this.linesPen = lines;
        this.lineStyle = style;
        this.useDraftsman = useDraftsman;
    }

    public void setBoardTileSize(float pxPerTile) {
        this.boardTileSize = pxPerTile;
    }

    public void setPGraphics(PGraphics pg) {
        this.pg = pg;
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
        float ts = (boardTileSize > 0 ? boardTileSize : tileSize); // position uses board tile size
        float lX = x * ts;
        float lY = y * ts;
        float lW = w * ts;
        float lH = h * ts;

        float actualPadding = Math.min(lW, lH) * paddingPercentage;
        if (lW - 2 * actualPadding <= 1 || lH - 2 * actualPadding <= 1) return;

        if (this.word != null) {
            float pixelX = this.x * ts;
            float pixelY = this.y * ts;

            int wordLength = this.word.length();
            float wordWidth  = wordLength * this.tileSize + (wordLength - 1) * this.gap; // glyph scale
            float rectWidth  = this.w * ts;
            float centeredX  = pixelX + (rectWidth - wordWidth) / 2;

            drawWord(this.word, centeredX, pixelY, this.tileSize, this.gap, pa, asciiMap); // glyphs use char tile size
        }

        if (this.pg != null) {
            pa.image(this.pg, lX, lY);
        }
    }


    public void renderTo(float paddingPercentage, PGraphics target, PApplet pa, HashMap<Character, ArrayList<PVector>> asciiMap) {
        float ts = (boardTileSize > 0 ? boardTileSize : tileSize); // position uses board tile size
        float lX = x * ts;
        float lY = y * ts;
        float lW = w * ts;
        float lH = h * ts;

        float actualPadding = Math.min(lW, lH) * paddingPercentage;
        if (lW - 2 * actualPadding <= 1 || lH - 2 * actualPadding <= 1) return;

        if (this.word != null) {
            float pixelX = this.x * ts;
            float pixelY = this.y * ts;

            int wordLength = this.word.length();
            float wordWidth  = wordLength * this.tileSize + (wordLength - 1) * this.gap; // glyph scale
            float rectWidth  = this.w * ts;
            float centeredX  = pixelX + (rectWidth - wordWidth) / 2;

            // draftsman path
            if (useDraftsman && linesPen != null && lineStyle != null) {
                float xPos = centeredX;
                for (char c : word.toCharArray()) {
                    ArrayList<PVector> vectors = getTranslatedVectorsForChar(c, xPos, pixelY, this.tileSize, asciiMap);
                    if (vectors != null && vectors.size() >= 2) {
                        PVector prev = vectors.get(0);
                        for (int i = 1; i < vectors.size(); i++) {
                            PVector curr = vectors.get(i);
                            linesPen.draftsmanLine(target, prev.x, prev.y, curr.x, curr.y, lineStyle);
                            prev = curr;
                        }
                    }
                    xPos += tileSize + gap;
                }
            } else {
                target.noFill();
                target.stroke(0);
                target.strokeWeight(pa.random(1) > .9f ? 1.5f : 1f);

                float xPos = centeredX;
                for (char c : word.toCharArray()) {
                    ArrayList<PVector> vectors = getTranslatedVectorsForChar(c, xPos, pixelY, this.tileSize, asciiMap);
                    target.beginShape();
                    for (PVector vec : vectors) {
                        PVector rotated = rotatePVectorAroundOrigin(vec, radians(pa.random(20, 30)), new PVector(xPos, pixelY));
                        target.curveVertex(rotated.x, rotated.y);
                    }
                    target.endShape();
                    xPos += tileSize + gap;
                }
                target.endShape();
            }
        }

        if (this.pg != null) {
            target.image(this.pg, lX, lY);
        }
    }



    private void drawWord(String word, float x, float y, float tileSize, float gap, PApplet pa, HashMap<Character, ArrayList<PVector>> asciiMap) {
        // draftsman mode (preferred if wired)
        if (useDraftsman && linesPen != null && lineStyle != null) {
            float xPos = x;
            for (char c : word.toCharArray()) {
                ArrayList<PVector> vectors = getTranslatedVectorsForChar(c, xPos, y, tileSize, asciiMap);
                if (vectors != null && vectors.size() >= 2) {
                    // connect successive points in the glyph
                    PVector prev = vectors.get(0);
                    for (int i = 1; i < vectors.size(); i++) {
                        PVector curr = vectors.get(i);
                        linesPen.draftsmanLine(pa.g, prev.x, prev.y, curr.x, curr.y, lineStyle);
                        prev = curr;
                    }
                }
                xPos += tileSize + gap;
            }
            return;
        }

        // fallback: your original curve-based stroke
        pa.noFill();
        pa.stroke(0);
        if (pa.random(1) > .9f) {
            pa.strokeWeight(1.5f);
        } else {
            pa.strokeWeight(1f);
        }



    }



    private ArrayList<PVector> getTranslatedVectorsForChar(char c, float x, float y, float tileSize, HashMap<Character, ArrayList<PVector>> asciiMap) {
        ArrayList<PVector> vectors = asciiMap.get(c);
        ArrayList<PVector> translatedVectors = new ArrayList<>();
        if (vectors == null)
            print(c);
        for (PVector vec : vectors) {
            float px = vec.x * tileSize + x;
            float py = vec.y * tileSize + y;
            translatedVectors.add(new PVector(px, py));
        }
        return translatedVectors;
    }

    PVector rotatePVectorAroundOrigin(PVector p, float angle, PVector origin) {
        float x = p.x - origin.x;
        float y = p.y - origin.y;
        float newX = x * cos(angle) - y * sin(angle);
        float newY = x * sin(angle) + y * cos(angle);
        newX += origin.x;
        newY += origin.y;
        return new PVector(newX, newY);
    }




}
