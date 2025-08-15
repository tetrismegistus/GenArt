void catalogAllColors() {
  colorCount = new HashMap<Integer, Integer>();
  for (int i = 0; i < img.pixels.length; i++) {
    int currentColor = img.pixels[i];
    colorCount.put(currentColor, colorCount.getOrDefault(currentColor, 0) + 1);
  }
}

void sortByOccurrences() {
  sortedColors = new ArrayList<Entry<Integer, Integer>>(colorCount.entrySet());
  Collections.sort(sortedColors, (a, b) -> b.getValue().compareTo(a.getValue()));
}

void filterSignificantColors(float threshold) {
  significantColors = new ArrayList<Integer>();
  for (Entry<Integer, Integer> entry : sortedColors) {
    boolean isDistinct = true;
    float[] currentCIELab = RGBtoCIELab(entry.getKey());
    for (int sigColor : significantColors) {
      float[] sigCIELab = RGBtoCIELab(sigColor);
      if (deltaE2k(currentCIELab, sigCIELab) < threshold) {
        isDistinct = false;
        break;
      }
    }
    if (isDistinct) {
      significantColors.add(entry.getKey());
    }
  }
}

void printAndDisplay(int nColors) {
  String colorCodes = "";
  int counter = 0;
  for (int col : significantColors) {
    if (counter < nColors) {
      fill(col);
      rect(10 + (counter % 10) * 50, floor(counter / 10) * 50 + 50, 40, 40);
      colorCodes += "#" + hex(col, 6) + (counter < nColors - 1 ? ", " : "");
    }
    counter++;
    if (counter >= nColors) break;
  }
  println("Top " + nColors + " significant colors: " + colorCodes);
}

float[] RGBtoCIELab(int rgb) {
  float[] XYZ = RGBtoXYZ(red(rgb), green(rgb), blue(rgb));
  return XYZtoCIELab(XYZ[0], XYZ[1], XYZ[2]);
}
