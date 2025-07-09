import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PFont;

class TileRect {
    int x, y;
    int w, h;
    int c;
    float tileSize;
    boolean draw = true;
    String text;
    String font;
    int fontSize;


    TileRect(int x, int y, int w, int h, float tSize, String t, int fontSize, String font) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.text = t;
        this.tileSize = tSize;
        this.fontSize = fontSize;
        this.font = font;

    }

    boolean place(Tile[][] b) {
        if (checkIsValid(b)) {
            for (int cx = x; cx < x + w; cx++) {
                for (int cy = y; cy < y + h; cy++) {
                    b[cy][cx] = new Tile(cx, cy, c, tileSize);
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

        if (x == 0 || x == b[0].length - 1 || y == 0 || y == b.length - 1) return false;
        if (x < 0 || x + w >= b[0].length - 1  || y < 0 || y + h >= b.length - 1) return false;


        for (int cx =  x; cx < x + w; cx++) {
            for (int cy =  y; cy < y + h; cy++) {
                if (b[cy][cx] != null) return false;
            }
        }

        return true;
    }

    void render(PGraphics pg, PApplet pa) {
        if (draw) {



            float lX = x * tileSize;
            float lY = y * tileSize;
            float lH = h * tileSize;
            float lW = w * tileSize;
            pg.noFill();
            pg.stroke(0);
            //pg.rect(lX, lY, lW, lH);
            PFont myFont = pa.createFont(font, this.fontSize);
            pg.textFont(myFont);
            pg.textSize(fontSize);
            pg.fill(pg.red(c), pg.green(c), pg.blue(c));

            float textY = lY + lH/1.05f;
            pg.text(this.text, lX, textY);
        }
    }
}