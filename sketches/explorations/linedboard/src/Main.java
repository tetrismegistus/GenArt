import com.krab.lazy.LazyGuiSettings;
import com.krab.lazy.stores.FontStore;
import com.krab.lazy.LazyGui;

import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PGraphics;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

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
    Grid grid;
    ArrayList<List<Node>> paths = new ArrayList<>();
    ArrayList<Grid> grids = new ArrayList<>();


    public static void main(String[] args) {
        PApplet.main(java.lang.invoke.MethodHandles.lookup().lookupClass());
    }

    public void setup() {

        gui = new LazyGui(this);
        gui.gradient("gradient", new int[]{0x114B5F, 0x456990, 0xF45B69, 0x6B2737});
        pg = createGraphics(width, height, P2D);

        grid = new Grid(100, 100, 160, 160, 5, this);
        grid.fillBoard();




        for (int i = 0; i < 10000; i++) {
            ArrayList<Node> validNodes = new ArrayList<>();
            List<Node> path;
            for (int r = 0; r < grid.rows; r++) {
                for (int c = 0; c < grid.cols; c++) {
                    if (!grid.nodes[r][c].isObstacle && grid.nodes[r][c].isTerminal) {
                        validNodes.add(grid.nodes[r][c]);
                    }
                }
            }
            Collections.shuffle(validNodes);
            resetParentPointers(validNodes);
            path = AStarAlgorithm.findPath(grid.nodes, validNodes.get(0), validNodes.get(1));
            if (path != null) paths.add(path);

        }

        for (List<Node> path : paths) {
            int color = color(random(360), random(100), random(50,100));
            for (Node node : path) {
                node.clr = color;
            }

        }
    }

    public void settings() {
        size(1000, 1000, P2D);
    }

    public void draw() {
        //background(360, 0, 100);
        pg.beginDraw();

        boolean drawGrid = gui.toggle("drawGrid");



        pg.stroke(0);
        pg.colorMode(HSB, 360, 100, 100, 1);
        if (gui.button("setColors")) {
            setColors();
        }
        drawBackground();
        pg.fill(60,25, 100);
        pg.strokeWeight(1);
        int c1 = 0xFFFFBF;
        int c2 = 0xCB5E3D;

        //pg.rect(100, 100, 800, 800);

        grid.render(pg, drawGrid);

        pg.fill(10, 100, 100);
        for (List<Node> path : paths) {
            if (path != null) {
                //beginShape();
                for (int i = 0; i < path.size() - 1; i++) {
                    Node node = path.get(i);
                    Node node2 = path.get(i + 1);
                    pg.stroke(255, 255, 255, 255);
                    pg.strokeWeight(2);
                    pg.line(node.x * grid.tileSize + 100 + grid.tileSize/2,
                            node.y * grid.tileSize + 100 + grid.tileSize/2,
                            node2.x * grid.tileSize + 100 + grid.tileSize/2,
                            node2.y * grid.tileSize + 100 + grid.tileSize/2);
                    pg.fill(node.clr);
                    pg.strokeWeight(1);
                    if (i == 0 && !node.isTerminal)
                        pg.square(node.x * grid.tileSize + 100, node.y * grid.tileSize + 100, grid.tileSize);
                    if (i == path.size() -1 && !node2.isTerminal)
                        pg.square(node2.x * grid.tileSize + 100, node2.y * grid.tileSize + 100, grid.tileSize);

                    //node.clr = color;
                }
                //endShape();
            }
        }

        pg.endDraw();
        image(pg, 0, 0);
        gui.draw();
    }

    public static void resetParentPointers(List<Node> terminalNodes) {
        for (Node node : terminalNodes) {
            node.parent = null;
        }
    }

    private void setColors() {
        for (TileRect r : grid.rects) {
            r.c = gui.gradientColorAt("gradient", this.random(1)).hex;
        }
        int i = floor(random(grid.rects.size()));
        colorMode(HSB, 360, 100, 100, 1);
        grid.rects.get(i).c = color(276, 28, 100);
    }

    private void drawBackground() {
        PGraphics bggradient = gui.gradient("bggradient", new int[]{color(60, 25, 100), color(14,70,80)});
        pg.image(bggradient, 0, 0);

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

                    stroke(h, 100, 100, a*alpha);
                    strokeWeight(sw);
                    line(p1.x, p1.y, p2.x, p2.y);
                }
            }
        }
    }
}