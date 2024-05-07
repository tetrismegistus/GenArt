class ColorPalette {
  color[] colors;

  ColorPalette(color[] colors) {
    this.colors = colors;
  }

  color getRandomColor() {
    return colors[(int)random(colors.length)];
  }

  // New method to get a color based on a noise value
  color getColorFromNoise(float noiseValue) {
    // Map the noise value to an index in the colors array
    int index = constrain(floor(noiseValue * colors.length), 0, colors.length - 1);
    return colors[index];
  }
}
