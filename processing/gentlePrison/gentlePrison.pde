import com.krab.lazy.*;
import java.util.Random;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

LazyGui gui;
ArrayList<Board> boards = new ArrayList<Board>();
PGraphics accumBuffer;
boolean accumulationEnabled = false;

final ColorPalette PAL_A = new ColorPalette(new color[]{#D64045, #1D3354});
final ColorPalette PAL_B = new ColorPalette(new color[]{#9ED8DB, #467599});
final color BACKGROUND_COLOR = #E9FFF9;

final float DEFAULT_TILE_SIZE = 15;
final int SOLID_FILL = 0;
final int NOISE_FILL = 1;
final int THREAD_FILL = 2;

boolean useNoiseForPalette = true;
int OCTAVES = 8;
float PERSISTENCE = 0.5f;
int MAX_TILE_WIDTH = 40;
int MAX_TILE_HEIGHT = 40;
int MIN_TILE_WIDTH = 10;
int MIN_TILE_HEIGHT = 10;
int DEFAULT_MAX_DEPTH = 0;
float FILL_THRESHOLD = 0;
float PADDING = 0.01;
float NOISE_SCALE = 0.1;
float STROKEWEIGHT = 1;
float jitterAmt = 5;
final int COMBO_FILL = 3;

PGraphics outputBuffer;
OpenSimplexNoise oNoise;

int outputWidth = 4000;
int outputHeight = 4000;
int previewWidth = 1000;
int previewHeight = 1000;
float padX, padY;
int rows, cols;

String[] renderModes = {"Solid Fill", "Noise Fill", "Thread Fill"};
String selectedMode = "Solid Fill"; // Default selection

void setup() {
  colorMode(HSB, 360, 100, 100, 1);
  size(1000, 1000, P3D);
  smooth(8);
  gui = new LazyGui(this);
  accumBuffer = createGraphics(outputWidth, outputHeight, P2D);
  accumBuffer.beginDraw();
  accumBuffer.colorMode(HSB, 360, 100, 100, 1);
  accumBuffer.blendMode(SCREEN);
  accumBuffer.endDraw();
  float marginRatio = 0.05;
  padX = outputWidth * marginRatio;
  padY = outputHeight * marginRatio;
  rows = (int) ((outputWidth - padX * 2) / DEFAULT_TILE_SIZE);
  cols = (int) ((outputHeight - padY * 2) / DEFAULT_TILE_SIZE);

  genBoard();
}

void draw() {
  background(BACKGROUND_COLOR);

  useNoiseForPalette = gui.toggle("Use Noise for Palette", useNoiseForPalette);
  NOISE_SCALE = gui.slider("NOISE_SCALE", NOISE_SCALE, 0.01, 1.0);
  FILL_THRESHOLD = gui.slider("FILL_THRESHOLD", FILL_THRESHOLD, -1.0, 1.0);
  OCTAVES = gui.sliderInt("OCTAVES", OCTAVES, 1, 10);
  PERSISTENCE = gui.slider("PERSISTENCE", PERSISTENCE, 0.1, 1.0);
  PADDING = gui.slider("PADDING", PADDING, 0, 0.45);
  STROKEWEIGHT = gui.slider("STROKEWEIGHT", STROKEWEIGHT, 0, 10);
  DEFAULT_MAX_DEPTH = gui.sliderInt("MAX_DEPTH", DEFAULT_MAX_DEPTH, 0, 3);
  MAX_TILE_WIDTH = gui.sliderInt("MAX_TILE_WIDTH", MIN_TILE_WIDTH + 1, 2, 200);
  MAX_TILE_HEIGHT = gui.sliderInt("MAX_TILE_HEIGHT", MIN_TILE_HEIGHT + 1, 2, 200);
  MIN_TILE_WIDTH = gui.sliderInt("MIN_TILE_WIDTH", MIN_TILE_WIDTH, 1, MAX_TILE_WIDTH - 1);
  MIN_TILE_HEIGHT = gui.sliderInt("MIN_TILE_HEIGHT", MIN_TILE_HEIGHT, 1, MAX_TILE_HEIGHT - 1);
  jitterAmt = gui.slider("jitter", jitterAmt, 0.1, 10);

  selectedMode = gui.radio("Render Mode", renderModes, selectedMode);

  if (gui.button("Save Selected Variant")) {
    saveVariant(selectedMode);
  }

  if (gui.button("rerender")) {
    genBoard();
  }
  
  if (gui.button("Accumulate Thread Layer")) {
  accumulateThreads();
}

if (gui.button("Clear Accumulated Threads")) {
  clearAccumBuffer();
}

if (gui.button("Save Accumulated Threads")) {
  accumBuffer.save(sketchName + "_accumulated_threads" + saveFormat);
}


  image(outputBuffer, 0, 0, previewWidth, previewHeight);

  text("Selected render mode: " + selectedMode, 10, height - 20);
}

void genBoard() {
  Random rand = new Random();
  long randomLongValue = rand.nextLong();
  oNoise = new OpenSimplexNoise(randomLongValue);
  boards.clear();

  Board b = new Board(padX, padY, cols, rows, DEFAULT_TILE_SIZE, PAL_A, PAL_B, 0, DEFAULT_MAX_DEPTH);
  b.fillBoard();            // ← this is key
  boards.add(b);

  outputBuffer = renderBoardToBuffer(PADDING, SOLID_FILL);
}

void saveVariant(String mode) {
  PGraphics pg;

  if (mode.equals("Thread Fill")) {
    pg = renderThreadVariant(boards.get(0), PADDING, 3); 
  } else if (mode.equals("Noise Fill")) {
    pg = renderBoardToBuffer(PADDING, NOISE_FILL);
  } else {
    pg = renderBoardToBuffer(PADDING, SOLID_FILL);
  }
  pg.save(getTemporalName(sketchName, saveFormat));
  String fileName = getTemporalName(sketchName, saveFormat);
  pg.save(mode.toLowerCase().replace(" ", "_") + fileName);
}

PGraphics renderBoardToBuffer(float padding, int fillMode) {
  PGraphics pg = createGraphics(outputWidth, outputHeight, P2D);
  pg.beginDraw();
  pg.clear();
  pg.colorMode(HSB, 360, 100, 100, 1);
  pg.strokeWeight(STROKEWEIGHT);
  pg.ellipseMode(CENTER);
  pg.background(BACKGROUND_COLOR);

  for (Board board : boards) {
    board.render(pg, padding, fillMode);
  }

  pg.endDraw();
  return pg;
}

PGraphics renderThreadVariant(Board board, float padding, int passes) {
  PGraphics pg = createGraphics(outputWidth, outputHeight, P2D);
  pg.beginDraw();
  pg.clear();
  pg.colorMode(HSB, 360, 100, 100, 1);
  pg.strokeWeight(STROKEWEIGHT);
  pg.ellipseMode(CENTER);

  // Step 1: Fill entire canvas background
  pg.background(BACKGROUND_COLOR);

  // Step 2: Draw a threadbox spanning the board area
  float gridWidth = board.cols * board.tileSize;
  float gridHeight = board.rows * board.tileSize;
  

  // Step 3: Render all tiles multiple times for thread texture effect
  for (int i = 0; i < passes; i++) {
    threadbox(pg, board.x, board.y, gridWidth, gridHeight, 0, 2, #000000);  // black threadbox
    board.render(pg, padding, THREAD_FILL);
  }

  pg.endDraw();
  return pg;
}

void keyReleased() {
  if (key == 's' || key == 'S') {
    outputBuffer.save(getTemporalName(sketchName, saveFormat));
  }
}

String getTemporalName(String prefix, String suffix) {
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}

void accumulateThreads() {
  accumBuffer.beginDraw();
  accumBuffer.colorMode(HSB, 360, 100, 100, 1);
  accumBuffer.strokeWeight(STROKEWEIGHT);
  accumBuffer.ellipseMode(CENTER);
  accumBuffer.blendMode(SUBTRACT); // or ADD for glow

  // Add a thread layer (could be more complex!)
  for (Board board : boards) {
    board.render(accumBuffer, PADDING, THREAD_FILL);
  }

  accumBuffer.endDraw();
}

void clearAccumBuffer() {
  accumBuffer.beginDraw();
  accumBuffer.clear();  // transparent
  accumBuffer.endDraw();
}
