import processing.core.PApplet;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class AldousBroder {

    public static Grid on(Grid grid) {
        Cell cell = grid.randomCell();
        int unvisited = grid.size() - 1;
        while (unvisited > 0) {
            List<Cell> neighbors = cell.neighbors();
            Collections.shuffle(neighbors);
            Cell neighbor = neighbors.get(0);

            if (neighbor.links().size() == 0) {
                cell.link(neighbor);
                unvisited -= 1;
            }

            cell = neighbor;
        }
        return grid;
    }

}
