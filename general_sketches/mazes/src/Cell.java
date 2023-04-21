import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Cell {
    private final int row;
    private final int column;
    private Cell north;
    private Cell south;
    private Cell east;
    private Cell west;
    private final Map<Cell, Boolean> links;
    private Distances distances;
    private List<Cell> frontier;


    public Cell(int row, int column) {
        this.row = row;
        this.column = column;
        this.links = new HashMap<>();
    }

    public void initDistances() {
        distances = new Distances(this);
        frontier = new ArrayList<>();
        frontier.add(this);
    }

    public Distances updateFrontier() {
        if (frontier == null || frontier.isEmpty()) {
            return null;
        }

        List<Cell> newFrontier = new ArrayList<>();

        for (Cell cell : frontier) {
            for (Cell linked : cell.links()) {
                if (distances.getDistance(linked) < 0) {
                    distances.setDistance(linked, distances.getDistance(cell) + 1);
                    newFrontier.add(linked);
                }
            }
        }

        frontier = newFrontier;
        return distances;
    }


    public Distances getDistances() {
        return distances;
    }


    public int getRow() {
        return this.row;
    }

    public int getColumn() {
        return this.column;
    }

    public Cell getNorth() {
        return this.north;
    }

    public void setNorth(Cell north) {
        this.north = north;
    }

    public Cell getSouth() {
        return this.south;
    }

    public void setSouth(Cell south) {
        this.south = south;
    }

    public Cell getEast() {
        return this.east;
    }

    public void setEast(Cell east) {
        this.east = east;
    }

    public Cell getWest() {
        return this.west;
    }

    public void setWest(Cell west) {
        this.west = west;
    }

    public Cell link(Cell cell) {
        return link(cell, true);
    }

    public Cell link(Cell cell, boolean bidi) {
        this.links.put(cell, true);
        if (bidi) {
            cell.link(this, false);
        }
        return this;
    }

    public Cell unlink(Cell cell) {
        return unlink(cell, true);
    }

    public Cell unlink(Cell cell, boolean bidi) {
        this.links.remove(cell);
        if (bidi) {
            cell.unlink(this, false);
        }
        return this;
    }

    public List<Cell> links() {
        return new ArrayList<>(this.links.keySet());
    }

    public boolean linked(Cell cell) {
        return this.links.containsKey(cell);
    }

    public List<Cell> neighbors() {
        List<Cell> list = new ArrayList<>();
        if (this.north != null) {
            list.add(this.north);
        }
        if (this.south != null) {
            list.add(this.south);
        }
        if (this.east != null) {
            list.add(this.east);
        }
        if (this.west != null) {
            list.add(this.west);
        }
        return list;
    }

    public Distances distances() {
        Distances distances = new Distances(this);
        List<Cell> frontier = new ArrayList<>();
        frontier.add(this);

        while (!frontier.isEmpty()) {
            List<Cell> newFrontier = new ArrayList<>();

            for (Cell cell : frontier) {
                for (Cell linked : cell.links()) {
                    if (distances.getDistance(linked) < 0) {
                        distances.setDistance(linked, distances.getDistance(cell) + 1);
                        newFrontier.add(linked);
                    }
                }
            }

            frontier = newFrontier;
        }

        return distances;
    }
}