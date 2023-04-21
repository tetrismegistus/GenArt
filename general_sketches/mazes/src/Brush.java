import processing.core.PApplet;
import processing.core.PVector;

class Brush{
    float rad, cx, cy, z;
    int col;
    BrushTip[] brushEnds;
    PApplet pApplet;

    Brush(float r, float x, float y, int c, PApplet pApplet) {
        rad = r;
        cx = x;
        cy = y;
        col = c;
        this.pApplet = pApplet;

        int cap = ((int) rad * (int) rad) * 4;
        brushEnds = new BrushTip[cap];
        for (int i = 0; i < cap; i++) {
            brushEnds[i] = getBrushTip();
        }
    }

    void render() {
        pApplet.pushMatrix();
        pApplet.translate(cx, cy);
        pApplet.colorMode(pApplet.HSB, 360, 100, 100, 1);
        for (BrushTip bt : brushEnds) {
            if (pApplet.random(1) > .1) {
                pApplet.strokeWeight(bt.sz);
                pApplet.stroke(col, .1f);
                pApplet.point(bt.pos.x, bt.pos.y);
            }
        }
        pApplet.popMatrix();
    }

    BrushTip getBrushTip() {
        float r = rad * pApplet.sqrt(pApplet.random(0, 1));
        float theta = pApplet.random(0, 1) * 2 * pApplet.PI;
        float x = r * pApplet.cos(theta) + pApplet.randomGaussian();
        float y = r * pApplet.sin(theta) + pApplet.randomGaussian();
        return new BrushTip(new PVector(x, y), .2f + pApplet.abs(pApplet.randomGaussian()));
    }

    public static void lerpLine(float x1, float y1, float x2, float y2, Brush b, PApplet pApplet) {
        float d = pApplet.dist(x1, y1, x2, y2);
        for (float i = 0; i < d; i++) {
            b.cx = pApplet.lerp(x1, x2, i/d);
            b.cy = pApplet.lerp(y1, y2, i/d);
            b.render();
        }
    }
}


class BrushTip {
    float sz;
    PVector pos;

    BrushTip(PVector xy, float isz) {
        pos = xy;
        sz = isz;
    }
}