class intCurve {
  PVector ap1, cp1, cp2, ap2;
  
  intCurve(PVector ap1, PVector cp1, PVector cp2, PVector ap2) {
    this.ap1 = ap1;
    this.cp1 = cp1;
    this.cp2 = cp2;
    this.ap2 = ap2;
  }
}


class intPoint {
  PVector loc;
  float pSize;
  
  intPoint(PVector loc, float pSize) {
    this.loc = loc;
    this.pSize = pSize;
  }
  
}
