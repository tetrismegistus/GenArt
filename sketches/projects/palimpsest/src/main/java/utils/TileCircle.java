package utils;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PVector;

import java.util.ArrayList;
import java.util.HashMap;

import static processing.core.PApplet.println;

public class TileCircle {
    float cx, cy, r, tileSize;
    ColorPalette palA, palB;
    PApplet pa;
    PGraphics pg;

    public TileCircle(float cx, float cy, float r, ColorPalette paletteA, ColorPalette paletteB, float tileSize, PApplet pa) {
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
                    float px = (x + 0.5f) * tileSize;  // CHANGED: center of tile
                    float py = (y + 0.5f) * tileSize;  // CHANGED
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
                float px = (x + 0.5f) * tileSize;  // CHANGED: center of tile
                float py = (y + 0.5f) * tileSize;  // CHANGED
                if (Math.pow(px - cx, 2) + Math.pow(py - cy, 2) < r * r) {
                    if (b[y][x] != null) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    public void setPGraphics(PGraphics pg) {
        this.pg = pg;
    }


    public void renderTo(float padding, PGraphics target, PApplet pa, HashMap<Character, ArrayList<PVector>> asciiMap) {
        if (this.pg != null) {
            float lX = cx - pg.width  / 2f;   // use actual buffer size
            float lY = cy - pg.height / 2f;
            target.image(this.pg, lX, lY);
        }
    }

    // If you have the window version too, make it match:
    void render(float padding, PApplet pa, HashMap<Character, ArrayList<PVector>> asciiMap) {
        if (this.pg != null) {
            float lX = cx - pg.width  / 2f;
            float lY = cy - pg.height / 2f;
            pa.image(this.pg, lX, lY);
        }
    }


}
