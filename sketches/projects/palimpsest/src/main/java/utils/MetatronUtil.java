package utils;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PVector;

public class MetatronUtil {
    private final PApplet app;
    private final LineUtils lines;

    public MetatronUtil(PApplet app, LineUtils lines) {
        this.app = app;
        this.lines = lines;
    }

    /** Back-compat: no transform/jitter. */
    public void metaShape(PGraphics g,
                          float x, float y, float height,
                          int sides, int refColorHSB,
                          boolean useDraftsman, LineStyle style) {
        metaShape(g, x, y, height, sides, refColorHSB, useDraftsman, style,
                /*rotDeg*/0f, /*dx*/0f, /*dy*/0f,
                /*endpointJitterSigma*/0f, /*radiusJitterSigma*/0f);
    }

    /**
     * Jitterable version:
     * - rotDeg: rotate the whole motif around its center (degrees)
     * - dx, dy: translate the motif
     * - endpointJitterSigma: per-vertex Gaussian jitter (pixels) applied to line endpoints
     * - radiusJitterSigma: Gaussian jitter (pixels) applied to circle radius (per pass)
     */
    public void metaShape(PGraphics g,
                          float x, float y, float height,
                          int sides, int refColorHSB,
                          boolean useDraftsman, LineStyle style,
                          float rotDeg, float dx, float dy,
                          float endpointJitterSigma, float radiusJitterSigma) {

        final float cy     = y + height / 2f;
        final float rSmall = height * 0.25f;
        final float rLarge = rSmall * 2f;

        // base polygon vertices before transforms
        PVector[] baseV1 = polygonVertices(x, cy, sides, rSmall);
        PVector[] baseV2 = polygonVertices(x, cy, sides, rLarge);

        g.beginDraw();
        g.colorMode(PApplet.HSB, 360, 100, 100, 1);

        // Apply global transform (rotate about center, then offset)
        g.pushMatrix();
        g.translate(x, cy);
        g.rotate(app.radians(rotDeg));
        g.translate(dx, dy);
        g.translate(-x, -cy);

        // Prepare styles
        LineStyle ringStyle = copyStyle(style);
        ringStyle.strokeColor = refColorHSB; // rings respect the ring picker color

        // Draw vertex rings
        drawRings(g, baseV1, rSmall * 2f, useDraftsman, ringStyle, radiusJitterSigma);
        drawRings(g, baseV2, rSmall * 2f, useDraftsman, ringStyle, radiusJitterSigma);

        // Center ring
        drawSingleRing(g, x, cy, rSmall * 2f, useDraftsman, ringStyle, radiusJitterSigma);

        // Webs (vertex connections), with per-endpoint jitter
        drawPolyConnections(g, baseV1, useDraftsman, style, endpointJitterSigma);
        drawPolyConnections(g, baseV2, useDraftsman, style, endpointJitterSigma);

        // Cross connections between the two polygons
        connectPolys(g, baseV1, baseV2, useDraftsman, style, endpointJitterSigma);

        g.popMatrix();
        g.endDraw();
    }

    // --- helpers -------------------------------------------------------------

    private PVector[] polygonVertices(float cx, float cy, int sides, float radius) {
        PVector[] pts = new PVector[sides];
        float step = app.radians(360f / sides);
        for (int i = 0; i < sides; i++) {
            float a = i * step;
            pts[i] = new PVector(radius * app.cos(a) + cx, radius * app.sin(a) + cy);
        }
        return pts;
    }

    private LineStyle copyStyle(LineStyle src) {
        LineStyle s = new LineStyle(src.strokeColor);
        s.baseAlpha      = src.baseAlpha;
        s.hueScale       = src.hueScale;
        s.satScale       = src.satScale;
        s.brtScale       = src.brtScale;
        s.weightScale    = src.weightScale;
        s.baseNoiseSigma = src.baseNoiseSigma;
        s.jitterSigma    = src.jitterSigma;
        s.repeats        = src.repeats;
        s.stepMultiplier = src.stepMultiplier;
        s.stepsMax       = src.stepsMax;
        s.fixedWeight    = src.fixedWeight;
        return s;
    }

