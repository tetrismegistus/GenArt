import processing.core.PApplet;
import processing.core.PImage;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Mask {
    private int rows;
    private int columns;
    private boolean[][] bits;

    public Mask(int rows, int columns) {
        this.rows = rows;
        this.columns = columns;
        this.bits = new boolean[rows][columns];
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < columns; j++) {
                bits[i][j] = true;
            }
        }
    }

    public int getRows() {
        return rows;
    }

    public void setRows(int rows) {
        this.rows = rows;
    }

    public int getColumns() {
        return columns;
    }

    public void setColumns(int columns) {
        this.columns = columns;
    }

    public boolean[][] getBits() {
        return bits;
    }

    public void setBits(boolean[][] bits) {
        this.bits = bits;
    }

    public boolean getBit(int row, int column) {
        if (row >= 0 && row < rows && column >= 0 && column < columns) {
            return bits[row][column];
        }
        return false;
    }

    public void setBit(int row, int column, boolean value) {
        bits[row][column] = value;
    }

    public int count() {
        int count = 0;
        for (int row = 0; row < rows; row++) {
            for (int column = 0; column < columns; column++) {
                if (bits[row][column]) {
                    count++;
                }
            }
        }
        return count;
    }

    public int[] randomLocation() {
        List<int[]> trueLocations = new ArrayList<>();
        for (int row = 0; row < rows; row++) {
            for (int column = 0; column < columns; column++) {
                if (bits[row][column]) {
                    trueLocations.add(new int[]{row, column});
                }
            }
        }

        if (trueLocations.isEmpty()) {
            return null;
        } else {
            Random random = new Random();
            int randomIndex = random.nextInt(trueLocations.size());
            return trueLocations.get(randomIndex);
        }
    }

    public static Mask fromPNG(String filename, PApplet pa) {
        PImage image = pa.loadImage(filename);
        Mask mask = new Mask(image.height, image.width);
        for (int row = 0; row < mask.getRows(); row++) {
            for (int col = 0; col < mask.getColumns(); col++) {
                int clr = image.get(col, row);
                //pa.println(pa.red(clr));
                mask.setBit(row, col, pa.red(clr) == 0.0f && pa.green(clr) == 0.0f && pa.blue(clr) == 0.0f);
            }
        }
        return mask;
    }
}