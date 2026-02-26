/*
SketchName: rectanglePackShader.pde
Credits: chatgpt don't tell anyone
Description: bin packing by ratio, CPU packing (outer + nested), fragment shader draws rect list

PATCH GOAL (MINIMAL):
- Without changing shader/uniforms, allow deeper nesting so squares can get smaller.
- Keep existing packGreedy() and shader payload format.
- Conserve uniform payload (RMAX) by reducing outer K and per-parent sends.

Changes:
1) Add a simple recursive emitter (emitSquareRecursive) that reuses packGreedy at every depth.
2) Switch nested size quantization from round(...) to floor(...) inside packGreedy for earlier small sizes.
3) Reduce K and NEST_MAX_SEND_PER_PARENT to preserve RMAX headroom for deeper nesting.
*/

String sketchName = "rectanglePackShader";
String saveFormat = ".png";

int calls = 0;
long lastTime;

PShader sh;

// ---- config ----
int GRID_N = 40;

// outer packing
int K = 100;              // PATCH: was 100; leaves payload for deeper nesting
int MAX_TRIALS = 1000;
int TRIES_PER_SQUARE = 50;

// nested packing
int NEST_K = 60;
int NEST_TRIES_PER_SQUARE = 40;
int NEST_MAX_SEND_PER_PARENT = 4;   // PATCH: was 10; leaves payload for deeper nesting
int MIN_PARENT_S = 3;               // PATCH: was 1; recursion only when it can actually subdivide

// PATCH: recursion depth cap (0 = only outer)
int MAX_DEPTH = 5;

float marginPx = 80;

float[] ratios = { 1f/3f, 1f/6f, 1f/9f };

// ---- GPU payload (rect list) ----
// rect = (xCell, yCell, sideCells, depth)
static final int RMAX = 128;          // keep <=128 to avoid uniform limit
int u_rect_count = 0;
int[] u_rect_flat = new int[RMAX * 4];

void setup() {
  size(800, 800, P2D);
  noStroke();

  sh = loadShader("shader.frag");
  regenerate();
}

void draw() {
  sh.set("u_resolution", (float)width, (float)height);
  sh.set("u_time", millis() / 1000.0f);

  sh.set("u_gridN", GRID_N);
  sh.set("u_margin_px", marginPx);

  // SEND RECT LIST (matches shader)
  sh.set("u_rect_count", u_rect_count);
  sh.set("u_rect_flat", u_rect_flat);

  shader(sh);
  rect(0, 0, width, height);
  resetShader();
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveFrame(getTemporalName(sketchName, saveFormat));
  } else {
    regenerate();
  }
}

// ---- packing + upload ----

void regenerate() {
  // Find best outer packing by max covered area (cells filled)
  PackResult best = null;
  int bestScore = -1;

  int[] sizes = new int[K];
  int[] rid   = new int[K];
  for (int i = 0; i < K; i++) {
    int rIndex = i % ratios.length;
    float r = ratios[rIndex];
    int s = max(1, (int)round(GRID_N * sqrt(r)));
    sizes[i] = s;
    rid[i] = rIndex;
  }

  int[] order = sortIndicesBySizeDesc(sizes);

  for (int trial = 0; trial < MAX_TRIALS; trial++) {
    boolean[][] occ = new boolean[GRID_N][GRID_N];
    Square[] placed = new Square[K];

    for (int oi = 0; oi < K; oi++) {
      int idx = order[oi];
      int s = sizes[idx];
      if (s > GRID_N) continue;

      boolean ok = false;
      int px = 0, py = 0;

      for (int t = 0; t < TRIES_PER_SQUARE; t++) {
        int x = (int)random(0, GRID_N - s + 1);
        int y = (int)random(0, GRID_N - s + 1);
        if (canPlace(occ, x, y, s)) {
          stamp(occ, x, y, s);
          px = x; py = y;
          ok = true;
          break;
        }
      }

      if (ok) placed[idx] = new Square(px, py, s, rid[idx]);
    }

    int score = countOccupied(occ, GRID_N);
    if (score > bestScore) {
      bestScore = score;
      best = new PackResult(placed);
      if (bestScore == GRID_N * GRID_N) break;
    }
  }

  // Build payload: outer + recursive nested children
  u_rect_count = 0;
  for (int i = 0; i < u_rect_flat.length; i++) u_rect_flat[i] = 0;

  if (best == null) return;

  // Emit each placed outer square and recurse inside it.
  // NOTE: u_rect_count / RMAX is now the global limiter.
  for (int i = 0; i < K; i++) {
    Square parent = best.placed[i];
    if (parent == null) continue;

    emitSquareRecursive(parent.x, parent.y, parent.s, 0);

    if (u_rect_count >= RMAX) break;
  }

  println("rect_count=" + u_rect_count);
}

