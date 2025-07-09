class Grid {
  PVector upperLeft;
  int row, col;
  int rows, cols;
  float cellSize;
  boolean[][] cells;
  ArrayList<Grid> grids;
  color clr;
  
  Grid (float x, float y, int rows, int cols, int row, int col, float cellSize, color clr) {
    this.row = row;
    this.col = col;
    this.upperLeft = new PVector(x, y);
    this.rows = rows;
    this.cols = cols;
    this.cellSize = cellSize;
    this.clr = clr;
    cells = new boolean[this.rows][this.cols];
    for (int r = 0; r < rows - 1; r++) {
      for (int c = 0; c < cols - 1; c++) {
        this.cells[r][c] = false;
      }
    }
    grids = new ArrayList<Grid>();    
  }
  
  boolean isValid(Grid otherGrid) {
  if ((row + otherGrid.rows > this.rows) ||
      (col + otherGrid.cols > this.cols)) 
        return false;
      
   for (int myRow = otherGrid.row; myRow < this.rows - 1; myRow++) {
     for (int myCol = otherGrid.col; myCol < this.cols - 1; myCol++) {
       if (this.cells[myRow][myCol])
         return false;
     }
   }
  return true;
  }
  
  void fillGrid() {
    if (this.cellSize < MIN_SIZE)
      return;
    
    for (int i = 0; i < MAX_ATTEMPTS; i++) {
      int pwidth = (int) random(1, this.rows - 1);
      int pheight = (int) random(1, this.cols - 1);
      int prow = (int) random(this.rows - 1);
      int pcol = (int) random(this.cols - 1);
      float x = prow * this.cellSize + upperLeft.x;
      float y = pcol * this.cellSize + upperLeft.y;
      color newColor = color(pal[(int)random(pal.length)]);
      int newSize = (int) cellSize/2;
      Grid newGrid = new Grid(x, y, pwidth, pheight, prow, pcol, newSize, newColor);
      if (isValid(newGrid)) {
        if(random(1) > .9) 
          newGrid.fillGrid();
        this.grids.add(newGrid);              
      }
    }
    return;    
  }
  
  void render() {
    float pixW = this.cellSize * this.rows;
    float pixH = this.cellSize * this.cols;      
    noFill();
    float h = hue(this.clr);
    float s = saturation(this.clr);
    float b = brightness(this.clr);
    float a = 1;
    //stroke(grid.clr);
    fill(h,s,b,a);
    if (pixW == pixH) {
      if (random(1) > .5) {
        ellipse(this.upperLeft.x, this.upperLeft.y, pixW, pixH);
      } else {
        if (random(1) > .5) {
          triangle(this.upperLeft.x, this.upperLeft.y + pixH,
                   this.upperLeft.x + pixW, this.upperLeft.y + pixH,
                   this.upperLeft.x + pixW/2, this.upperLeft.y);                   
        } else {
          triangle(this.upperLeft.x, this.upperLeft.y,
                   this.upperLeft.x + pixW, this.upperLeft.y,
                   this.upperLeft.x + pixW/2, this.upperLeft.y + pixH);
        
        }
      }
      
    } else {
      rect(this.upperLeft.x, this.upperLeft.y, pixW, pixH);
      float minSizeW = 12/textWidth("test") * pixW;
      float minSizeH = 12/(textDescent()+textAscent()) *pixH;
      float textsz = min(minSizeW, minSizeH);
      blendMode(DIFFERENCE);
      if (textsz > 5) {
        fill(#FFFFFF);      
        text((char) int(random(33, 127)), this.upperLeft.x + pixW/2, this.upperLeft.y + pixH-textDescent()*1.5);
      }
      //blendMode(NORMAL);
    }
    for (Grid grid : grids) {
      grid.render();      
    }
  }
}
