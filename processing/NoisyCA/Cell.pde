class Cell {
  int x, y;
  boolean alive;
  float perlinValue;
  float z = 0; // This could represent generation or time
  color c;
  float age = 0;
  float perlinThreshold;

  Cell(int x, int y, boolean alive) {
    this.x = x;
    this.y = y;
    this.alive = alive;       
    perlinThreshold = .6;
    updatePerlinValue();
  }
  
  void updatePerlinValue() {
    this.perlinValue = noise(54604 + this.x * 0.01f, this.y * 0.01f, z);
  }
  
  void advanceZ(float increment) {
    z += increment;
  }
  
  color getColor() {
    return lerpColor(#C5D1EB, #395B50, age);
  }
  
  

  boolean willLiveNextGen(Cell[][] neighbors) {
    int aliveNeighbors = 0;
    for (Cell[] row : neighbors) {
        for (Cell cell : row) {
            if (cell != null && cell.alive) {
                aliveNeighbors++;
            }
        }
    }
    
    if ((aliveNeighbors == 2 || aliveNeighbors == 3) && this.alive || this.perlinValue > perlinThreshold) {       //<>//
      float potential = age + .1;
      age = min(potential, 1);
      return true;
    }
    
    if ((aliveNeighbors == 3) && !this.alive || this.perlinValue > perlinThreshold) {
      age = 0;
      return true;
    }
    
    if (!this.alive && this.perlinValue > perlinThreshold) {
      age = 0;
      return true;
    }
    
    return false;
  }

}
