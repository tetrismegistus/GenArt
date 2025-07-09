class ColliderRect {
  PVector pos;
  float w, h;
  
  ColliderRect(PVector pos, float w, float h) {
    this.pos = pos;
    this.w = w;
    this.h = h;
  }
  
  void display() {
    noStroke();
    fill(#a4bec3);
    //rect(pos.x, pos.y, w, h);
  }
  
  void collideWith(PVector atom, PVector vel) {
    if ((atom.x > pos.x)
        && (atom.x < pos.x + w)
        && (atom.y > pos.y) 
        && (atom.y < pos.y + h)) {
          if (atom.x > pos.x) {
            atom.y = pos.y; 
            atom.x = pos.x;   

          }
          if (atom.x < pos.x + w) {
            atom.y = pos.y;
            atom.x = pos.x;   
          
          }
    }    
  }
}
