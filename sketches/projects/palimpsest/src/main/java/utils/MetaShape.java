package utils;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PVector;

import static processing.core.PApplet.*;

public class MetaShape {
    public PGraphics pg;  // keep public so callers can use ms.pg like before
    int w;
    int h;

    public MetaShape(int w, int h, PApplet pa) {
        pg = pa.createGraphics(w, h);
        this.w = w;
        this.h = h;
    }

    void metaShape(float h, int sides) {
        float xOffset = w * 0.015f;
        float yOffset = h * 0.015f;
        float x1 = (w / 2.0f) - xOffset;
        float y1 = (h / 2.0f) + yOffset;

        float y2 = y1 + h / 2;

        float D1 = 0.770f * dist(x1, y1 - h / 2, x1, y2);

        float diameter = D1 / 4;

        PVector[] vertices  = polygonVertices(x1, y1, sides, diameter);
        PVector[] vertices2 = polygonVertices(x1, y1, sides, diameter * 2);

        pg.beginDraw();
        pg.noFill();
        pg.colorMode(HSB, 360, 100, 100);
        pg.clear();
        drawCircles(vertices, diameter);
        drawCircles(vertices2, diameter);
        pg.circle(x1, y1, diameter);
        drawPolyConnections(vertices);
        drawPolyConnections(vertices2);
        connectPolys(vertices, vertices2);
        pg.endDraw();
    }

    PVector[] polygonVertices(float x, float y, int sides, float sz) {
        PVector[] corners = new PVector[sides];
        for (int i = 0; i < sides; i++) {
            float step = radians(360f / sides);
            corners[i] = new PVector(sz * cos(i * step) + x, sz * sin(i * step) + y);
        }
        return corners;
    }

    void drawPolyConnections(PVector[] vertices) {
        for (PVector a : vertices) {
            for (PVector b : vertices) {
                pg.line(a.x, a.y, b.x, b.y);
            }
        }
    }

    void connectPolys(PVector[] v1, PVector[] v2) {
        for (PVector a : v1) {
            for (PVector b : v2) {
                pg.line(a.x, a.y, b.x, b.y);
            }
        }
    }

    void drawCircles(PVector[] vertices, float diameter) {
        for (PVector v : vertices) {
            pg.circle(v.x, v.y, diameter);
        }
    }
}
