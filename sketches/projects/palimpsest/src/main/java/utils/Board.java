package utils;

import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PGraphics;

import java.util.ArrayList;
import java.util.HashMap;

import utils.LineUtils;
import utils.LineStyle;

import static processing.core.PApplet.println;

public class Board {
    float x, y, tileSize;
    int rows, cols, max_tile_width, max_tile_height;

    Tile[][] board;
    ArrayList<TileRect> rects = new ArrayList<>();
    ArrayList<TileCircle> circles = new ArrayList<>();
    ColorPalette palA, palB;
    PApplet pa;

    private LineUtils asemicLines = null;
    private LineStyle  asemicStyle = null;
    private boolean    asemicUseDraftsman = false;

    public void setAsemicPen(LineUtils lines, LineStyle style, boolean useDraftsman) {
        this.asemicLines = lines;
        this.asemicStyle = style;
        this.asemicUseDraftsman = useDraftsman;
    }

    public Board(float x, float y, int r, int c, float tSz, ColorPalette paletteA, ColorPalette paletteB, int mtw, int mth, PApplet pa) {
        this.x = x;
        this.y = y;
        rows = r;
        cols = c;
        board = new Tile[rows][cols];
        this.tileSize = tSz;
        this.palA = paletteA;
        this.palB = paletteB;
        this.pa = pa;
        this.max_tile_height = mth;
        this.max_tile_width = mtw;
    }

    TileRect tryPlaceTile(int startX, int startY, int startWidth, int startHeight) {
        TileRect tr = new TileRect(startX, startY, pa.width, pa.height, palA, palB, tileSize * rows * .005f, tileSize);
        while (startWidth > 0 && startHeight > 0) {
            if (tr.checkIsValid(board)) {
                tr.place(board);
                return tr;
            }
            if (startWidth > 1) startWidth--;
            if (startHeight > 1) startHeight--;
            tr.w = startWidth;
            tr.h = startHeight;
        }
        return null;
    }

    TileRect tryPlaceGutterTile(int startX, int startY) {
        TileRect tr = new TileRect(startX, startY, 1, 1, palA, palB, tileSize * rows * .005f, tileSize);
        if (tr.checkIsValid(board)) {
            tr.place(board);
            return tr;
        }
        return null;
    }

    public static void placeGutterTile(Board page, int col, int row) {
        utils.TileRect tr = page.tryPlaceGutterTile(col, row);
        if (tr != null) {
            page.rects.add(tr);
        }
    }

    TileCircle tryPlaceCircle(float cx, float cy, float r) {
        TileCircle tc = new TileCircle(cx, cy, r, palA, palB, tileSize, pa);
        if (tc.checkIsValid(board)) {
            tc.place(board);
            circles.add(tc);
            return tc;
        }
        return null;
    }

    public TileRect tryPlaceWord(String word, int startX, int startY, float tileSize, float gap) {
        int wordTileLength = calculateWordTileLength(word, tileSize, gap);
        TileRect tr = new TileRect(startX, startY, wordTileLength, 1, palA, palB, 1, tileSize);
        tr.setBoardTileSize(this.tileSize);   // NEW: tell it the grid’s pixel size
        if (tr.checkIsValid(board)) {
            tr.place(board);
            tr.word = word;
            return tr;
        }
        return null;
    }


    public int calculateWordTileLength(String word, float tileSize, float gap) {
        return (int) Math.ceil((word.length() * tileSize + (word.length() - 1) * gap) / tileSize);
    }

    public void render(float padding, HashMap<Character, ArrayList<PVector>> asciiMap) {
        pa.pushMatrix();
        pa.translate(x, y);
        for (TileCircle tc : circles) {
            tc.render(padding, pa, asciiMap);
        }
        for (TileRect tr : rects) {
            tr.setAsemicPen(asemicLines, asemicStyle, asemicUseDraftsman);  // <-- add this line
            tr.render(padding, pa, asciiMap);

        }
        pa.popMatrix();
    }

    public void renderTo(PGraphics target, PApplet pa, float padding, HashMap<Character, ArrayList<PVector>> asciiMap) {
        target.pushMatrix();
        target.translate(x, y);

        // Make sure images draw from top-left
        target.imageMode(PApplet.CORNER);

        for (TileCircle tc : circles) {
            tc.renderTo(padding, target, pa, asciiMap);
        }
        for (TileRect tr : rects) {
            tr.renderTo(padding, target, pa, asciiMap);
        }

        target.popMatrix();
    }


}
