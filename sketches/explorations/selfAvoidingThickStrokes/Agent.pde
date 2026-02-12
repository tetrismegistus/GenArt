class Agent {
  int idx;
  ArrayList<PVector> history = new ArrayList<>();
  final int[] nbr = new int[4];
  boolean stuck = false;
  color agentColor;

  // smoothing control
  int smoothIters = 4;
  int cachedSmoothIters = -1;

  // cached render artifact
  ThickStroke cachedStroke = null;
  int cachedHistorySize = -1;

  // --- stroke sizing ---
  // baseWidth = min(cellW, cellH) * widthMul
  float widthMul = .5;

  // --- sine styling knobs ---
  // SineMul(amp, cycles, phase)
  float sineAmp  = 0.2f;
  float sineBase = 0.10f;

  // wave scaling: cycles derived from ARC LENGTH in "cell units"
  float wavesPerCell = 0.1f; // cycles ≈ wavesPerCell * (lenPx / cellSize)
  int wavesMin = 2;
  int wavesMax = 10;

  // paint-inside params; widths are FRACTIONS of baseWidth
  boolean paint = true;
  int childCount = 30;
  float childWMinFrac = 0.10f, childWMaxFrac = 0.35f;
  float childLenMin = 0.10f, childLenMax = 0.55f;

  // child rule (optional sine)
  boolean childUsesSine = true;
  float childSineAmp  = 0.10f;
  float childSineBase = 0.20f;

  Agent(int startIdx, Grid grid, color clr) {
    
    idx = startIdx;
    agentColor = clr;
    updateHistory(grid);
  }

  // ----- fluent styling -----

  Agent strokeWidthMul(float mul) {
    widthMul = mul;
    invalidateStroke();
    return this;
  }

  Agent smoothing(int iters) {
    smoothIters = max(0, iters);
    invalidateStroke();
    return this;
  }

  Agent sineStyle(float amp, float phase, float wavesPerCell, int wMin, int wMax) {
    this.sineAmp = amp;
    this.sineBase = phase;
    this.wavesPerCell = wavesPerCell;
    this.wavesMin = wMin;
    this.wavesMax = wMax;
    invalidateStroke();
    return this;
  }

  Agent paintStyle(int count,
                   float wMinFrac, float wMaxFrac,
                   float lenMin, float lenMax) {
    paint = true;
    childCount = count;
    childWMinFrac = wMinFrac;
    childWMaxFrac = wMaxFrac;
    childLenMin = lenMin;
    childLenMax = lenMax;
    invalidateStroke();
    return this;
  }

  Agent childSineStyle(boolean enabled, float amp, float phase) {
    childUsesSine = enabled;
    childSineAmp = amp;
    childSineBase = phase;
    invalidateStroke();
    return this;
  }

  Agent noPaint() {
    paint = false;
    invalidateStroke();
    return this;
  }

  void invalidateStroke() {
    cachedStroke = null;
    cachedHistorySize = -1;
    cachedSmoothIters = -1;
  }

  // ----- movement bookkeeping -----

  PVector position(Grid grid) {
    return grid.centerOfIndex(idx);
  }

  void updateHistory(Grid grid) {
    history.add(position(grid));
  }

  void step(Grid grid, boolean[] occupiedEver) {
    if (stuck) return;

    int n = grid.unvisitedNeighbors4(idx, occupiedEver, nbr);
    if (n == 0) { stuck = true; return; }

    idx = nbr[grid.rng.nextInt(n)];
    occupiedEver[idx] = true;
    updateHistory(grid);

    // optional: if you ever animate and want live rebuilds
    // invalidateStroke();
  }

  // ----- rendering -----

  void draw(PGraphics pg, Grid grid) {
    if (history.size() < 3) return;

    float cellSize = min(grid.cellWidth, grid.cellHeight);
    float baseWidth = cellSize * widthMul;

    if (cachedStroke == null ||
        cachedHistorySize != history.size() ||
        cachedSmoothIters != smoothIters) {

      List<PVector> line = (smoothIters > 0) ? chaikin(history, smoothIters) : history;

      int waves = computeWaves(grid, line);

      WidthRuleMul parentRule = new SineMul(sineAmp, waves, sineBase);
      cachedStroke = new ThickStroke(line, baseWidth, parentRule);

      if (paint) {
        float wMin = baseWidth * childWMinFrac;
        float wMax = baseWidth * childWMaxFrac;

        WidthRuleMul cr = childUsesSine
          ? new SineMul(childSineAmp, waves, childSineBase)
          : new NoiseMul(0.25, 0.02);

        cachedStroke.paintInside(childCount, wMin, wMax, childLenMin, childLenMax, cr);
      }

      cachedHistorySize = history.size();
      cachedSmoothIters = smoothIters;
    }

    cachedStroke.render(pg, agentColor);
  }

  // cycles based on physical length, not point count
  int computeWaves(Grid grid, List<PVector> line) {
    float cell = min(grid.cellWidth, grid.cellHeight);
    if (cell <= 0 || line.size() < 2) return wavesMin;

    float len = 0;
    for (int i = 1; i < line.size(); i++) {
      len += PVector.dist(line.get(i - 1), line.get(i));
    }

    float cellsTraveled = len / cell;
    int w = round(cellsTraveled * wavesPerCell);
    if (w < wavesMin) w = wavesMin;
    if (w > wavesMax) w = wavesMax;
    return w;
  }

  List<PVector> chaikin(List<PVector> pts, int iters) {
    if (pts.size() < 3) return pts;

    ArrayList<PVector> cur = new ArrayList<>(pts.size());
    for (PVector p : pts) cur.add(p.copy());

    for (int k = 0; k < iters; k++) {
      ArrayList<PVector> next = new ArrayList<>(cur.size() * 2);
      next.add(cur.get(0).copy()); // keep start

      for (int i = 0; i < cur.size() - 1; i++) {
        PVector a = cur.get(i);
        PVector b = cur.get(i + 1);
        next.add(PVector.lerp(a, b, 0.25f));
        next.add(PVector.lerp(a, b, 0.75f));
      }

      next.add(cur.get(cur.size() - 1).copy()); // keep end
      cur = next;
    }
    return cur;
  }
}
