class Grid {
  int rows, cols, N;
  Random rng = new Random();

  float leftX, topY, rightX, bottomY;
  float gridWidth, gridHeight;
  float cellWidth, cellHeight;

  Grid(int w, int h) {
    // padded bounds in the coordinate system you pass in (screen or SS buffer)
    leftX   = w * PADDING;
    topY    = h * PADDING;
    rightX  = w - leftX;
    bottomY = h - topY;

    gridWidth  = rightX - leftX;
    gridHeight = bottomY - topY;

    // "desired" cell size derived from CELL_SCALE (fraction of padded region)
    float desiredCellW = gridWidth  * CELL_SCALE;
    float desiredCellH = gridHeight * CELL_SCALE;

    // choose integer grid resolution
    cols = max(1, floor(gridWidth  / desiredCellW));
    rows = max(1, floor(gridHeight / desiredCellH));
    N = rows * cols;

    // recompute actual cell pitch so the grid fits exactly
    cellWidth  = gridWidth  / cols;
    cellHeight = gridHeight / rows;
  }

  int[] makeIndexBagShuffled() {
    int[] bag = new int[N];
    for (int i = 0; i < N; i++) bag[i] = i;
    for (int i = N - 1; i > 0; i--) {
      int j = rng.nextInt(i + 1);
      int tmp = bag[i];
      bag[i] = bag[j];
      bag[j] = tmp;
    }
    return bag;
  }

  int index(int r, int c) { return r * cols + c; }
  int rowOf(int idx)      { return idx / cols; }
  int colOf(int idx)      { return idx % cols; }

  float centerXOfCol(int c) { return leftX + (c + 0.5f) * cellWidth; }
  float centerYOfRow(int r) { return topY  + (r + 0.5f) * cellHeight; }

  PVector centerOfCell(int r, int c) {
    return new PVector(centerXOfCol(c), centerYOfRow(r));
  }

  PVector centerOfIndex(int idx) {
    return centerOfCell(rowOf(idx), colOf(idx));
  }

  int neighbors4(int idx, int[] out) {
    int r = rowOf(idx), c = colOf(idx);
    int n = 0;
    if (r > 0)         out[n++] = index(r-1, c);
    if (r < rows - 1)  out[n++] = index(r+1, c);
    if (c > 0)         out[n++] = index(r, c-1);
    if (c < cols - 1)  out[n++] = index(r, c+1);
    return n;
  }

  int unvisitedNeighbors4(int idx, boolean[] occupiedEver, int[] out) {
    int nAll = neighbors4(idx, out);
    int n = 0;
    for (int i = 0; i < nAll; i++) {
      int cand = out[i];
      if (!occupiedEver[cand]) out[n++] = cand;
    }
    return n;
  }
}
