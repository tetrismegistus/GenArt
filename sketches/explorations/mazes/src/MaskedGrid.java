import processing.core.PApplet;

public class MaskedGrid extends ColoredGrid {
    private final Mask mask;

    private MaskedGrid(Mask mask, Cell[][] cells) {
        super(mask.getRows(), mask.getColumns(), cells);
        this.mask = mask;
    }

    public MaskedGrid(Mask mask) {
        this(mask, prepareGrid(mask));
    }

    private static Cell[][] prepareGrid(Mask mask) {
        Cell[][] cells = new Cell[mask.getRows()][mask.getColumns()];
        for (int row = 0; row < mask.getRows(); row++) {
            for (int column = 0; column < mask.getColumns(); column++) {
                if (mask.getBit(row, column)) {
                    cells[row][column] = new Cell(row, column);
                } else {
                    cells[row][column] = null;
                }
            }
        }
        return cells;
    }


    @Override
    public Cell randomCell() {
        int[] location = mask.randomLocation();
        if (location != null) {
            int row = location[0];
            int col = location[1];
            return getCell(row, col);
        } else {

            return null;
        }
    }

    public int size() {
        return mask.count();
    }
}