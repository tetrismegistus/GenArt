import com.krab.lazy.LazyGuiSettings;
import com.krab.lazy.stores.FontStore;
import com.krab.lazy.LazyGui;

import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PGraphics;

import java.util.ArrayList;

public class Main extends PApplet  {

    /*
    SketchName: default.pde
    Credits: Literally every tutorial I've read and SparkyJohn
    Description: My default starting point for sketches
    */
    LazyGui gui;
    PGraphics pg;

    String sketchName = "mySketch";
    String saveFormat = ".png";

    int calls = 0;
    long lastTime;

    float theta = 0;
    ArrayList<PVector> trail = new ArrayList<>();

    public static void main(String[] args) {
        PApplet.main(java.lang.invoke.MethodHandles.lookup().lookupClass());
    }

    public void setup() {

        gui = new LazyGui(this);
        pg = createGraphics(width, height, P2D);

    }

    public void settings() {
        size(1000, 1000, P2D);
    }

    public void draw() {
        background(0);
        if (gui.button("reInit")) {
            pg = createGraphics(width, height, P2D);
            theta = 0;
            trail = new ArrayList<>();
        }

        pg.beginDraw();
        pg.colorMode(HSB, 360, 100, 100, 1);
        drawBackground();
        float r = 100.0f;
        //pg.stroke(map(theta, 0, TWO_PI, 0, 360), 100, 100);
        pg.noFill();

        float speed = gui.slider("speed", 0.01f, 0f, 1f);
        pg.stroke(0);

        Complex a = new Complex(1, 0);
        Complex b = new Complex(-1f/2f, 0);
        Complex c = new Complex(0, -1f/3f);

        Complex term1_exp = new Complex(PApplet.sin(theta), PApplet.sin(theta));
        Complex term2_exp = new Complex(PApplet.sin(6 * theta), PApplet.cos(6 * theta));
        Complex term3_exp = new Complex(PApplet.cos(-14 * theta), PApplet.sin(-14 * theta));

        Complex term1 = a.multiply(term1_exp);
        Complex term2 = b.multiply(term2_exp);
        Complex term3 = c.multiply(term3_exp);
        Complex sum = term1.add(term2).add(term3);
        sum = sum.scale(r);

        PVector mu = new PVector(sum.real + width/2.0f, sum.imag + height/2.0f);

        pg.circle(mu.x, mu.y, 10);
        trail.add(mu.copy());
        for (PVector t : trail) {
            pg.point(t.x, t.y);
        }

        theta += speed;
        pg.endDraw();
        image(pg, 0, 0);
        gui.draw();
    }

    private void drawBackground() {
        pg.fill(gui.colorPicker("background").hex);
        pg.noStroke();
        pg.rectMode(CORNER);
        pg.rect(0, 0, width, height);
    }

    public void keyReleased() {
        if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));
    }


    String getTemporalName(String prefix, String suffix){
        // Thanks! SparkyJohn @Creative Coders on Discord
        long time = System.currentTimeMillis();
        if(lastTime == time) {
            calls ++;
        } else {
            lastTime = time;
            calls = 0;
        }
        return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
    }

    public void connectPoints(ArrayList<PVector> points, float sw, float alpha, float radius) {
        for (int l1 = 0; l1 < points.size(); l1++) {
            for (int l2 = 0; l2 < l1; l2++) {
                PVector p1 = points.get(l1);
                PVector p2 = points.get(l2);
                float d = PVector.dist(p1, p2);
                float a = pow(1/(d/radius+1), 6);
                float h;
                if (d <= radius) {

                    h = map(1-a, 0, 1, 0, 360) % 360;

                    pg.stroke(h, 100, 100, a*alpha);
                    pg.strokeWeight(sw);
                    pg.line(p1.x, p1.y, p2.x, p2.y);
                }
            }
        }
    }
}