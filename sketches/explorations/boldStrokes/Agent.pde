class Agent {
  float x, y;
  float step;
  int steps;

  // stroke generation params
  float baseWidth = 80;
  WidthRuleMul parentRule = new ConstMul();

  // optional paint-inside params (keeps your ThickStroke "simple usage")
  boolean paint = true;
  int childCount = 60;
  float childWMin = 5, childWMax = 22;
  float childLenMin = 0.10, childLenMax = 0.55;
  WidthRuleMul childRule = new NoiseMul(0.25, 0.02);

  Agent(float x, float y, float step, int s) {
    this.x = x;
    this.y = y;
    this.step = step;
    this.steps = s;  
  }

  Agent strokeStyle(float baseWidth, WidthRuleMul rule) {
    this.baseWidth = baseWidth;
    this.parentRule = rule;
    return this;
  }

  Agent paintStyle(int childCount,
                   float childWMin, float childWMax,
                   float childLenMin, float childLenMax,
                   WidthRuleMul childRule) {
    this.paint = true;
    this.childCount = childCount;
    this.childWMin = childWMin;
    this.childWMax = childWMax;
    this.childLenMin = childLenMin;
    this.childLenMax = childLenMax;
    this.childRule = childRule;
    return this;
  }

  // Walk and EMIT a stroke into outStrokes (no drawing).
  void walk(FlowField f, ArrayList<ThickStroke> outStrokes) {
    ArrayList<PVector> pts = new ArrayList<>(steps);

    for (int i = 0; i < steps; i++) {
      pts.add(new PVector(x, y));

      float angle = f.getAngle(x, y);
      x += cos(angle) * step;
      y += sin(angle) * step;

      // optional: early exit if you leave the field bounds
      // (depends on what you want; remove if you want clamped angles to keep going)
      // if (x < f.leftX || x > f.leftX + f.cols*f.resolution || y < f.topY || y > f.topY + f.rows*f.resolution) break;
    }

    // need at least 2 points to build a ribbon; realistically more
    if (pts.size() < 3) return;

    ThickStroke s = new ThickStroke(pts, baseWidth, parentRule);

    if (paint) {
      s.paintInside(childCount, childWMin, childWMax, childLenMin, childLenMax, childRule);
      // optional: s.paintOffset(6.0, 0.95);  // if you kept that method
    }

    outStrokes.add(s);
  }
}
