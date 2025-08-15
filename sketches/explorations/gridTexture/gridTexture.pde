// Processing (Java mode)

void settings() {
  // Fullscreen like createCanvas(windowWidth, windowHeight)
  // (swap to size(W, H, P2D) if you prefer fixed dimensions)
  fullScreen(P2D);
}

void setup() {
  colorMode(HSB, 360, 100, 100, 1);
  noLoop();
  background(0, 0, 100);

  int[] cellSizes = {128, 64, 32, 16, 8, 4, 2}; // coarse -> fine
  for (int s : cellSizes) {
    int cols = (int) ceil(width / (float) s);
    int rows = (int) ceil(height / (float) s);
    float h = map(s, 2, 128, 180, 300);
    drawGrid(cols, rows, s, h);
  }

  // save the canvas (in the sketch folder)
  saveFrame("grid_art_auto.png");
}

void draw() {
  // not used (noLoop)
}

void drawGrid(int cols, int rows, float cellSize, float h) {
  int[][] values = new int[cols][rows];

  // fill cells
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int n = (int) random(1, 9); // 1..8 inclusive (matches p5 int(random(1,9)))
      float x = i * cellSize;
      float y = j * cellSize;

      float sat = map(n, 0, 9, 20, 100);
      float brt = map(n % 2, 0, 1, 20, 100);

      noStroke();
      fill(h, sat, brt, 0.2f);
      rect(x, y, cellSize, cellSize);

      values[i][j] = n;
    }
  }

  // draw connecting lines for odd-odd neighbors
  stroke(0);
  strokeWeight(1);
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float x = i * cellSize;
      float y = j * cellSize;
      int val = values[i][j];

      if (i < cols - 1) {
        int neighborVal = values[i + 1][j];
        if (val % 2 == 1 && neighborVal % 2 == 1) {
          line(x + cellSize / 2f, y + cellSize / 2f,
               x + 1.5f * cellSize, y + cellSize / 2f);
        }
      }
      if (j < rows - 1) {
        int neighborVal = values[i][j + 1];
        if (val % 2 == 1 && neighborVal % 2 == 1) {
          line(x + cellSize / 2f, y + cellSize / 2f,
               x + cellSize / 2f, y + 1.5f * cellSize);
        }
      }
    }
  }
}
