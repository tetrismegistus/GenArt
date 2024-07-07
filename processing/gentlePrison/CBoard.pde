class Board {
  float x, y;
  int rows;
  int cols;
  float tileSize;
  Tile[][] board;
  ArrayList<TileRect> rects = new ArrayList<TileRect>();  
  ColorPalette palA, palB; // Two palettes
  int depth;
  int maxDepth;

  // Modify the constructor to accept two palettes
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
                  
                  // Use the new tryPlaceTile method.
                  TileRect tr = tryPlaceTile(tx, ty, (int)random(4, MAX_TILE_WIDTH), (int)random(4, MAX_TILE_HEIGHT));
  
                  if (tr != null) {
                      if (tr.w % 2 == 0 && tr.h % 2 == 0 && depth < maxDepth) {
                          tr.draw = false;                        
                          Board newBoard = new Board(this.x + tr.x * tileSize, 
                                                    this.y + tr.y * tileSize, 
                                                    tr.h * 2, tr.w * 2, 
                                                    tileSize/2, 
                                                    palA, palB, depth+1, this.maxDepth); // Pass both palettes
                          newBoard.fillBoard();
                          boards.add(newBoard);          
                          rects.add(tr);
                      } else {
                          rects.add(tr);
                      }
                  }         
              }    
          }
      }    
  }
  
   /**
   * Attempts to place a tile on the board. 
   * Starts from the given width and height and tries smaller sizes until a valid placement is found or minimum size is reached.
   * 
   * @param startX The x-coordinate to start placement.
   * @param startY The y-coordinate to start placement.
   * @param startWidth The initial width to attempt to place.
   * @param startHeight The initial height to attempt to place.
   * @param c Color of the tile.
   * @return A successfully placed TileRect or null if no valid placement was found.
   */
   TileRect tryPlaceTile(int startX, int startY, int startWidth, int startHeight) {
        int width = startWidth;
        int height = startHeight;

        // Pass both palettes to the TileRect constructor
        TileRect tr = new TileRect(startX, startY, width, height, palA, palB, tileSize*rows*.005, tileSize);

        while (width > 0 && height > 0) {
            if (tr.checkIsValid(board)) {
                tr.place(board);
                return tr;
            }

            // Decrement the width and height to check for smaller tile sizes.
            if (width > 1) width--;
            if (height > 1) height--;

            tr.w = width;
            tr.h = height;
        }
        return null;  // No valid placement was found.
  }
  
  void render(float padding) {
    outputBuffer.pushMatrix();
    outputBuffer.translate(x, y);
    outputBuffer.noFill();

    //rect(0, 0, this.cols * tileSize, this.rows * tileSize);
    for (TileRect tr : rects) {
      tr.render(padding);
    }
    outputBuffer.popMatrix();
  }

}
