import processing.core.PApplet;

public class PolarGrid extends Grid {

    public PolarGrid(int rows, Cell[][] cells) {
        super(rows, 1, cells);
    }

    @Override
    public void display(float startX, float startY, float cellSize, PApplet pa, int c1, int c2, boolean drawWalls) {
        float center = pa.width/2.0f;

        this.eachCell(cell -> {
            float theta = 2 * PApplet.PI / this.grid[cell.getRow()].length;
        });
    }



}