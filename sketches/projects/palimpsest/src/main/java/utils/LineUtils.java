package utils;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PVector;

public class LineUtils {
    private final PApplet p;

    public LineUtils(PApplet p) {
        this.p = p;
    }

    /* ============
       DRAFTSMAN (Style-based)
       ============ */
    public void draftsmanLine(PGraphics g,
                              float x1, float y1, float x2, float y2,
                              LineStyle style) {

        int baseColor = style.strokeColor;

        float distance = p.dist(x1, y1, x2, y2);
        int steps = Math.max(1, (int) (distance * style.stepMultiplier));
        if (style.stepsMax > 0) steps = Math.min(steps, style.stepsMax);

        float baseHue = p.hue(baseColor);
        float baseSat = p.saturation(baseColor);
        float baseBrt = p.brightness(baseColor);

        float baseNoiseOffset = (float) p.randomGaussian() * style.baseNoiseSigma;

        g.colorMode(PApplet.HSB, 360, 100, 100, 1);

        int passes = Math.max(1, style.repeats);
        for (int j = 0; j < passes; j++) {
            for (int i = 0; i <= steps; i++) {
                float t = i / (float) steps;
                float x = PApplet.lerp(x1, x2, t);
                float y = PApplet.lerp(y1, y2, t);
                float n = baseNoiseOffset + t;

                float h = (baseHue + PApplet.map(p.noise(x * style.hueScale, n), 0, 1, -100, 100) + 360f) % 360f;
                float s = PApplet.constrain(baseSat + PApplet.map(p.noise(x * style.satScale, n), 0, 1, -20, 20), 0, 100);
                float b = PApplet.constrain(baseBrt + PApplet.map(p.noise(x * style.brtScale, n), 0, 1, -20, 20), 0, 100);

                float w = PApplet.map(p.noise(x * style.weightScale, n), 0, 1, 0.1f, 2.0f);

                g.stroke(h, s, b, style.baseAlpha);
                g.strokeWeight(w);
                g.point(
                        x + (float) p.randomGaussian() * style.jitterSigma,
                        y + (float) p.randomGaussian() * style.jitterSigma
                );
            }
        }
    }

    /**
     * DRAFTSMAN CIRCLE
     * Draws a noisy “draftsman” ring centered at (cx, cy) with radius r.
     * Steps scale with circumference (2πr) * style.stepMultiplier.
     */
    public void draftsmanCircle(PGraphics g,
                                float cx, float cy, float r,
                                LineStyle style) {

        int baseColor = style.strokeColor;

        // steps proportional to circumference
        float circumference = PApplet.TWO_PI * Math.max(0.001f, r);
        int steps = Math.max(1, (int) (circumference * style.stepMultiplier));
        if (style.stepsMax > 0) steps = Math.min(steps, style.stepsMax);

        float baseHue = p.hue(baseColor);
        float baseSat = p.saturation(baseColor);
        float baseBrt = p.brightness(baseColor);

        float baseNoiseOffset = (float) p.randomGaussian() * style.baseNoiseSigma;

        g.colorMode(PApplet.HSB, 360, 100, 100, 1);

        int passes = Math.max(1, style.repeats);
        for (int j = 0; j < passes; j++) {
            for (int i = 0; i <= steps; i++) {
                float t = i / (float) steps;                 // 0..1
                float theta = t * PApplet.TWO_PI;            // angle
                float ux = p.cos(theta);
                float uy = p.sin(theta);

                float x = cx + r * ux;
                float y = cy + r * uy;

                float n = baseNoiseOffset + t;

                // Use angle as the domain variable for noise (rotational continuity)
                float domain = theta;

                float h = (baseHue + PApplet.map(p.noise(domain * style.hueScale, n), 0, 1, -100, 100) + 360f) % 360f;
                float s = PApplet.constrain(baseSat + PApplet.map(p.noise(domain * style.satScale, n), 0, 1, -20, 20), 0, 100);
                float b = PApplet.constrain(baseBrt + PApplet.map(p.noise(domain * style.brtScale, n), 0, 1, -20, 20), 0, 100);

                float w = PApplet.map(p.noise(domain * style.weightScale, n), 0, 1, 0.1f, 2.0f);

                g.stroke(h, s, b, style.baseAlpha);
                g.strokeWeight(w);
                g.point(
                        x + (float) p.randomGaussian() * style.jitterSigma,
                        y + (float) p.randomGaussian() * style.jitterSigma
                );
            }
        }
    }

    /* ============
       THREADBOX (kept in case you still use it)
       ============ */
    public void threadbox(PGraphics g,
                          float x, float y, float w, float h,
                          float angleDegrees, float spacing,
                          LineStyle style) {

        float angle = p.radians(angleDegrees);
        float dx = p.cos(angle);
        float dy = p.sin(angle);
        float ox = -dy, oy = dx;

        float diag = p.dist(0, 0, w, h);

        for (float i = -diag; i <= diag; i += spacing) {
            float cx = x + w / 2f + i * ox;
            float cy = y + h / 2f + i * oy;

            float x1 = cx - dx * diag;
            float y1 = cy - dy * diag;
            float x2 = cx + dx * diag;
            float y2 = cy + dy * diag;

            PVector[] clipped = clipLineToRect(x1, y1, x2, y2, x, y, w, h);
            if (clipped != null) {
                draftsmanLine(g, clipped[0].x, clipped[0].y, clipped[1].x, clipped[1].y, style);
            }
        }
    }

    /* ============
       CLIPPING
       ============ */
    private PVector[] clipLineToRect(float x1, float y1, float x2, float y2,
                                     float rx, float ry, float rw, float rh) {
        float xmin = rx, xmax = rx + rw;
        float ymin = ry, ymax = ry + rh;

        int code1 = computeOutCode(x1, y1, xmin, xmax, ymin, ymax);
        int code2 = computeOutCode(x2, y2, xmin, xmax, ymin, ymax);

        boolean accept = false;

        while (true) {
            if ((code1 | code2) == 0) { accept = true; break; }
            else if ((code1 & code2) != 0) { break; }
            else {
                float x = 0, y = 0;
                int out = (code1 != 0) ? code1 : code2;

                if ((out & 8) != 0) { // top
                    x = x1 + (x2 - x1) * (ymax - y1) / (y2 - y1); y = ymax;
                } else if ((out & 4) != 0) { // bottom
                    x = x1 + (x2 - x1) * (ymin - y1) / (y2 - y1); y = ymin;
                } else if ((out & 2) != 0) { // right
                    y = y1 + (y2 - y1) * (xmax - x1) / (x2 - x1); x = xmax;
                } else if ((out & 1) != 0) { // left
                    y = y1 + (y2 - y1) * (xmin - x1) / (x2 - x1); x = xmin;
                }

                if (out == code1) {
                    x1 = x; y1 = y;
                    code1 = computeOutCode(x1, y1, xmin, xmax, ymin, ymax);
                } else {
                    x2 = x; y2 = y;
                    code2 = computeOutCode(x2, y2, xmin, xmax, ymin, ymax);
                }
            }
        }

        if (accept) return new PVector[]{ new PVector(x1, y1), new PVector(x2, y2) };
        return null;
    }

    private int computeOutCode(float x, float y, float xmin, float xmax, float ymin, float ymax) {
        int code = 0;
        if (x < xmin) code |= 1; else if (x > xmax) code |= 2;
        if (y < ymin) code |= 4; else if (y > ymax) code |= 8;
        return code;
    }
}
