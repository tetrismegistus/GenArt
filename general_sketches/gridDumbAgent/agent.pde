class Agent {
  IntVec loc;
  color col;
  
  Agent(int r, int c, color col) {
    loc = new IntVec(c, r);
    board[r][c] = false;    
    this.col = col;
    fill(col);
    noStroke();
    //circle(100 + tileSize/2 + loc.x * tileSize, 100 + tileSize/2 + loc.y * tileSize, 10);
    
  }
  
  void move() {
    ArrayList<IntVec> targets = findTargets();
    
    Collections.shuffle(targets);
    if (targets.size() > 0) {
      
      Brush brush = new Brush(5, 50 + tileSize/2 + loc.x * tileSize, 50 + tileSize/2 + loc.y * tileSize, col);
      IntVec target = targets.get(0).add(loc); 
      stroke(col);
      strokeWeight(4);
      float x1 = 50 + tileSize/2 + loc.x * tileSize;
      float y1 = 50 + tileSize/2 + loc.y * tileSize;
      float x2 = 50 + tileSize/2 + target.x * tileSize;
      float y2 = 50 + tileSize/2 + target.y * tileSize;
      for (int i = 0; i < 100; i++) {
        float lx = lerp(x1, x2, i/100.);
        float ly = lerp(y1, y2, i/100.);
        brush.cx = lx;
        brush.cy = ly;
        brush.render();
      }

      board[target.y][target.x] = false;
      loc = target;
    } else {
      fill(col);
      noStroke();
      //circle(100 + tileSize/2 + loc.x * tileSize, 100 + tileSize/2 + loc.y * tileSize, 10);
    }
  }
  
  
  ArrayList<IntVec> findTargets() {
    ArrayList<IntVec> targets = new ArrayList<IntVec>();
    

    if (loc.y + 1 < rows) {
      if (board[loc.y + 1][loc.x]) {
        targets.add(new IntVec(0, 1));        
      }
    }
    
    if (loc.y - 1 > -1) {
      if (board[loc.y - 1][loc.x]) {
        targets.add(new IntVec(0, -1));        
      }
    }
    
    if (loc.x - 1 > -1) {
      if (board[loc.y][loc.x - 1]) {
        targets.add(new IntVec(-1, 0));        
      }
    }
    
    if (loc.x + 1 < cols ) {
      if (board[loc.y][loc.x + 1]) {
        targets.add(new IntVec(1, 0));        
      }
    }
   
    
    if (loc.x - 1 > - 1 && loc.y - 1 > -1) {
      if (board[loc.y - 1][loc.x - 1] && board[loc.y][loc.x-1] && board[loc.y - 1][loc.x]) {
        targets.add(new IntVec(-1, -1));        
      }
    }

      
    if (loc.x - 1 > - 1 && loc.y < rows - 1 && board[loc.y][loc.x-1] && board[loc.y + 1][loc.x]) {
      if (board[loc.y + 1][loc.x - 1]) {
        targets.add(new IntVec(-1, 1));        
      }
    }
    
    if (loc.x < cols - 1 && loc.y < rows - 1 && board[loc.y + 1][loc.x] && board[loc.y][loc.x + 1]) {
      if (board[loc.y + 1][loc.x + 1]) {
        targets.add(new IntVec(1, 1));        
      }
    }
    
    if (loc.x < cols - 1 && loc.y > 0 && board[loc.y][loc.x+1] && board[loc.y - 1][loc.x]) {
      if (board[loc.y - 1][loc.x + 1]) {
        targets.add(new IntVec(1, -1));        
      }
    }
   
    
    return targets;
  }
   
}


class IntVec {
  int x, y;
  IntVec(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  IntVec() {
    this(0, 0);
  }
  
  IntVec add(IntVec o) {
    return new IntVec(this.x + o.x, this.y + o.y);  
  }
}
