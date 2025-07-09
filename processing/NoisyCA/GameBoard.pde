class GameBoard {
  int width, height;
  float generation;
  float timeIncrement = 0.001;
  Cell[][] board;
  

  GameBoard(int width, int height) {
    this.width = width;
    this.height = height;
    this.board = new Cell[width][height];
    generation = 0.0;

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        board[x][y] = new Cell(x, y, random(1) > .5); // Random initial state
      }
    }
  }

  Cell[][] getNeighbors(int x, int y) {
    Cell[][] neighbors = new Cell[3][3];
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            int nx = x + i;
            int ny = y + j;               
            if (nx >= 0 && ny >= 0 && nx < width && ny < height && (i != 0 || j != 0)) {
                neighbors[i + 1][j + 1] = board[nx][ny];
            }
        }
    }
    
    return neighbors;
}

  void evolve() {
    boolean[][] newStates = new boolean[width][height];

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {        
        newStates[x][y] = board[x][y].willLiveNextGen(getNeighbors(x, y));
        board[x][y].advanceZ(this.timeIncrement);
        board[x][y].updatePerlinValue();
        
      }
    }

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        board[x][y].alive = newStates[x][y];
      }
    }
  }
}
