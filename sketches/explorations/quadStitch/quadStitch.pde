String sketchName = "mySketch";
String saveFormat = ".png";
int calls = 0;
long lastTime;

// ---- configuration ----
String[] files = { "1.png", "2.png", "3.png", "4.png" };

int gridCols = 2;
int gridRows = 2;

int gutter = 100;   // space BETWEEN tiles
int outer  = 100;   // space AROUND the grid

PImage[] imgs = new PImage[4];
PGraphics stitched;

int tileSize;

void settings() {
  // preview window only (not the final stitched size)
  size(2000, 2000, P2D);
}

void setup() {
  // ---- load images ----
  for (int i = 0; i < files.length; i++) {
    imgs[i] = loadImage(files[i]);
    if (imgs[i] == null) {
      println("Failed to load: " + files[i]);
      exit();
    }
  }

  // ---- validate square + uniform ----
  tileSize = imgs[0].width;

  for (int i = 0; i < imgs.length; i++) {
    if (imgs[i].width == 0 || imgs[i].height == 0) {
      println("Image has zero dimensions (bad load?): " + files[i]);
      exit();
    }
    if (imgs[i].width != imgs[i].height) {
      println("Image not square: " + files[i] + " (" + imgs[i].width + "x" + imgs[i].height + ")");
      exit();
    }
    if (imgs[i].width != tileSize) {
      println("Image size mismatch: " + files[i] + " expected " + tileSize + " got " + imgs[i].width);
      exit();
    }
  }

  // ---- build offscreen canvas ----
  int canvasW = outer * 2 + gridCols * tileSize + (gridCols - 1) * gutter;
  int canvasH = outer * 2 + gridRows * tileSize + (gridRows - 1) * gutter;

  stitched = createGraphics(canvasW, canvasH, P2D);

  // render once
  renderStitched();
}

void draw() {
  background(#EFEDE8);

  // preview: fit stitched image into window (letterboxed)
  float sx = (float) width  / stitched.width;
  float sy = (float) height / stitched.height;
  float s = min(sx, sy);

  float dw = stitched.width * s;
  float dh = stitched.height * s;
  float dx = (width  - dw) * 0.5;
  float dy = (height - dh) * 0.5;

  image(stitched, dx, dy, dw, dh);
}

void renderStitched() {
  stitched.beginDraw();
  
  stitched.background(#EFEDE8);

  for (int i = 0; i < imgs.length; i++) {
    int col = i % gridCols;
    int row = i / gridCols;

    int x = outer + col * (tileSize + gutter);
    int y = outer + row * (tileSize + gutter);

    stitched.image(imgs[i], x, y, tileSize, tileSize);
  }

  stitched.endDraw();
}

void keyReleased() {
  if (key == 's' || key == 'S') {
    stitched.save(getTemporalName(sketchName, saveFormat));
  }
}

String getTemporalName(String prefix, String suffix) {
  long time = System.currentTimeMillis();
  if (lastTime == time) calls++;
  else { lastTime = time; calls = 0; }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}
