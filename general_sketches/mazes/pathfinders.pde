class Distances {
  Cell root;
  HashMap<Cell, Integer> cells;
  
  Distances(Cell r_) {
    root = r_;
    cells = new HashMap<Cell, Integer>();
    cells.put(root, 0); 
  }
  
  int getDistance(Cell cell) {
    if (cells.get(cell) != null) {
      return cells.get(cell);
    } else {
      return -999;
    }
  }
  
  void setDistance(Cell cell, int distance) {
    cells.put(cell, distance);
  }
  
  Set<Cell> getCells() {
    return cells.keySet();
  
  }
  
}
