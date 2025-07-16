public class MetaShape {
    int w;
    int h;
    PApplet pa; // store reference to PApplet object to be able to draw on it
    int sides;

    MetaShape(int w, int h, int sides, PApplet pa) {
        this.w = w;
        this.h = h;
        this.pa = pa; // store the PApplet reference
        this.sides = sides;
    }

    void metaShape(float x, float y, float h) {
        float xOffset = w * 0.015f;  // 5% offset to the left
        float yOffset = h * 0.015f;  // 5% offset to the left
        float x1 = x + xOffset;
        float y1 = y + yOffset;

        float y2 = y1 + h / 2; // y2 for other calculations

        float D1 = 0.770f * dist(x1, y1 - h / 2, x1, y2);
        float diameter = D1 / 4;

        PVector[] vertices = polygonVertices(x1, y1, sides, diameter);
        PVector[] vertices2 = polygonVertices(x1, y1, sides, diameter * 2);

        pa.noFill();
        pa.colorMode(HSB, 360, 100, 100);
        drawCircles(vertices, diameter);
        drawCircles(vertices2, diameter);
        pa.circle(x1, y1, diameter);
        drawPolyConnections(vertices);
        drawPolyConnections(vertices2);
        connectPolys(vertices, vertices2);
    }

    PVector[] polygonVertices(float x, float y, int sides, float sz) {
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
                pa.line(pVector.x, pVector.y, vertex.x, vertex.y);
            }
        }
    }

    void connectPolys(PVector[] v1, PVector[] v2) {
        for (PVector vector : v1) {
            for (PVector pVector : v2) {
                pa.line(vector.x, vector.y, pVector.x, pVector.y);
            }
        }
    }

    void drawCircles(PVector[] vertices, float diameter) {
        for (PVector vertex : vertices) {
            pa.circle(vertex.x, vertex.y, diameter);
        }
    }
}
