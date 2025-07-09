import processing.core.PApplet;

import java.util.function.Consumer;
import java.util.ArrayList;
import java.util.List;

public class Grid {
    private final int rows;
    private final int columns;
    Cell[][] grid;

    public Grid(int rows, int columns, Cell[][] cells) {
        this.rows = rows;
        this.columns = columns;
        this.grid = cells;
        configureCells();
    }

    public int getRows() {
        return this.rows;
    }

    public int getColumns() {
        return this.columns;
    }

    public Cell getCell(int row, int column) {
        if (row < 0 || row >= this.rows || column < 0 || column >= this.grid[row].length) {
            return null;
        }
        return this.grid[row][column];
    }

    protected Cell[][] prepareGrid() {
        Cell[][] cells = new Cell[this.rows][this.columns];
        for (int row = 0; row < this.rows; row++) {
            for (int col = 0; col < this.columns; col++) {
                cells[row][col] = new Cell(row, col);
            }
        }
        return cells;
    }

    void configureCells() {
        for (int row = 0; row < this.rows; row++) {
            for (int col = 0; col < this.columns; col++) {
                Cell cell = this.grid[row][col];

                if (cell != null) {
                    Cell north = getCell(row - 1, col);
                    Cell south = getCell(row + 1, col);
                    Cell west = getCell(row, col - 1);
                    Cell east = getCell(row, col + 1);

                    if (north != null) {
                        cell.setNorth(north);
                    }
                    if (south != null) {
                        cell.setSouth(south);
                    }
                    if (west != null) {
                        cell.setWest(west);
                    }
                    if (east != null) {
                        cell.setEast(east);
                    }
                }
            }
        }
    }

    public Cell randomCell() {
        int row = (int) (Math.random() * this.rows);
        int col = (int) (Math.random() * this.grid[row].length);
        return getCell(row, col);
    }

    public int size() {
        return this.rows * this.columns;
    }

    public void eachRow(Consumer<Cell[]> consumer) {
        for (Cell[] row : this.grid) {
            consumer.accept(row);
        }
    }

    public void eachCell(Consumer<Cell> consumer) {
        eachRow((row) -> {
            for (Cell cell : row) {
                if (cell != null) {
                    consumer.accept(cell);
                }
            }
        });
    }

    public List<Cell> deadends(Grid grid) {
        List<Cell> list = new ArrayList<>();

        grid.eachCell(cell -> {
            if (cell.links().size() == 1) {
                list.add(cell);
            }
        });

        return list;
    }

    public String contentsOf(Cell cell) {
        return "";
    }

    public int backgroundColor(Cell cell, PApplet pa, int c1, int c2) {
        return pa.color(0, 0, 100, 0);
    }


    public void display(float startX, float startY, float cellSize, PApplet pa, int c1, int c2, boolean drawWalls) {
        pa.pushMatrix();
        pa.translate(startX, startY);
        pa.noFill();


        float fontSize = calculateFontSize(cellSize, pa);
        pa.textAlign(PApplet.CENTER, PApplet.CENTER);
        pa.textSize(fontSize);
        pa.fill(pa.color(pa.hue(c2), pa.saturation(c2), pa.brightness(c2)));
        //pa.rect(0, 0, this.getColumns() * cellSize, this.getRows() * cellSize);

        this.eachCell((cell) -> {
            float x = cell.getColumn() * cellSize;
            float y = cell.getRow() * cellSize;
            pa.noStroke();
            int c = this.backgroundColor(cell, pa, c1, c2);
            pa.fill(pa.color(pa.hue(c), pa.saturation(c), pa.brightness(c)));
            pa.square(x, y, cellSize);
            pa.stroke(0);

            if (drawWalls) {
                if (!cell.linked(cell.getNorth())) {
                    pa.line(x, y, x + cellSize, y);
                }
                if (!cell.linked(cell.getEast())) {
                    pa.line(x + cellSize, y, x + cellSize, y + cellSize);
                }
                if (!cell.linked(cell.getWest())) {
                    pa.line(x, y, x, y + cellSize);
                }
                if (!cell.linked(cell.getSouth())) {
                    pa.line(x, y + cellSize, x + cellSize, y + cellSize);
                }
            }

            String cellContents = this.contentsOf(cell);
            pa.fill(0); // Set the text color to black
            pa.text(cellContents, x + cellSize / 2, y + cellSize / 2.5f);

        });
        pa.stroke(0);
        //pa.strokeWeight(4);

        pa.popMatrix();
    }

    float calculateFontSize(float cellSize, PApplet pa) {
        float currentFontSize = 1;
        float currentWidth = 0;

        while (true) {
            pa.textSize(currentFontSize);
            currentWidth = pa.textWidth("000");

            if (currentWidth >= cellSize) {
                break;
            }
            currentFontSize++;
        }

        return currentFontSize;
    }

}