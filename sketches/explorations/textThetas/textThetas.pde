/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/
import processing.svg.*;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float[][] grid;
float[][] averages2;
int left_x;
int right_x; 
int top_y; 
int bottom_y;
int resolution, num_columns, num_rows;
char[] characters;
PFont font;

color[] p = {#2B2D42, #8D99AE, #EF233C, #D80032};


void setup() {
  size(1500, 1500);
  colorMode(HSB, 360, 100, 100, 1);
  font = createFont("LibreBaskerville-VariableFont_wght.ttf", 48);
  
  
  textFont(font);
  left_x = 100;
  right_x = width - 100; 
  top_y = 100; 
  bottom_y = height - 100;
  resolution = int(width * 0.0015); 
  num_columns = (right_x - left_x) / resolution; 
  num_rows = (bottom_y - top_y) / resolution;
  
  grid = new float[num_columns][num_rows];
  
  
  String[] lines = loadStrings("poem.txt");
  String text = join(lines, "\n");
  characters = text.toCharArray(); // Convert the string to a char arr

  // Build thetas from printable chars
  ArrayList<Float> thetas = new ArrayList<Float>();
  for (char c : characters) {
    if (c > 32 && c < 127) {
      thetas.add(map(c, 32, 126, 1, 2 * TWO_PI));
    }
  }

  int n = thetas.size();

  int cidx = 0;
  for (int x = 0; x < num_columns; x++) {
    for (int y = 0; y < num_rows; y++) {

      grid[x][y] = thetas.get(cidx % n);   // cycle
      cidx++;
 
    }
  }

  for (int i = 0; i < 10; i++) {
    //grid = averageField(grid);
  }

  
}





float[][] averageField(float[][] grid) {
  float[][] averages;
  averages = new float[grid.length][grid[0].length];  
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[i].length; j++) {
        float sum = grid[i][j];
        int count = 1;
        for (int k = i - 1; k <= i + 1; k++) {
            for (int l = j - 1; l <= j + 1; l++) {
                if (k >= 0 && k < grid.length && l >= 0 && l < grid[k].length && (k != i || l != j)) {
                    sum += grid[k][l];
                    count++;
                }
            }
        }
        averages[i][j] = sum / count;
    }
  }
  return averages;
}


