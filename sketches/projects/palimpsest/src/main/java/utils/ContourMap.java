package utils;

import processing.core.PGraphics;

import noise.OpenSimplexNoise;
import processing.core.PApplet;


public class ContourMap {
    private final PApplet p;
    public float ix, iy, fbmLacunarity, fbmGain, off;
    int fbmOctaves;
    boolean fbmEnabled;
    OpenSimplexNoise noise;
    NoiseUtils warp;
    private final LineUtils lines;
    float contourStepLength  = 2;
    LineStyle s1;
    LineStyle s2;

    public ContourMap(PApplet p, OpenSimplexNoise noise, int fbmOctaves, float fbmLacunarity, float fbmGain,
                      boolean fbmEnabled, float off, float contourStepLength, LineUtils lines) {
        this.p = p;
        this.noise = noise;
        this.lines = lines;
        warp = new NoiseUtils(noise);
        this.fbmOctaves = fbmOctaves;
        this.fbmLacunarity = fbmLacunarity;
        this.fbmGain = fbmGain;
        this.off = off;
        this.contourStepLength = contourStepLength;
        this.fbmEnabled = fbmEnabled;
        this.ix = 0;
        this.iy = 0;
        s1 = new LineStyle(0x12776d);
        s2 = new LineStyle(0x000000);
    }


    public void buildMapLayer(PGraphics g, LineStyle style,
                              float startX, float startY, float regionW, float regionH) {
        g.beginDraw();
        g.colorMode(p.HSB, 360, 100, 100, 1);

        // === GRID (region-based, border-aligned) ===
        g.noFill();
        final int cellSize = 50;

        // clamp region to graphics bounds
        float rx0 = p.constrain(startX, 0, g.width);
        float ry0 = p.constrain(startY, 0, g.height);
        float rx1 = p.constrain(startX + regionW, 0, g.width);
        float ry1 = p.constrain(startY + regionH, 0, g.height);

        // snap inner box to cell grid
        int left   = (int)(Math.ceil (rx0 / cellSize) * cellSize + p.randomGaussian()  * 10);
        int top    = (int)(Math.ceil (ry0 / cellSize) * cellSize);
        int right  = (int)(Math.floor(rx1 / cellSize) * cellSize);
        int bottom = (int)(Math.floor(ry1 / cellSize) * cellSize);

        // guard against degenerate region
        if (right - left < cellSize || bottom - top < cellSize) {
            g.endDraw();
            return;
        }

        // --- agents only within the inner box ---
        p.println("parachutes");
        int drops = p.max(1, ((right - left) * (bottom - top)) / 2500);
        for (int i = 0; i < drops; i++) {
            float ax = p.random(left,  right);
            float ay = p.random(top,   bottom);
            dropAgent(g, ax, ay, style, left, top, right, bottom);
        }
        p.println("deployed");

        // grid
        for (int x = left; x + cellSize <= right; x += cellSize) {
            for (int y = top; y + cellSize <= bottom; y += cellSize) {
                lines.rectOutline(g, x, y, cellSize, cellSize, s2);
            }
        }

        // labels (span full edges of grid box)
        g.textSize(10);
        g.fill(0);

        int degTop = (int)p.random(70);
        for (int x = left; x < right; x += cellSize) {
            g.text(degTop++ + "°", x, top - 2);
        }

        int degLeft = (int)p.random(70);
        g.pushMatrix();
        g.translate(left - 3, bottom);
        g.rotate(p.radians(270));
        for (int y = 0; y < (bottom - top); y += cellSize) {
            g.text(degLeft++ + "°", y, 0);
        }
        g.popMatrix();

        // borders tight to the grid box
        float innerW = right  - left;
        float innerH = bottom - top;

        g.pushMatrix(); g.translate(left,  top);              drawBorder(g, innerW); g.popMatrix();        // top
        g.pushMatrix(); g.translate(left,  bottom);           drawBorder(g, innerW); g.popMatrix();        // bottom
        g.pushMatrix(); g.translate(left,  top);    g.rotate(p.radians(90)); drawBorder(g, innerH); g.popMatrix(); // left
        g.pushMatrix(); g.translate(right, top);    g.rotate(p.radians(90)); drawBorder(g, innerH); g.popMatrix(); // right

        g.endDraw();
    }

    void dropAgent(PGraphics g, float x, float y, LineStyle style,
                   int left, int top, int right, int bottom) {

        if (x < left || x > right || y < top || y > bottom) return;

        g.strokeWeight(.1f);
        if (noContourNear(g, x, y, style.strokeColor)) {
            g.stroke(style.strokeColor);
            renderContour(g, x, y, style, left, top, right, bottom);
        }
    }


