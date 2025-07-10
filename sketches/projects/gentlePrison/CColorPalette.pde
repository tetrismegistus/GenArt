class ColorPalette {
    color[] colors;

    ColorPalette(color[] colors) {
        this.colors = colors;
    }

    color getRandomColor() {
        return colors[(int)random(colors.length)];
    }
}
