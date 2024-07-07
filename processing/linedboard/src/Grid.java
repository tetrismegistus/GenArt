import com.krab.lazy.LazyGui;
import processing.core.PGraphics;

import java.util.*;

import processing.core.PApplet;

import static processing.core.PApplet.println;

public class Grid {
    float x, y;
    int rows;
    int cols;
    float tileSize;
    Tile[][] grid;
    Node[][] nodes;
    ArrayList<TileRect> rects = new ArrayList<>();
    PApplet pa;

    Grid(float x, float y, int r, int c, float tSz, PApplet pa) {
        this.x = x;
        this.y = y;
        this.rows = r;
        this.cols = c;
        this.tileSize = tSz;
        this.grid = new Tile[rows][cols];
        this.nodes = new Node[rows][cols];
        for (int ry = 0; ry < r; ry++) {
            for (int rx = 0; rx < c; rx++) {
                nodes[ry][rx] = new Node(rx, ry, false);
            }
        }
        this.pa = pa;
    }

    void placeRect(int tx, int ty, int w, int h) {
        TileRect tr = new TileRect(tx, ty, w, h, tileSize);
        boolean placed = tr.place(grid, pa, nodes);
        if (placed) rects.add(tr);
    }

    void fillBoard() {
        for (int i = 0; i < 7000; i++) {
            int proposedX = PApplet.floor(pa.random(4, cols - 4));
            int proposedY = PApplet.floor(pa.random(4, rows - 4));


            int proposedW = PApplet.floor(pa.random(4, cols - 4 - proposedX));
            int proposedH = PApplet.floor(pa.random(4, rows - 4 - proposedY));
            placeRect(proposedX, proposedY, proposedW, proposedH);
        }
    }

    void render(PGraphics pg, boolean drawGrid) {


        pg.pushMatrix();
        pg.translate(x, y);

        if (drawGrid) {
            pg.noFill();
            pg.stroke(0);
            pg.strokeWeight(.5f);
            for (int r = 0; r < rows; r++) {
                for (int c = 0; c < cols; c++) {
                    pg.square(c * tileSize, r * tileSize, tileSize);
                }
            }
        }

        //List<Node> path = AStarAlgorithm.findPath(nodes, start, end);
        for (TileRect tr : rects) {

            tr.render(pg);
        }

        for (Node[] row : nodes) {
            for (Node node : row) {
                if (node != null && node.isTerminal)
                    pg.circle(node.x * tileSize + tileSize/2, node.y * tileSize + tileSize/2, 3);
            }
        }

        pg.popMatrix();
    }


}
