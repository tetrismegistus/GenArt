class Turtle {
  double x, y, heading;
  double stride;
  HashMap<Character,String> rules;
  int maxDepth = 11;
  float angleIncrement;
  

  Turtle (float x, float y, float aI, int d, HashMap<Character,String> rules) {
    this.rules = rules;
    this.x = x;
    this.y = y;
    this.heading = 270.0;
    this.stride = 20.0;
    this.angleIncrement = aI;
    this.maxDepth = d;
   
  }
  
  void executeInstruction(char instruction) {
    
    
    if (instruction == 'F') {
            
      double nx = x +  (stride * Math.cos(Math.toRadians(heading)));
      double ny = y + (stride * Math.sin(Math.toRadians(heading)));
      if (nx > 0 && nx < width && ny > 0 && ny < height) {
        
        Brush b = new Brush(5.0, (float) x, (float) y, color(random(0, 27), random(50, 100), random(20, 100), .5));
        for (int i = 0; i < 100; i++) {
          float lx = lerp((float)x, (float)nx, i/100.0);
          float ly = lerp((float)y, (float)ny, i/100.0);
          b.cx = lx;
          b.cy = ly;
          b.render();
          
        }
      }
      //line((float) x, (float) y, (float) nx, (float) ny);
      float n = noise((float)x * .001, (float)y * 0.001);
      float mn = map(n, 0, 1, 0, 100);
      stroke(27, mn, mn);
      fill(27, mn, mn , .1);
      //noFill();
      //circle((float) x, (float) y, 2.0);
      x = nx;
      y = ny;
    }
    
    if (instruction == 'f') {
      x = x + (stride * Math.cos(Math.toRadians(heading)));
      y = y + (stride * Math.sin(Math.toRadians(heading)));
    }
    
    if (instruction == '+') {
      heading = heading + angleIncrement;
    }
    
    if (instruction == '-') {
      heading = heading - angleIncrement;
    }
  }
  
  void executeInstString(String instr) {
    
    for (int i = 0; i < maxDepth; i++) {
      
      StringBuilder newRule = new StringBuilder("");
      for (char c : instr.toCharArray()) {
        String addition = str(c);
        if (rules.containsKey(c)){
          addition = rules.get(c);         
        } 
        newRule.append(addition);      
      }
      instr = newRule.toString();
    }
    
    for (char c : instr.toCharArray()) {      
      executeInstruction(c);  
    }
  }
  
}
