import com.krab.lazy.LazyGuiSettings;
import com.krab.lazy.stores.FontStore;
import com.krab.lazy.LazyGui;

import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PGraphics;

import java.util.ArrayList;
import java.util.List;

public class Main extends PApplet  {

    /*
    SketchName: default.pde
    Credits: Literally every tutorial I've read and SparkyJohn
    Description: My default starting point for sketches
    */
    //LazyGui gui;
    PGraphics pg;

    String sketchName = "mySketch";
    String saveFormat = ".png";

    int calls = 0;
    long lastTime;
    MaskedGrid grid;
    float cellSize = 1;
    float startX = 50;
    float startY = 50;
    boolean animationFinished = false;
    boolean animate = false;
    Cell startingCell;

    public static void main(String[] args) {
        PApplet.main(java.lang.invoke.MethodHandles.lookup().lookupClass());
    }

    public void setup() {

        //gui = new LazyGui(this);
        colorMode(HSB, 360, 100, 100, 1);
        //grid = new ColoredGrid(1000, 1000);
        grid = this.makeMaskedMaze("1.png");
        //RecursiveBacktracker.on(grid);



            startingCell = grid.randomCell();
            startingCell.initDistances();
            Distances distances = startingCell.distances();
            grid.setDistances(distances);
            println(grid.getRows());

        noLoop();


    }

    public void settings() {
        size(1245, 962);
    }

    public void draw() {
        background(360, 0, 100);
        /*
        if (animate) {
            Distances updatedDistances = startingCell.updateFrontier();
            if (updatedDistances != null) {
                grid.setDistances(updatedDistances); // Set the distances of the ColoredGrid
            }
        }

         */

        grid.display(startX, startY, cellSize, this, 0x1A8FE3, 0xD11149, false);



        save(getTemporalName(sketchName, saveFormat));
        /*
        if (updatedDistances != null) {
                    saveFrame("frames/####.png");
        }
        */
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

    public MaskedGrid makeMaskedMaze(String filename) {
        Mask mask = Mask.fromPNG(filename, this);
        MaskedGrid grid = new MaskedGrid(mask);
        RecursiveBacktracker.on(grid);
        return grid;
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

                    stroke(h, 100, 100, a*alpha);
                    strokeWeight(sw);
                    line(p1.x, p1.y, p2.x, p2.y);
                }
            }
        }
    }
}