    boolean nn() {
        float brder = .5f;
        // compare normalized field at current point to the seed iso-value “border”
        return p.abs(fbm01(ix * off, iy * off) - brder) < 0.02;
    }

/* -------------------------
   Helpers
   ------------------------- */

    // geometric amplitude sum for classic fBM
    float amplitudeSum(int octaves, float gain) {
        if (p.abs(gain - 1.0f) < 1e-9) return octaves; // edge case
        return (1.0f - p.pow(gain, octaves)) / (1.0f - gain);
    }

    // Field mapped to [0,1]; uses fBM when enabled, else plain OpenSimplex
    float fbm01(float x, float y) {
        if (!fbmEnabled) {
            float n = (float) noise.eval(x, y, 0.0);
            return n * 0.5f + 0.5f;
        }
        float raw = warp.fbmWarp(x, y, 0, this.fbmOctaves, this.fbmLacunarity, this.fbmGain);
        float A = amplitudeSum(this.fbmOctaves, this.fbmGain);
        return p.constrain(raw / (2.0f*A) + 0.5f, 0, 1);  // [-A,+A] -> [0,1]
    }

    // Tunable tolerance (in 0..255 RGB space). 28–40 works well for AA edges.
    private static final int COLOR_TOLERANCE = 10;

    private boolean nearColorRGB(int c, int ref, int tol) {
        int r  = (c >> 16) & 0xFF, g  = (c >> 8) & 0xFF,  b  = c & 0xFF;
        int rr = (ref >> 16) & 0xFF, gg = (ref >> 8) & 0xFF, bb = ref & 0xFF;
        int dr = r - rr, dg = g - gg, db = b - bb;
        // compare squared distance to avoid sqrt
        return (dr*dr + dg*dg + db*db) <= (tol * tol);
    }

    boolean noContourNear(PGraphics g, float x, float y, int strokeColor) {
        g.loadPixels();
        final int tol = COLOR_TOLERANCE;

        for (int j = 1; j < 15; j++) {
            for (int nA = 0; nA < 360; nA += 1) {
                float nX = j * p.cos(p.radians(nA)) + x;
                float nY = j * p.sin(p.radians(nA)) + y;
                int ixp = (int) nX, iyp = (int) nY;
                if (ixp < 0 || ixp >= g.width || iyp < 0 || iyp >= g.height) continue;
                int idx = ixp + iyp * g.width;

                // consider the neighborhood "occupied" if pixel is close to the intended stroke color
                if (nearColorRGB(g.pixels[idx], strokeColor, tol)) {
                    return false;
                }
            }
        }
        return true;
    }


    // keep your existing renderContour(...) if you want; add this bounded version
    void renderContour(PGraphics g, float nx, float ny, LineStyle style,
                       int left, int top, int right, int bottom) {
        ix = nx;
        iy = ny;

        float d = 0;
        float sx = ix, sy = iy;

        for (int i = 0; i < 10000; i++) {
            float od = d;
            float ox = ix, oy = iy;

            // angular search for next point on iso-contour
            for (d = od + p.HALF_PI;
                 (d > od - p.HALF_PI && !nn()) || d == od + p.HALF_PI;
                 d -= .17) {
                float tx = ox + contourStepLength * p.cos(d);
                float ty = oy - contourStepLength * p.sin(d);
                // if proposed step leaves the box, stop searching further angles
                if (tx < left || tx > right || ty < top || ty > bottom) break;
                ix = tx; iy = ty;
            }

            // if we stepped out of bounds, stop the contour
            if (ix < left || ix > right || iy < top || iy > bottom) break;

            lines.draftsmanLine(g, ox, oy, ix, iy, style);

            if (p.dist(ix, iy, sx, sy) < contourStepLength && i > 1) {
                if (i > 4) lines.draftsmanLine(g, ix, iy, sx, sy, style); // close loop
                break;
            }
        }
    }


    void drawBorder(PGraphics g, float length) {


        for (float x = 0; x <= length - 50; x += 50) {
            for (int i = 0; i < 3; i++) {
                float jx  = x + p.randomGaussian();
                float jy  = p.randomGaussian();
                lines.rectOutline(g, jx, jy, 25, 2, s1);

                float jx2 = (x + 25) + p.randomGaussian() * 2;
                float jy2 = p.randomGaussian();
                lines.rectOutline(g, jx2, jy2, 25, 2, s2);
            }
        }
    }
}
