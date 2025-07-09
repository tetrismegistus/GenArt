class Branch {
  PVector begin, end;
  boolean finished;
  float angle;
  int depth;
  float lenMod;
  color myColor1, myColor2;
  
  
  Branch(PVector b_, PVector e_, int d_) {
    begin = b_;
    end = e_;    
    finished = false;
    angle = PI/4 + randomGaussian() * .5;
    //angle = PI * 0.5;
    depth = d_;
    lenMod = .73;
    
  }
  
  void show() {
    
    float a = map(depth, 0, maxDepth, 1, .01);
    float sw = map(depth, 0, maxDepth, .1, 2);
    strokeWeight(sw);
    float amount = map(depth, 0, maxDepth, 0, 1);    
    color interCol = lerpColor(myColor1, myColor2, amount);
    stroke(interCol, a);
    
    line(begin.x, begin.y, end.x, end.y);
  }
  
  Branch branchA() {
    
    PVector dir = PVector.sub(end, begin);
    dir.rotate(angle);
    dir.mult(lenMod);
    PVector newEnd = PVector.add(end, dir);
    Branch a = new Branch(end, newEnd, depth + 1);
    return a;
  
  }
  Branch branchB() {
    PVector dir = PVector.sub(end, begin);
    dir.rotate(-angle);
    dir.mult(lenMod);
    PVector newEnd = PVector.add(end, dir);
    Branch b = new Branch(end, newEnd, depth + 1);
    return b;
  
  }
  
}
