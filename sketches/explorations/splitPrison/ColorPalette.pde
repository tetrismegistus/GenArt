class ColorPalette {
  int[] colors;

  ColorPalette(int[] colors) {
    this.colors = colors;
  }

  int size() {
    return colors.length;
  }

  int getColor(int index) {
    return colors[constrain(index, 0, colors.length - 1)];
  }

  int getInterpolatedColor(float t) {
    // t is expected in range [0, 1]
    if (colors.length == 0) return color(0);
    if (colors.length == 1) return colors[0];

    // Map t across palette
    float scaled = constrain(t, 0, 1) * (colors.length - 1);
    int idx1 = floor(scaled);
    int idx2 = min(idx1 + 1, colors.length - 1);
    float f = scaled - idx1;
    return lerpColor(colors[idx1], colors[idx2], f);
  }

  int getRandomColor() {
    return colors[(int) random(colors.length)];
  }
}