void draw() {

  background(#FCF5E5);
  int numCircles = int((width * height / 1000000.0) * 10000);
  parchmentTexture(numCircles);

  float margin = 100;
  float x0Base = margin;
  float x1 = width  - margin;
  float y1 = height - margin;

  float rowStep = 45;

  float spaceW      = textWidth(" ");
  float step_length = spaceW * 2;
  float wordGapBase = spaceW;
  float wordGapJit  = 2.0;            // draw-pass only
  float wordGapLayout = wordGapBase;  // deterministic for measuring

  float trackMin  = 0.5;
  float trackFrac = 0.10;

  float jitterAmp = 0.75;             // draw-pass only
  float safetyPad = 0.5;

  // ---------- PASS 1: compute line breaks + widths ----------
  ArrayList<Integer> lineStarts = new ArrayList<Integer>();
  ArrayList<Integer> lineEnds   = new ArrayList<Integer>();  // exclusive
  ArrayList<Float>   lineWidths = new ArrayList<Float>();

  int idx = 0;
  int n = characters.length;

  lineStarts.add(0);

  float x = x0Base;
  float currentWidth = 0;

  while (idx < n) {
    char ch = characters[idx];

    if (ch == '\r') { idx++; continue; }

    if (ch == '\n') {
      lineEnds.add(idx);
      lineWidths.add(currentWidth);

      idx++; // consume newline

      lineStarts.add(idx);
      x = x0Base;
      currentWidth = 0;
      continue;
    }

    if (ch == '\t') ch = ' ';

    if (ch == ' ') {
      // ignore leading spaces
      if (currentWidth == 0) { idx++; continue; }

      float adv = wordGapLayout;

      // wrap on space if it would push us over
      if (x + adv > x1) {
        lineEnds.add(idx);
        lineWidths.add(currentWidth);

        idx++; // eat the space so we don't loop
        lineStarts.add(idx);
        x = x0Base;
        currentWidth = 0;
        continue;
      }

      x += adv;
      currentWidth += adv;
      idx++;
      continue;
    }

    String s = str(ch);
    float w = textWidth(s);
    float tracking = max(trackMin, w * trackFrac);
    float adv = w + tracking;

    // wrap before this char
    if ((x + w + safetyPad) > x1) {
      lineEnds.add(idx);
      lineWidths.add(currentWidth);

      lineStarts.add(idx); // start new line at same char
      x = x0Base;
      currentWidth = 0;
      continue;
    }

    x += adv;
    currentWidth += adv;
    idx++;
  }

  // finalize last line
  if (lineEnds.size() < lineStarts.size()) {
    lineEnds.add(n);
    lineWidths.add(currentWidth);
  }

  int lineCount = lineWidths.size();
  if (lineCount == 0) {
    save("out/" + getTemporalName(sketchName, saveFormat));
    noLoop();
    return;
  }

  // ---------- compute intelligent y0 (vertical centering) ----------
  float blockHeight = max(0, (lineCount - 1)) * rowStep;
  float usableTop = margin;
  float usableBottom = height - margin;

  float y0 = (usableTop + usableBottom - blockHeight) * 0.5;
  y0 = constrain(y0, usableTop, usableBottom);

  // ---------- compute shared xStart for the whole block ----------
  float usableW = (x1 - x0Base);

  // Use an 80th-percentile width so one long line doesn't dominate
  float[] ws = new float[lineCount];
  for (int li = 0; li < lineCount; li++) ws[li] = lineWidths.get(li);
  java.util.Arrays.sort(ws);
  float blockW = ws[(int)constrain(floor(0.80 * (lineCount - 1)), 0, lineCount - 1)];

  // 0.5 = centered; lower biases left but keeps "center-ish" composition
  float bias = 0.35;
  float blockLeft = x0Base + max(0, (usableW - blockW) * bias);

  // ---------- PASS 2: draw ----------
  int cidx = 0; // not used for indexing now, but kept as a local if you expand later
  color c = p[(int)random(p.length)];

  for (int li = 0; li < lineCount; li++) {
    float y = y0 + li * rowStep;
    if (y > y1) break;

    float xStart = blockLeft;
    float cx = xStart;

    int start = lineStarts.get(li);
    int end   = lineEnds.get(li);

    for (int i = start; i < end; i++) {
      char ch = characters[i];
      if (ch == '\r') continue;
      if (ch == '\t') ch = ' ';

      if (ch == ' ') {
        if (cx == xStart) continue; // ignore leading spaces visually
        c = p[(int)random(p.length)];
        cx += wordGapBase + random(-wordGapJit, wordGapJit);
        continue;
      }

      String s = str(ch);
      float w = textWidth(s);
      float tracking = max(trackMin, w * trackFrac);

      float worstRightEdge = cx + w + jitterAmp + safetyPad;
      if (worstRightEdge > x1) break;

      float jitterX = random(-jitterAmp, jitterAmp);
      float jitterY = random(-jitterAmp, jitterAmp);

      stroke(c);
      fill(c);
      text(s, cx + jitterX, y + jitterY);

      if (random(1) > 0.95) {
        int cap = int(random(1, 15));
        fill(c, .5);
        drawFlowText(cap, cx + jitterX, y + jitterY, step_length, ch);
      }

      cx += w + tracking;
    }
  }

  save("out/" + getTemporalName(sketchName, saveFormat));
  noLoop();
}



void drawFlowText(int cap, float x, float y, float step_length, char displayChar) {


  for (int i = 0; i < cap; i++) {

    // bail out once we leave the field bounds
    if (x < left_x || x > right_x || y < top_y || y > bottom_y) break;

    text(displayChar, x, y);

    float x_offset = x - left_x;
    float y_offset = y - top_y;
    int column_index = int(x_offset / resolution);
    int row_index    = int(y_offset / resolution);

    // optional now, but still fine to keep
    row_index = constrain(row_index, 0, num_rows - 1);
    column_index = constrain(column_index, 0, num_columns - 1);

    float t = grid[column_index][row_index];
    x -= step_length * cos(t);
    y -= step_length * sin(t);
  }
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
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


void parchmentTexture(int numCircles) {
  noFill();
  strokeWeight(.5);
  stroke(0, 0, 0, .02);
  float radBase = 200;
  float curveSpread = 100;
  for (int i = 0; i < numCircles; i++) {
    float x = random(width + radBase);
    float y = random(height + radBase);
    float rad = randomGaussian() * curveSpread + radBase;
    circle(x, y, rad);
  }
}
