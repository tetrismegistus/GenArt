import processing.core.PApplet;

public class ColoredGrid extends Grid {
    private Distances distances;
    private int maximum;

    public ColoredGrid(int rows, int columns, Cell[][] cells) {
        super(rows, columns, cells);
    }

    public void setDistances(Distances distances) {
        this.distances = distances;
        CellDistancePair maxPair = distances.max();
        this.maximum = maxPair.distance();
    }

    @Override
    public int backgroundColor(Cell cell, PApplet pa, int c1, int c2) {
        int distance = this.distances.getDistance(cell);
        double t = (double) (this.maximum - distance) / this.maximum;
        return pa.lerpColor(pa.color(pa.hue(c1), pa.saturation(c1), pa.brightness(c1)),
                pa.color(pa.hue(c2), pa.saturation(c2), pa.brightness(c2)), (float) t);
    }
}