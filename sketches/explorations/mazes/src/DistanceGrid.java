import processing.core.PApplet;

public class DistanceGrid extends Grid {
    private Distances distances;

    public DistanceGrid(int rows, int columns, Cell[][] cells) {
        super(rows, columns, cells);
    }

    public void setDistances(Distances distances) {
        this.distances = distances;
    }

    @Override
    public String contentsOf(Cell cell) {
        if (distances != null && distances.getDistance(cell) >= 0) {
            return Integer.toString(distances.getDistance(cell), 36);
        }
        return super.contentsOf(cell);
    }

}