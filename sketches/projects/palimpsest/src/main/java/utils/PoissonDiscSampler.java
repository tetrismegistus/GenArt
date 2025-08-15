package utils;

import java.util.ArrayList;
import processing.core.PApplet;
import processing.core.PVector;

import static processing.core.PApplet.*;

public class PoissonDiscSampler {
    // https://sighack.com/post/poisson-disk-sampling-bridsons-algorithm
    float width;
    float height;
    ArrayList<PVector> samples;
    PApplet pa;

    public PoissonDiscSampler(float w, float h, PApplet p) {
        width = w;
        height = h;
        pa = p;
    }

    boolean isValidPoint(PVector[][] grid, float cellsize,
                         int gwidth, int gheight,
                         PVector p, float radius) {
        if (p.x < 0 || p.x >= this.width || p.y < 0 || p.y >= this.height)
            return false;

        int xindex = floor(p.x / cellsize);
        int yindex = floor(p.y / cellsize);
        int i0 = max(xindex - 1, 0);
        int i1 = min(xindex + 1, gwidth - 1);
        int j0 = max(yindex - 1, 0);
        int j1 = min(yindex + 1, gheight - 1);

        for (int i = i0; i <= i1; i++)
            for (int j = j0; j <= j1; j++)
                if (grid[i][j] != null)
                    if (dist(grid[i][j].x, grid[i][j].y, p.x, p.y) < radius)
                        return false;

        return true;
    }

    void insertPoint(PVector[][] grid, float cellsize, PVector point) {
        int xindex = floor(point.x / cellsize);
        int yindex = floor(point.y / cellsize);
        grid[xindex][yindex] = point;
    }

    public ArrayList<PVector> poissonDiskSampling(float radius, int k) {
        int N = 5;
        ArrayList<PVector> points = new ArrayList<>();
        ArrayList<PVector> active = new ArrayList<>();
        PVector p0 = new PVector(pa.random(this.width), pa.random(this.height));
        PVector[][] grid;
        float cellsize = floor(radius / sqrt(N));

        int ncells_width = ceil(this.width / cellsize) + 1;
        int ncells_height = ceil(this.width / cellsize) + 1;

        grid = new PVector[ncells_width][ncells_height];
        for (int i = 0; i < ncells_width; i++)
            for (int j = 0; j < ncells_height; j++)
                grid[i][j] = null;

        insertPoint(grid, cellsize, p0);
        points.add(p0);
        active.add(p0);

        while (active.size() > 0) {
            int random_index = (int) pa.random(active.size());
            PVector p = active.get(random_index);

            boolean found = false;
            for (int tries = 0; tries < k; tries++) {
                float theta = pa.random(360);
                float new_radius = pa.random(radius, 2 * radius);
                float pnewx = p.x + new_radius * cos(radians(theta));
                float pnewy = p.y + new_radius * sin(radians(theta));
                PVector pnew = new PVector(pnewx, pnewy);

                if (!isValidPoint(grid, cellsize, ncells_width, ncells_height, pnew, radius))
                    continue;

                points.add(pnew);
                insertPoint(grid, cellsize, pnew);
                active.add(pnew);
                found = true;
                break;
            }

            if (!found)
                active.remove(random_index);
        }

        return points;
    }
}
