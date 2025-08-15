public class ColorPalette {
    int[] colors;

    ColorPalette(int[] colors) {
        this.colors = colors;
    }

    int getRandomColor(PApplet pa) {
        return colors[(int)pa.random(colors.length)];
    }
}
