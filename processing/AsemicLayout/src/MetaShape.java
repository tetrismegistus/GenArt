import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PVector;

import static processing.core.PApplet.*;

public class MetaShape {
    PGraphics pg;
    int w;
    int h;

    MetaShape(int w, int h, PApplet pa) {
        pg = pa.createGraphics(w, h);
        this.w = w;
        this.h = h;
    }

    void metaShape(float h, int sides) {
        float xOffset = w * 0.015f;  // 5% offset to the left
        float yOffset = h * 0.015f;  // 5% offset to the left
        float x1 = (w / 2.0f) - xOffset;  // Center the x-coordinate and apply the offset
        float y1 = (h / 2.0f) + yOffset;  // Center the y-coordinate, assuming h = height of the canvas

        float y2 = y1 + h / 2; // y2 for other calculations

        // Let's reduce the diameter to say, 90% of what it was
        float D1 = 0.770f * dist(x1, y1 - h / 2, x1, y2); // Adjust y1 accordingly

        float diameter = D1 / 4;

        PVector[] vertices = polygonVertices(x1, y1, sides, diameter);
        PVector[] vertices2 = polygonVertices(x1, y1, sides, diameter * 2);

        pg.beginDraw();
        pg.noFill();
        pg.colorMode(HSB, 360, 100, 100);
        pg.background(38, 10, 94);
        drawCircles(vertices, diameter);
        drawCircles(vertices2, diameter);
        pg.circle(x1, y1, diameter);
        drawPolyConnections(vertices);
        drawPolyConnections(vertices2);
        connectPolys(vertices, vertices2);
        pg.endDraw();
    }


    PVector[] polygonVertices(float x, float y, int sides, float sz){

        PVector[] corners = new PVector[sides];

        for (int i = 0; i < sides; i++) {
            float step = radians(360f/sides);
            corners[i] = new PVector(sz * cos(i*step) + x, sz * sin(i*step) + y);
        }

        return corners;
    }

    void drawPolyConnections(PVector[] vertices) {
        for (PVector pVector : vertices) {
            for (PVector vertex : vertices) {
                pg.line(pVector.x, pVector.y, vertex.x, vertex.y);
            }
        }
    }

    void connectPolys(PVector[] v1, PVector[]v2) {
        for (PVector vector : v1) {
            for (PVector pVector : v2) {
                pg.line(vector.x, vector.y, pVector.x, pVector.y);
            }
        }

    }

    void drawCircles(PVector[] vertices, float diameter) {
        for (PVector vertex : vertices) {
            pg.circle(vertex.x, vertex.y, diameter);
        }
    }

}
