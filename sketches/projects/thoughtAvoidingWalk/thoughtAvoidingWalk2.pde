/* //<>// //<>//
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

import java.util.*;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

int cols;
int rows;
float cellSize = 50;
float padding = 100;
Spot[][] grid;
ArrayList<Spot> path = new ArrayList<>();
Spot spot;

PFont font;
int fontHeight = 16;
float fontWidth;

color[] p = {#e3170a, #a9e5bb, #fcf6b1, #f7b32b};
int cidx = 0;

String[] lines;
char[] characters;
PGraphics squares;

void setup() {
  size(2000, 2000);
  colorMode(HSB, 360, 100, 100, 1);

  font = createFont("LexendDeca-Regular.ttf", 100);
  textFont(font);
  textSize(50);
  textAlign(CENTER, CENTER);
  textSize(calculateFontSize("A", cellSize));  

  lines = loadStrings("output.txt");
  String text = join(lines, "").toUpperCase();
  characters = text.toCharArray();

  // target usable drawing area
  float usableW = width * 0.9;
  float usableH = height * 0.9;

  // estimate grid aspect to match canvas
  float aspect = usableW / usableH;

  // --- SLACK: make the grid bigger than the text to make SAW easier ---
  float slack = 1.3; // try 1.2, 1.4, 1.8
  int gridCells = ceil(characters.length * slack);

  // compute cols/rows from slackened cell count
  cols = ceil(sqrt(gridCells * aspect));
  rows = ceil((float)gridCells / cols);

  // derive cell size from available space
  cellSize = min(
    usableW / cols,
    usableH / rows
  );

  // center grid
  padding = (width - cols * cellSize) * 0.5;

  // NOW that cellSize is final, size the font accordingly
  textSize(calculateFontSize("A", cellSize * 0.5));



  initGrid();
  solveWalk();          // now: retries until solved (or hits maxAttempts)
  addSpotAttributes();
  noLoop();
}

void draw() {
  background(0);

  for (int i = 0; i < path.size() - 1; i++) {
    Spot s = path.get(i);
    Spot ns = path.get(i + 1);
    s.display(ns);
  }

  Spot s = path.get(path.size() - 1);
  s.display(null);
  println(s.letter);
  save(getTemporalName(sketchName, saveFormat));
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));
}

/**
 * Retry wrapper: run a bounded solve. If it bails (stalled/backtracked/time),
 * reset and try again until we reach the target path length.
 */
void solveWalk() {
  int targetPathLen = min(characters.length, rows * cols); // one char per cell
  int maxAttempts = 10000;                                  // hard cap so we don't hang forever

  int attempt = 0;
  boolean ok = false;

  // optional: keep best-so-far so you can still render something if maxAttempts is hit
  ArrayList<Spot> bestPath = new ArrayList<Spot>();
  int bestLen = 0;

  while (!ok && attempt < maxAttempts) {
    attempt++;

    // vary randomness per attempt
    randomSeed((int)(System.nanoTime() ^ (attempt * 2654435761L)));

    resetGridState();
    ok = solveWalkOnce(targetPathLen);

    if (path.size() > bestLen) {
      bestLen = path.size();
      bestPath = new ArrayList<Spot>(path);
    }

    if (!ok && attempt % 50 == 0) {
      println("attempt " + attempt + " failed; bestLen=" + bestLen + " target=" + targetPathLen);
    }
  }

  if (!ok) {
    println("FAILED after " + maxAttempts + " attempts. Best achieved len=" + bestLen + " / " + targetPathLen);
    path = bestPath; // render longest found
  } else {
    println("SUCCESS in " + attempt + " attempts. len=" + path.size() + " / " + targetPathLen);
  }
}

/**
 * Single attempt: bounded backtracking + stall detection.
 * Returns true only if we reach targetPathLen.
 */
boolean solveWalkOnce(int targetPathLen) {
  int targetSteps = targetPathLen - 1;    // because path starts with the first cell already

  int maxIterations = 200000;             // hard cap on loop iterations
  int maxBacktracks = 50000;              // cap on pops
  int maxStallIterations = 20000;         // cap on iterations without growing path
  int timeLimitMs = 1500;                 // per-attempt time budget

  long start = millis();

  spot = grid[0][0];
  path.clear();
  path.add(spot);
  spot.visited = true;

  int i = 0;            // forward steps
  int iter = 0;
  int backtracks = 0;

  int bestPathSize = path.size();
  int stall = 0;

  while (i < targetSteps && iter < maxIterations) {
    iter++;

    if (millis() - start > timeLimitMs) return false;

    Spot next = spot.nextSpot();

    if (next == null) {
      if (path.size() <= 1) return false;

      Spot stuck = path.remove(path.size() - 1);
      stuck.clear();
      spot = path.get(path.size() - 1);
      i--;
      backtracks++;

      if (backtracks >= maxBacktracks) return false;
    } else {
      spot = next;
      path.add(spot);
      spot.visited = true;
      i++;
    }

    // stall/thrash detection
    if (path.size() > bestPathSize) {
      bestPathSize = path.size();
      stall = 0;
    } else {
      stall++;
      if (stall >= maxStallIterations) return false;
    }
  }

  return path.size() >= targetPathLen;
}

/**
 * Reset per-attempt state: clear visited/options everywhere.
 * (Assumes Spot.clear() resets visited + options, as in your code.)
 */
void resetGridState() {
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      grid[c][r].clear(); // keep your existing indexing convention
    }
  }
  path.clear();
  spot = null;
}

void initGrid() {
  grid = new Spot[rows][cols];
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      grid[c][r] = new Spot(r, c);
    }
  }
}

void addSpotAttributes() {
  // IMPORTANT: if we ever fail and keep bestPath, path.size() may be < characters.length
  int usableLen = min(path.size(), characters.length);
  int cidx = 0;

  for (int i = 0; i < usableLen - 1; i++) {
    Spot s = path.get(i);
    Spot nspot = path.get(i + 1);
    PVector pv = PVector.sub(nspot.realPos, s.realPos);

    s.letter = characters[i];
    s.clr = p[cidx];
    s.dir = pv.copy().setMag(cellSize/2.2);
    s.connector = pv.copy().setMag(cellSize/1.6).add(s.realPos).add(cellSize/2, cellSize/2);

    if (i < usableLen - 2) {
      Spot nnspot = path.get(i + 2);
      nspot.fromDir = PVector.sub(nspot.realPos, nnspot.realPos).setMag(cellSize/4);
    }

    // guard i+1 access
    if (i + 1 < characters.length && characters[i + 1] == ' ') cidx++;
    if (cidx >= p.length) cidx = 0;
  }

  Spot last = path.get(usableLen - 1);
  last.letter = characters[usableLen - 1];
  last.clr = p[cidx];
}

String getTemporalName(String prefix, String suffix){
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if(lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}

float calculateFontSize(String letter, float targetSize) {
  float currentFontSize = 1;
  float currentWidth = 0;

  while (true) {
    textSize(currentFontSize);
    currentWidth = textWidth(letter);

    if (currentWidth >= targetSize) {
      break;
    }
    currentFontSize++;
  }

  return currentFontSize;
}


PVector measureChar(char ch) {
  float w = textWidth(ch);
  float h = textAscent() + textDescent();
  return new PVector(w, h);
}
