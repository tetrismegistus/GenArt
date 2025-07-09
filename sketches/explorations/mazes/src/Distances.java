import java.util.HashMap;
import java.util.Map;

public class Distances {

    private Cell root;
    private Map<Cell, Integer> cells;

    public Distances(Cell root) {
        this.root = root;
        this.cells = new HashMap<>();
        this.cells.put(root, 0);
    }

    public int getDistance(Cell cell) {
        return this.cells.getOrDefault(cell, -1);
    }

    public void setDistance(Cell cell, int distance) {
        this.cells.put(cell, distance);
    }

    public Iterable<Cell> getCells() {
        return this.cells.keySet();
    }

    public Distances pathTo(Cell goal) {
        Cell current = goal;

        Distances breadcrumbs = new Distances(this.root);
        breadcrumbs.setDistance(current, this.getDistance(current));

        while (!current.equals(this.root)) {
            for (Cell neighbor : current.links()) {
                if (this.getDistance(neighbor) < this.getDistance(current)) {
                    breadcrumbs.setDistance(neighbor, this.getDistance(neighbor));
                    current = neighbor;
                    break;
                }
            }
        }

        return breadcrumbs;
    }

    public CellDistancePair max() {
        int maxDistance = 0;
        Cell maxCell = root;

        for (Map.Entry<Cell, Integer> entry : cells.entrySet()) {
            Cell cell = entry.getKey();
            int distance = entry.getValue();

            if (distance > maxDistance) {
                maxDistance = distance;
                maxCell = cell;
            }
        }

        return new CellDistancePair(maxCell, maxDistance);
    }



    public String toString() {
        String output = "";

        for (int distance : this.cells.values()) {
            output += distance + " ";
        }

        return output;
    }
}