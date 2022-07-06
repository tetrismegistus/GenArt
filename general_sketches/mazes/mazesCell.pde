class Cell { //<>//
  int row, column;
  HashMap<Cell, Boolean> links;
  Cell north, south, east, west;

  Cell(int r_, int c_) {
    row = r_;
    column = c_;
    links = new HashMap<Cell, Boolean>();
  }

  void link(Cell cell, boolean bidi) {
    links.put(cell, true);
    if (bidi) {
      cell.link(this, false);
    }
  }

  void unlink(Cell cell, boolean bidi) {
    links.remove(cell);
    if (bidi) {
      cell.unlink(this, false);
    }
  }

  Set<Cell> links() {
    return links.keySet();
  }

  boolean linked(Cell cell) {
    if (links.get(cell) == null) {
      return false;
    } else {
      return true;
    }
  }
  


  ArrayList<Cell> neighbors() {
    ArrayList<Cell> dlist = new ArrayList<Cell>();
    if (north != null) {
      dlist.add(north);
    } 

    if (south != null) {
      dlist.add(south);
    } 

    if (east != null) {
      dlist.add(east);
    } 

    if (west != null) {
      dlist.add(west);
    }
    return dlist;
  }       


  Distances distances() {
    Distances distances = new Distances(this);
    ArrayList<Cell> frontier = new ArrayList<Cell>();
    frontier.add(this);

    while (frontier.size() > 0) {
      ArrayList<Cell> newFrontier = new ArrayList<Cell>();
      for (Cell cell : frontier) {
        for (Cell linked : cell.links()) {
          if (distances.getDistance(linked) != -999) {
            distances.setDistance(linked, distances.getDistance(cell) + 1);
            newFrontier.add(linked);
          }
        }
      }
      frontier = newFrontier;
    }        

    return distances;
  }
}
