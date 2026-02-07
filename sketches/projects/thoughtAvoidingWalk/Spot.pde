class Spot {
  IntVec pos;    
  PVector realPos;
  Step[] options;
  PVector connector;
  PVector dir;
  PVector fromDir;
  boolean visited = false;
  char letter;
  color clr;
  
  
  Spot(int x, int y) {
    pos = new IntVec(x, y); 
    realPos = new PVector(x * cellSize + padding, y * cellSize + padding);
    options = allOptions();
  }
  
  void clear() {
    visited = false;
    options = allOptions();
  }
  
  Spot nextSpot() {
    ArrayList<Step> validOptions = new ArrayList<>();
    for (Step option : options) {
      IntVec newPos = pos.add(option.dir);
      if (isValid(newPos) && !option.tried) {
        validOptions.add(option);
      }
    }
  
  
    Collections.shuffle(validOptions);
    if (validOptions.size() > 0) {
      Step step = validOptions.get(0);
      step.tried = true;
      return grid[pos.y + step.dir.y][pos.x + step.dir.x]; 
    }
    return null;
  }
  
  void display(Spot next) {
    stroke(clr);
    fill(clr);
    text(letter, realPos.x + cellSize/2, realPos.y + cellSize/2.3);  
    strokeWeight(4);
    
    if (connector != null) {
      drawArrow(realPos.x + cellSize/2, realPos.y + cellSize/2, next.realPos.x + cellSize/2, next.realPos.y + cellSize/2);

      if(next.letter == ' ')
        drawConnection(next);
    }
  
  }
   
  
  void drawArrow(float x1, float y1, float x2, float y2) {
    //line(x1, y1, x2, y2);
    PVector vec = new PVector(x2 - x1, y2 - y1);
    vec.mult(.62);
    x2 = x1 + vec.x;
    y2 = y1 + vec.y;
    vec.setMag(8);
    line(x2, y2, x2 - vec.x + vec.y, y2 - vec.y - vec.x);
    line(x2, y2, x2 - vec.x - vec.y, y2 - vec.y + vec.x);
    
  }
  
  void drawConnection(Spot next) {
  if (next.connector != null) {
    int steps = 1000;
    noFill();
    strokeWeight(3);
    for (int i = 0; i <= steps; i++) {      
      float t = i / float(steps);
      color Curclr = lerpColor(clr, next.clr, map(i, 0, steps, 0, 1));
      stroke(Curclr);
      float x = bezierPoint(connector.x, connector.x + dir.x, next.connector.x + next.fromDir.x, next.connector.x, t);
      float y = bezierPoint(connector.y, connector.y + dir.y, next.connector.y + next.fromDir.y, next.connector.y, t);      
      point(x, y);
    }        
  }
}
  
  
}

class Step {
  IntVec dir;
  boolean tried;
  
  Step(int vert, int hor) {
    dir = new IntVec(vert, hor);
    tried = false;    
  }
    
}


Step[] allOptions() {
  Step[] options = {new Step(1, 0), new Step(-1, 0), new Step(0, 1), new Step(0, -1)};
  return options;
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


boolean isValid(IntVec pos) {
  if (pos.x < 0 || pos.x >= cols || pos.y < 0 || pos.y >= rows) {
    return false;
  }
  return !grid[pos.y][pos.x].visited;
}
