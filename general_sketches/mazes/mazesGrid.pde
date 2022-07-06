class Grid {
  int rows, columns;
  Cell[][] _grid;
  
  
  Grid (int r_, int c_) {
    rows = r_;
    columns = c_;
    _grid = prepare_grid();
    this.configure_cells();
  }
  
  Cell[][] prepare_grid() {
    Cell[][] cgrid = new Cell[rows][columns];
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        cgrid[y][x] = new Cell(y, x);
       }
    }         
    return cgrid;
  }
  
  void configure_cells() {
    for (Cell[] row : _grid){
      for(Cell cell : row) {
        int crow = cell.row;
        int ccol = cell.column;
        cell.north = grid(ccol, crow - 1);
        cell.south = grid(ccol, crow + 1);
        cell.west = grid(ccol - 1, crow);
        cell.east = grid(ccol + 1 , crow);
        
      }
    }     
  }
  
  Cell grid(int c, int r) {
    if (!((0 <= r) && (r < rows))) {
      return null;
    }
    if (!((0 <= c) && (c < columns))) {
      return null;
    }
    return _grid[r][c];
  }
  
  Cell random_cell() {
    int r = int(random(rows));
    int c = int(random(columns));
    return this.grid(c, r);
  }
  
  int size() {
    return rows * columns;
  }
  
  int contentsOf(Cell cell) {
    return 0;
  }
  
  void render(float cellSize) {
    color wall = color(123, 123, 123, 50);
    float sw = .3;
    
    for (Cell[] row : _grid){
      for(Cell cell : row) {
        float x1 = cell.column * cellSize;
        float y1 = cell.row * cellSize;
        float x2 = (cell.column + 1) * cellSize;
        float y2 = (cell.row + 1) * cellSize;
        
        //fill(wall);
        stroke(wall);
        float h = hue(fc);
        if (cell.north == null) {
          neonLine(x1, y1, x2, y1, h);
        }
        
        if (cell.west == null) {
          neonLine(x1, y1, x1, y2, h);
        }
        
        if (!cell.linked(cell.east)) {
          neonLine(x2, y1, x2, y2, h);                   
        }
        
        if (!cell.linked(cell.south)) {
          neonLine(x1, y2, x2, y2, h);          
        }
      }
    }
  }
    
}
