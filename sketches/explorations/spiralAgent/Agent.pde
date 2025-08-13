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
    ArrayList<IntVec> targets;
    if (loc.x > 0 && loc.x < cols && loc.y > 0 && loc.y < rows) {
      targets =  findTargets();            
    } else {
      targets = new ArrayList<IntVec>();            
    }
  
    Collections.shuffle(targets);
    if (targets.size() > 0) {
      
      Brush brush = new Brush(3, 50 + tileSize/2 + loc.x * tileSize, 50 + tileSize/2 + loc.y * tileSize, col);      
      float n = noise(brush.cx * .01, brush.cy * .01); 
      stroke(col);
      strokeWeight(4);
      if (n > .5) { 
        IntVec target = targets.get(0).add(loc);
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
          float r = 0;
          float b = .037;
          
          int endSize = endPoints[(int) random(endPoints.length)];

          for (int i = 0; i < endSize; i++) {
            r = .1 + b * radians(i);
            brush.render();
            float nx = brush.cx + cos(radians(i + 1)) * r;
            float ny = brush.cy + sin(radians(i + 1)) * r;            
            int nix = constrain(((int) nx / (int) tileSize) - 2, 0, rows - 1);
            int niy = constrain(((int) ny / (int) tileSize) - 2, 0, cols - 1);
            if (!board[nix][niy])
              break;
            brush.cx = brush.cx + cos(radians(i)) * r;
            brush.cy = brush.cy + sin(radians(i)) * r;
            //50 + tileSize/2 + loc.x * tileSize
            int lx = constrain(((int) (brush.cy) / (int) tileSize) - 2, 0, rows);
            int ly = constrain(((int) (brush.cx) / (int) tileSize) - 2, 0, cols);
            loc = new IntVec(lx, ly );
            if (loc.x > 0 && loc.x < cols && loc.y > 0 && loc.y < rows) {
              board[loc.x][loc.y] = false;            
            } else {
              targets = new ArrayList<IntVec>();            
            }
          }
                 
         
          
      }


      
    } else {
      fill(col);
      noStroke();
      //circle(100 + tileSize/2 + loc.x * tileSize, 100 + tileSize/2 + loc.y * tileSize, 10);
    }
  }
  
  
  ArrayList<IntVec> findTargets() {
    ArrayList<IntVec> targets = new ArrayList<IntVec>();
    
    float n = noise((50 + tileSize/2 + loc.x * tileSize) * .01, 
    (50 + tileSize/2 + loc.y * tileSize) * .01);
    if (n > .5) {
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
    } else {
    
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
