import processing.core.PApplet;
import processing.core.PGraphics;

class TileRect {
    int x, y;
    int w, h;
    int c;
    float tileSize;
    boolean draw = true;


    TileRect(int x, int y, int w, int h, float tSize) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;

        this.tileSize = tSize;
    }

    boolean place(Tile[][] b, PApplet pa, Node[][] nodes) {
        if (checkIsValid(b)) {
            for (int cx = x; cx < x + w; cx++) {
                for (int cy = y; cy < y + h; cy++) {
                    b[cy][cx] = new Tile(cx, cy, c, tileSize);
                    nodes[cy][cx].isObstacle = true;
                    if (cx == x + w - 1 && w < h) nodes[cy][cx + 1].isTerminal = true;
                    if (cx == x && w < h) nodes[cy][cx - 1].isTerminal = true;
                    if (cy == y && h < w) nodes[cy - 1][cx].isTerminal = true;
                    if (cy == y + h - 1 && h < w) nodes[cy + 1][cx].isTerminal = true;
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
                if (b[cy - 2][cx - 2] != null) return false;
                if (b[cy + 2][cx + 2] != null) return false;
                if (b[cy - 2][cx + 2] != null) return false;
                if (b[cy + 2][cx - 2] != null) return false;
                if (b[cy - 2][cx] != null) return false;
                if (b[cy + 2][cx] != null) return false;
                if (b[cy][cx - 2] != null) return false;
                if (b[cy][cx + 2] != null) return false;
                if (b[cy - 1][cx - 1] != null) return false;
                if (b[cy + 1][cx + 1] != null) return false;
                if (b[cy - 1][cx + 1] != null) return false;
                if (b[cy + 1][cx - 1] != null) return false;
                if (b[cy - 1][cx] != null) return false;
                if (b[cy + 1][cx] != null) return false;
                if (b[cy][cx - 1] != null) return false;
                if (b[cy][cx + 1] != null) return false;
            }
        }

        return true;
    }

    void render(PGraphics pg) {
        if (draw) {

            pg.noStroke();
            //stroke(c);
            pg.fill(c);
            pg.stroke(0);
            //pg.noFill();
            float lX = x * tileSize;
            float lY = y * tileSize;
            float lW = w * tileSize;
            float lH = h * tileSize;

            pg.rect(lX, lY, lW, lH);
        }
    }
}