// PATCH: recursive nesting using existing greedy packer
void emitSquareRecursive(int gx, int gy, int s, int depth) {
  if (u_rect_count >= RMAX) return;

  // push this square
  pushRect(gx, gy, s, depth);
  if (u_rect_count >= RMAX) return;

  // stop
  if (depth >= MAX_DEPTH) return;
  if (s < MIN_PARENT_S) return;

  // pack kids inside local s×s region
  Square[] kids = packGreedy(s, NEST_K, NEST_TRIES_PER_SQUARE);

  // Prefer larger kids first (gives more opportunity for further nesting)
  int[] kidSizes = new int[kids.length];
  for (int i = 0; i < kids.length; i++) kidSizes[i] = (kids[i] == null) ? -1 : kids[i].s;
  int[] order = sortIndicesBySizeDesc(kidSizes);

  int sent = 0;
  for (int oi = 0; oi < order.length; oi++) {
    if (sent >= NEST_MAX_SEND_PER_PARENT) break;
    Square c = kids[order[oi]];
    if (c == null) continue;

    int cx = gx + c.x;
    int cy = gy + c.y;

    // containment guard
    if (cx + c.s > gx + s) continue;
    if (cy + c.s > gy + s) continue;

    emitSquareRecursive(cx, cy, c.s, depth + 1);
    sent++;

    if (u_rect_count >= RMAX) return;
  }
}

void pushRect(int x, int y, int s, int depth) {
  if (u_rect_count >= RMAX) return;
  int base = u_rect_count * 4;
  u_rect_flat[base + 0] = x;
  u_rect_flat[base + 1] = y;
  u_rect_flat[base + 2] = s;
  u_rect_flat[base + 3] = depth;
  u_rect_count++;
}

// ---- nested greedy packer ----
Square[] packGreedy(int N, int Klocal, int triesPerSquare) {
  boolean[][] occ = new boolean[N][N];
  Square[] placed = new Square[Klocal];

  int[] sizes = new int[Klocal];
  int[] rid   = new int[Klocal];

  for (int i = 0; i < Klocal; i++) {
    int rIndex = i % ratios.length;
    float r = ratios[rIndex];

    // PATCH: floor instead of round so small regions produce smaller children sooner
    int s = max(1, (int)floor(N * sqrt(r)));

    sizes[i] = s;
    rid[i] = rIndex;
  }

  int[] order = sortIndicesBySizeDesc(sizes);

  for (int oi = 0; oi < Klocal; oi++) {
    int idx = order[oi];
    int s = sizes[idx];
    if (s > N) continue;

    boolean ok = false;
    int px = 0, py = 0;

    for (int t = 0; t < triesPerSquare; t++) {
      int x = (int)random(0, N - s + 1);
      int y = (int)random(0, N - s + 1);
      if (canPlace(occ, x, y, s)) {
        stamp(occ, x, y, s);
        px = x; py = y;
        ok = true;
        break;
      }
    }

    if (ok) placed[idx] = new Square(px, py, s, rid[idx]);
  }

  return placed;
}

// ---- occupancy helpers ----
boolean canPlace(boolean[][] occ, int x0, int y0, int s) {
  for (int y = y0; y < y0 + s; y++) {
    for (int x = x0; x < x0 + s; x++) {
      if (occ[x][y]) return false;
    }
  }
  return true;
}

void stamp(boolean[][] occ, int x0, int y0, int s) {
  for (int y = y0; y < y0 + s; y++) {
    for (int x = x0; x < x0 + s; x++) {
      occ[x][y] = true;
    }
  }
}

int countOccupied(boolean[][] occ, int N) {
  int c = 0;
  for (int y = 0; y < N; y++) {
    for (int x = 0; x < N; x++) {
      if (occ[x][y]) c++;
    }
  }
  return c;
}

int[] sortIndicesBySizeDesc(int[] sizes) {
  int n = sizes.length;
  int[] idx = new int[n];
  for (int i = 0; i < n; i++) idx[i] = i;

  for (int i = 0; i < n; i++) {
    int best = i;
    for (int j = i + 1; j < n; j++) {
      if (sizes[idx[j]] > sizes[idx[best]]) best = j;
    }
    int tmp = idx[i];
    idx[i] = idx[best];
    idx[best] = tmp;
  }
  return idx;
}

// ---- data types ----
class Square {
  int x, y, s, rid;
  Square(int x, int y, int s, int rid) {
    this.x = x; this.y = y; this.s = s; this.rid = rid;
  }
}

class PackResult {
  Square[] placed;
  PackResult(Square[] placed) { this.placed = placed; }
}

String getTemporalName(String prefix, String suffix){
  long time = System.currentTimeMillis();
  if(lastTime == time) calls++;
  else { lastTime = time; calls = 0; }
  return prefix + time + (calls>0 ? "-" + calls : "") + suffix;
}
