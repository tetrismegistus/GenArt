class TrailManager {
  ArrayList<Trail> trails  = new ArrayList<Trail>(); 
  int trailIndex = 0;

  void displayTrails() {
    for (Trail trail : trails) {
      noFill();
      strokeWeight(2.5);
      stroke(trail.c, 1);
      beginShape();
      for (PVector v : trail.trail) {

        curveVertex(v.x, v.y);

      }
      endShape();
    }
  }
  
  int createTrail(color c) {
    trails.add(new Trail(c));
    trailIndex++;
    return trailIndex - 1;
  }
}

class Trail {
  ArrayList<PVector> trail = new ArrayList<PVector>();
  color c;
  
  Trail(color c_) {
    this.c = c_;
  }
}
