class Agent {
  float x, y;
  float step;
  ArrayList<Pose> points;
  color baseColor;

  Agent(float x, float y, float step, color c) {
    this.x = x;
    this.y = y;
    this.step = step;
    this.points = new ArrayList<Pose>();
    this.baseColor = c;
  }

  void walk(FlowField f, int steps) {
    for (int i = 0; i < steps; i++) {
      float angle = f.getAngle(x, y);
      points.add(new Pose(x, y, angle));
      x += cos(angle) * step;
      y += sin(angle) * step;
    }
  }
  
  void draw(PGraphics pg) {
    for (Pose p : points) {
      pg.pushMatrix();
      pg.translate(p.pos.x, p.pos.y);
      pg.rotate(p.heading);
      threadbox(0, 0, 50, 50, 0, 5, baseColor, pg);

      pg.popMatrix();
    }
  
  }
  
}


class Pose {
  PVector pos;
  float heading; 
  Pose(float x, float y, float heading) {
    this.pos = new PVector(x, y);
    this.heading = heading;
  }
}
