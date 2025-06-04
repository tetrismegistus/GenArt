class Board {
  float x, y;
  int rows;
  int cols;
  float tileSize;
  Tile[][] board;
  ArrayList<TileRect> rects = new ArrayList<TileRect>();  
  ColorPalette palA, palB;
  int depth;
  int maxDepth;

  Board(float x, float y, int r, int c, float tSz, ColorPalette paletteA, ColorPalette paletteB, int depth, int maxDepth) {
    this.x = x;
    this.y = y;
    rows = r;
    cols = c;
    tileSize = tSz;
    board = new Tile[rows][cols];    
    this.palA = paletteA;
    this.palB = paletteB;
    this.depth = depth;
    this.maxDepth = maxDepth;
  }

  void fillBoard() {
    for (int ty = 0; ty < board.length; ty++) {
      for (int tx = 0; tx < board[ty].length; tx++) {
        if (board[ty][tx] == null) {
          TileRect tr = tryPlaceTile(tx, ty, (int)random(MIN_TILE_WIDTH, MAX_TILE_WIDTH), (int)random(MIN_TILE_HEIGHT, MAX_TILE_HEIGHT));

          if (tr != null) {
            tr.lX = tr.x * tr.tileSize;
            tr.lY = tr.y * tr.tileSize;
            tr.lW = tr.w * tr.tileSize;
            tr.lH = tr.h * tr.tileSize;

            // Store noise once, for consistent palette decisions
            tr.noiseValue = fbm_warp(tr.lX * .1, tr.lY * .1, OCTAVES, .1, .9);

            rects.add(tr);
          }
        }
      }
    }
  }

  TileRect tryPlaceTile(int startX, int startY, int startWidth, int startHeight) {
    int width = startWidth;
    int height = startHeight;

    TileRect tr = new TileRect(startX, startY, width, height, palA, palB, tileSize * rows * 0.005, tileSize);

    while (width > MIN_TILE_WIDTH && height > MIN_TILE_HEIGHT) {
      if (tr.checkIsValid(board)) {
        tr.place(board);
        return tr;
      }

      // Try smaller
      if (width > 1) width--;
      if (height > 1) height--;

      tr.w = width;
      tr.h = height;
    }
    return null;
  }

  void render(PGraphics pg, float padding, int fillMode) {
    pg.pushMatrix();
    pg.translate(x, y);
    pg.noFill();

    for (TileRect tr : rects) {
      tr.render(pg, padding, fillMode);
    }

    pg.popMatrix();
  }
}
