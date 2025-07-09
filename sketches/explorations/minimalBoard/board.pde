class Board {
  float x, y;
  int rows;
  int cols;
  float tileSize;
  Tile[][] board;
  ArrayList<TileRect> rects = new ArrayList<TileRect>();
  ColorPalette palA, palB; 

  // Modify the constructor to accept two palettes
  Board(float x, float y, int c, int r, float tSz, ColorPalette paletteA, ColorPalette paletteB) {
    this.x = x;
    this.y = y;    
    cols = c;
    rows = r;
    board = new Tile[cols][rows];  
    this.tileSize = tSz;
    this.palA = paletteA;
    this.palB = paletteB;
  }

  TileRect tryPlaceTile(int startX, int startY, int startWidth, int startHeight) {
    TileRect tr = new TileRect(startX, startY, width, height, palA, palB, tileSize*rows*.005, tileSize);
    while (width > 0 && height > 0) {
        if (tr.checkIsValid(board)) {
            tr.place(board);
            return tr;
        }
        // Decrement the width and height to check for smaller tile sizes.
        if (startWidth > 1) startWidth--;
        if (startHeight > 1) startHeight--;
        tr.w = startWidth;
        tr.h = startHeight;
    }
    return null;  // No valid placement was found.
  }
  
  void fillBoard() {
    for (int ty = 0; ty < board.length; ty++) {
      for (int tx = 0; tx < board[ty].length; tx++) {
        if (board[ty][tx] == null) {            
          TileRect tr = tryPlaceTile(tx, ty, (int)random(4, MAX_TILE_WIDTH), (int)random(4, MAX_TILE_HEIGHT));

          if (tr != null) {
              
              rects.add(tr);                  
          }         
        }    
      }
    }   
  }



  void render(float padding) {
    for (TileRect tr : rects) {
      tr.render(padding);
    }
  }
}
