package utils;

import java.util.*;
import processing.core.PApplet;
import processing.core.PVector;

// These types already exist in your codebase per the snippet:
import utils.PoissonDiscSampler;
import utils.Board;
import utils.TileRect;
import utils.TileCircle;
import utils.MetaShape;

/** Strict extraction of functions from the provided snippet. No new behavior. */
public final class AsemicUtil {

    private AsemicUtil() {} // utility class

    /** Moved from Main.generateAsciiMap(). Populates asciiMap in-place. */
    public static void generateAsciiMap(HashMap<Character, ArrayList<PVector>> asciiMap, PApplet app) {
        float radius = 50;
        int k = 30;
        float centerX = 100 / 2.0f;
        float centerY = 100 / 2.0f;
        PoissonDiscSampler sampler = new PoissonDiscSampler(100, 100, app);

        asciiMap.clear();

        for (char c = 32; c <= 126; c++) {
            ArrayList<PVector> allSamples = sampler.poissonDiskSampling(radius, k);

            // Move points towards the center.
            for (PVector point : allSamples) {
                float dx = centerX - point.x;
                float dy = centerY - point.y;
                point.x += dx * 0.5f;
                point.y += dy * 0.5f;
            }

            ArrayList<PVector> selectedSamples = new ArrayList<>();
            for (int i = 0; i < Math.min((int) app.random(3, 15), allSamples.size()); i++) {
                PVector sample = allSamples.get(i);
                sample.x /= 100;
                sample.y /= 100;
                selectedSamples.add(sample);
            }


            asciiMap.put(c, selectedSamples);
        }
    }

    /** Moved unchanged from Main.computeCentroid(). */
    private static PVector computeCentroid(ArrayList<PVector> points) {
        float cx = 0;
        float cy = 0;
        for (PVector point : points) {
            cx += point.x;
            cy += point.y;
        }
        return new PVector(cx / points.size(), cy / points.size());
    }

    /** Moved unchanged from Main.placeAndDrawWord(). */
    public static boolean placeAndDrawWord(String word, int startX, int startY, float tileSize, float gap, Board page) {
        TileRect tr = page.tryPlaceWord(word, startX, startY, tileSize, gap);
        if (tr != null) {
            tr.word = word;
            tr.tileSize = tileSize;
            tr.gap = gap;
            page.rects.add(tr);
            return true;
        }
        return false;
    }

    public static void placeGutterTile(Board page, int col, int row) {
        utils.TileRect tr = page.tryPlaceGutterTile(col, row);
        if (tr != null) {
            page.rects.add(tr);
        }
    }

    public static void addMetaShape(PApplet app, Board page, int blockWidth, int circleX, int circleY, int sides) {
        MetaShape ms = new MetaShape(blockWidth, blockWidth, app);
        ms.metaShape((float) blockWidth, sides);

        int radius = blockWidth / 2;

        // NEW: convert window -> board-local so it aligns with Board.translate(x,y)
        float localCx = circleX - page.x;
        float localCy = circleY - page.y;

        TileCircle tc = page.tryPlaceCircle(localCx, localCy, radius);

        if (tc != null) {
            tc.setPGraphics(ms.pg);
            page.circles.add(tc);
        }
    }



}
