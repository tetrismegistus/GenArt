import processing.core.PApplet;

import java.util.function.Consumer;

public class Grid {
    private final int rows;
    private final int columns;
    private final Cell[][] grid;

    public Grid(int rows, int columns) {
        this.rows = rows;
        this.columns = columns;
        this.grid = prepareGrid();
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

    private Cell[][] prepareGrid() {
        Cell[][] cells = new Cell[this.rows][this.columns];
        for (int row = 0; row < this.rows; row++) {
            for (int col = 0; col < this.columns; col++) {
                cells[row][col] = new Cell(row, col);
            }
        }
        return cells;
    }

    private void configureCells() {
        for (int row = 0; row < this.rows; row++) {
            for (int col = 0; col < this.columns; col++) {
                Cell cell = this.grid[row][col];
                cell.setNorth(getCell(row - 1, col));
                cell.setSouth(getCell(row + 1, col));
                cell.setWest(getCell(row, col - 1));
                cell.setEast(getCell(row, col + 1));
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
        pa.noFill();
        pa.rect(0, 0, this.getColumns() * cellSize, this.getRows() * cellSize);
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