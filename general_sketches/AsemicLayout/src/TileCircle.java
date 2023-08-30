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

    void render(float padding, PApplet pa, HashMap<Character, ArrayList<PVector>> asciiMap) {
        float lX = cx - r;
        float lY = cy - r;

        if (this.pg != null) {
            pa.image(this.pg, lX, lY);
        }
    }

    public void setPGraphics(PGraphics pg) {
        this.pg = pg;
    }

}