import com.krab.lazy.LazyGui;
import processing.core.PFont;
import processing.core.PGraphics;

import java.util.*;

import processing.core.PApplet;

import static processing.core.PApplet.println;

public class Grid {
    float x, y;
    int rows;
    int cols;
    float tileSize;
    ArrayList<TileRect> rects = new ArrayList<>();
    PApplet pa;
    Tile[][] grid;

    Grid(float x, float y, int r, int c, float tSz, PApplet pa) {
        this.x = x;
        this.y = y;
        this.rows = r;
        this.cols = c;
        this.tileSize = tSz;
        this.pa = pa;
        this.grid = new Tile[rows][cols];
    }

    void tryPlaceRect(int w, int h, String text, int fontSize, int clr, String fontName) {
        for (int i = 0; i < 1000; i++) {
            int tx = PApplet.floor(pa.random(0, cols - 1));
            int ty = PApplet.floor(pa.random(0, rows - 1));
            TileRect tr = new TileRect(tx, ty, w, h, tileSize, text, fontSize, fontName);
            tr.c = clr;
            boolean placed = tr.place(grid);
            if (placed) {
                rects.add(tr);
                break;
            }
        }
    }


    int[] pixelsToTiles(int pixelWidth, int pixelHeight, int tileSize) {
        int tileWidth = PApplet.ceil((float)pixelWidth / tileSize);
        int tileHeight = PApplet.ceil((float)pixelHeight / tileSize);

        return new int[]{tileWidth, tileHeight};
    }

    int[] wordSizeInTiles(String word, float fontSize, PFont font) {
        pa.textFont(font);
        pa.textSize(fontSize);

        // Calculate the width and height of the word in pixels
        float wordWidth = pa.textWidth(word);
        float wordHeight = pa.textAscent() + pa.textDescent();

        // Define padding for width and height
        float paddingWidth = wordWidth * .01f; // 10% of the word width
        float paddingHeight = wordHeight * 0.3f; // 10% of the word height

        // Apply padding to word dimensions
        wordWidth += paddingWidth;
        wordHeight -= paddingHeight;

        // Convert the width and height in pixels to tiles
        return pixelsToTiles((int)wordWidth, (int)wordHeight, PApplet.floor(tileSize));
    }

    void render(PGraphics pg, boolean drawGrid) {


        pg.pushMatrix();
        pg.translate(x, y);

        if (drawGrid) {
            pg.noFill();
            pg.stroke(0);
            pg.strokeWeight(.5f);
            for (int r = 0; r < rows; r++) {
                for (int c = 0; c < cols; c++) {
                    pg.square(c * tileSize, r * tileSize, tileSize);
                }
            }
        }

        //List<Node> path = AStarAlgorithm.findPath(nodes, start, end);
        for (TileRect tr : rects) {

            tr.render(pg, pa);
        }

        pg.popMatrix();
    }


}
