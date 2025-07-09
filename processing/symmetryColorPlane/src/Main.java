import com.krab.lazy.LazyGuiSettings;
import com.krab.lazy.stores.FontStore;
import com.krab.lazy.LazyGui;

import processing.core.PApplet;
import processing.core.PImage;
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
    PImage img;
    String sketchName = "mySketch";
    String saveFormat = ".png";

    int calls = 0;
    long lastTime;

    float theta = 0;
    ArrayList<PVector> trail = new ArrayList<>();

    int[][] colors;
    PGraphics mapping;

    public static void main(String[] args) {
        PApplet.main(java.lang.invoke.MethodHandles.lookup().lookupClass());
    }

    public void setup() {

        gui = new LazyGui(this);
        pg = createGraphics(width, height, P2D);
        colorMode(HSB, 360, 100, 100, 1);
        colors = new int[1000][1000];
        img = loadImage("data/jung.png");

        for (int x = 0; x < width - 1; x++) {
            for (int y = 0; y < height - 1; y++) {
                Complex z = getZ(x, y);

                PVector complexLocation = complexLocation(z);
                int c = colorRef(complexLocation.x, complexLocation.y);
                colors[x][y] = c;
            }
        }

        mapping = createImage();

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
        float r = 200.0f;
        //pg.stroke(map(theta, 0, TWO_PI, 0, 360), 100, 100);
        pg.noFill();

        float speed = gui.slider("speed", 0.01f, 0f, 1f);
        pg.stroke(0);

        pg.image(mapping, 0, 0);


        pg.endDraw();
        image(pg, 0, 0);
        gui.draw();
    }

    PGraphics createImage() {
        PGraphics img = createGraphics(width, height);
        img.beginDraw();
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                int c = colors[x][y];
                img.stroke(c);
                img.point(x, y);
            }
        }
        img.endDraw();
        return img;

    }

    private int colorRef(float x, float y) {

        return img.get((int)x, (int)y);
    }

    private int colorRefWheel(float x, float y) {
        PVector curV = new PVector(x, y);
        PVector center = new PVector(width/2.0f, height/2.0f);
        float dist = curV.dist(center);
        if (Float.isInfinite(dist)) {
            return color(0, 0, 100); // Return a default color for points with infinite distance.
        }
        PVector diff = PVector.sub(center, curV);
        float h = map(diff.heading(), -PI, PI, 0, 360);
        float s = map(dist, 0, width/2.0f, 0, 100);
        float b = map(dist, 0, width, 100, 0);
        return color(h, s, b);
    }

    Complex getZ(float x, float y) {
        // Map pixel coordinates to the desired range in the complex plane.
        float mappedReal = map(x, 0, width, -2, 2);
        float mappedImaginary = map(y, 0, height, -2, 2);

        Complex z = new Complex(mappedReal, mappedImaginary);
        Complex zbar = new Complex(mappedReal, -mappedImaginary); // Compute the complex conjugate of z.
        Complex result = new Complex(0, 0);

        int maxPositivePower = 6;
        int maxNegativePower = -14;

        for (int n = maxNegativePower; n <= maxPositivePower; n++) {
            if (n < 0) {

                Complex coef = new Complex((n == -14) ? 1 / 3f : 0, 0);
                result = result.add(coef.multiply(zbar.pow(n)));
            }
            if (n >= 0) {
                float coefMod = 0;
                if (n == 1) {
                    coefMod = 1;
                } else if (n == 6) {
                    coefMod = 0.5f;
                }
                Complex coef = new Complex(coefMod, 0);
                result = result.add(coef.multiply(z.pow(n)));
            }

        }

        return result;
    }

    float a_n_for_positive_power(int n) {
        if (n == 1) {
            return 1;
        } else if (n == 6) {
            return 0.5f;
        }
        return 0;
    }


    PVector complexLocation(Complex z) {
        // Map the real and imaginary parts of z back to the pixel coordinates.
        float x = map(z.real, -2, 2, 0, width);
        float y = map(z.imag, -2, 2, 0, height);

        // Create a PVector with the mapped coordinates.
        return new PVector(x, y);
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