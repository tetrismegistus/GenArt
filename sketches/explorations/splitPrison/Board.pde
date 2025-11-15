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
          float meanW = (MIN_TILE_WIDTH + MAX_TILE_WIDTH) / 2.0;
          float meanH = (MIN_TILE_HEIGHT + MAX_TILE_HEIGHT) / 2.0;
          
          // slightly wider spread — fewer tiles near the mean, more toward extremes
          float sdW = (MAX_TILE_WIDTH - MIN_TILE_WIDTH) / 4.0;
          float sdH = (MAX_TILE_HEIGHT - MIN_TILE_HEIGHT) / 4.0;
          
          float w = constrain((float)randomGaussian() * sdW + meanW, MIN_TILE_WIDTH, MAX_TILE_WIDTH);
          float h = constrain((float)randomGaussian() * sdH + meanH, MIN_TILE_HEIGHT, MAX_TILE_HEIGHT);
          
          TileRect tr = tryPlaceTile(tx, ty, (int)w, (int)h);


          if (tr != null) {
            tr.lX = tr.x * tr.tileSize;
            tr.lY = tr.y * tr.tileSize;
            tr.lW = tr.w * tr.tileSize;
            tr.lH = tr.h * tr.tileSize;
  
            // store noise for palette decisions
            tr.noiseValue = (float) oNoise.eval(tr.lX * NOISE_SCALE, tr.lY * NOISE_SCALE);

  
            // 🔸 Apply padding logic (using global 'padding')
            float actualPadding = min(tr.lW, tr.lH) * PADDING;
            float padX = tr.lX + actualPadding;
            float padY = tr.lY + actualPadding;
            float padW = tr.lW - 2 * actualPadding;
            float padH = tr.lH - 2 * actualPadding;
  
            // Create padded tile geometry
            Polygon tile = createRect(x + padX, y + padY, padW, padH);
            holePolygons.add(tile);
  
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

}