    private void drawRings(PGraphics g, PVector[] vertices, float diameter,
                           boolean draftsman, LineStyle ringStyle, float radiusJitterSigma) {
        for (PVector v : vertices) {
            drawSingleRing(g, v.x, v.y, diameter, draftsman, ringStyle, radiusJitterSigma);
        }
    }

    private void drawSingleRing(PGraphics g, float cx, float cy, float diameter,
                                boolean draftsman, LineStyle ringStyle, float radiusJitterSigma) {
        if (draftsman) {
            // Use jittered radius if requested (Gaussian per ring)
            float d = diameter + (float) app.randomGaussian() * radiusJitterSigma * 2f;
            d = Math.max(0.1f, d);
            lines.draftsmanCircle(g, cx, cy, d, ringStyle);
        } else {
            // Plain circle but still respect alpha/weight and ring color
            float h = app.hue(ringStyle.strokeColor);
            float s = app.saturation(ringStyle.strokeColor);
            float b = app.brightness(ringStyle.strokeColor);
            g.noFill();
            g.stroke(h, s, b, ringStyle.baseAlpha);
            g.strokeWeight(ringStyle.fixedWeight > 0 ? ringStyle.fixedWeight : 1.5f);
            float d = diameter + (float) app.randomGaussian() * radiusJitterSigma * 2f;
            d = Math.max(0.1f, d);
            g.circle(cx, cy, d);
        }
    }

    private void drawPolyConnections(PGraphics g, PVector[] vertices,
                                     boolean draftsman, LineStyle style,
                                     float endpointJitterSigma) {
        int n = vertices.length;
        for (int i = 0; i < n; i++) {
            PVector a = vertices[i];
            for (int j = 0; j < n; j++) {
                if (i == j) continue;
                PVector b = vertices[j];

                float ax = a.x + (float) app.randomGaussian() * endpointJitterSigma;
                float ay = a.y + (float) app.randomGaussian() * endpointJitterSigma;
                float bx = b.x + (float) app.randomGaussian() * endpointJitterSigma;
                float by = b.y + (float) app.randomGaussian() * endpointJitterSigma;

                if (draftsman) {
                    lines.draftsmanLine(g, ax, ay, bx, by, style);
                } else {
                    float h = app.hue(style.strokeColor);
                    float s = app.saturation(style.strokeColor);
                    float br= app.brightness(style.strokeColor);
                    g.stroke(h, s, br, style.baseAlpha);
                    g.strokeWeight(style.fixedWeight > 0 ? style.fixedWeight : 1f);
                    g.line(ax, ay, bx, by);
                }
            }
        }
    }

    private void connectPolys(PGraphics g, PVector[] v1, PVector[] v2,
                              boolean draftsman, LineStyle style,
                              float endpointJitterSigma) {
        int n1 = v1.length, n2 = v2.length;
        for (int i = 0; i < n1; i++) {
            PVector a = v1[i];
            for (int j = 0; j < n2; j++) {
                if (i == j) continue; // keep your asymmetry
                PVector b = v2[j];

                float ax = a.x + (float) app.randomGaussian() * endpointJitterSigma;
                float ay = a.y + (float) app.randomGaussian() * endpointJitterSigma;
                float bx = b.x + (float) app.randomGaussian() * endpointJitterSigma;
                float by = b.y + (float) app.randomGaussian() * endpointJitterSigma;

                if (draftsman) {
                    lines.draftsmanLine(g, ax, ay, bx, by, style);
                } else {
                    float h = app.hue(style.strokeColor);
                    float s = app.saturation(style.strokeColor);
                    float br= app.brightness(style.strokeColor);
                    g.stroke(h, s, br, style.baseAlpha);
                    g.strokeWeight(style.fixedWeight > 0 ? style.fixedWeight : 1f);
                    g.line(ax, ay, bx, by);
                }
            }
        }
    }
}
