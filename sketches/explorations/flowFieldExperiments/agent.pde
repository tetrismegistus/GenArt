class Agent {
  float x, y;
  float step;

  Agent(float x, float y, float step) {
    this.x = x;
    this.y = y;
    this.step = step;
  }

  void walk(FlowField f, int steps) {
    stroke(f.drawColor, 40);      // ← use the field’s color
    noFill();
    beginShape();

    for (int i=0; i<steps; i++){
      curveVertex(x, y);

      float angle = f.getAngle(x, y);
      x += cos(angle) * step;
      y += sin(angle) * step;
    }

    endShape();
  }
}
