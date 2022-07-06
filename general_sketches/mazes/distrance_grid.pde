class DistanceGrid extends Grid {
  Distances distances;
  
  DistanceGrid(int r_, int c_) {
    super(r_, c_);       
    
  }
  
  int contentsOf(Cell cell) {
    if ((distances != null) && (distances.getDistance(cell) != -999)) {
      return distances.getDistance(cell);
    } else {
      return 0;
    }
  }
}
