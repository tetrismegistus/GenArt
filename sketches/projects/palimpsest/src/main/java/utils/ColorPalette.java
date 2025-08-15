package utils;

import processing.core.PApplet;

public class ColorPalette {
    int[] colors;

    public ColorPalette(int[] colors) {
        this.colors = colors;
    }

    public int getRandomColor(PApplet pa) {
        return colors[(int) pa.random(colors.length)];
    }
}
