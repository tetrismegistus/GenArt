abstract class FlowField {
  int leftX, topY;
  int cols, rows;
  int resolution;
  float[][] field;

  color drawColor = color(0);   // default black

  FlowField(int w, int h, float under, float over, float scale) {
    leftX = int(w * under);
    int rightX = int(w * over);
    topY = int(h * under);
    int bottomY = int(h * over);

    // clamp to avoid resolution==0 when scale is tiny
    resolution = max(1, int(w * scale));

    cols = max(2, (rightX - leftX) / resolution);
    rows = max(2, (bottomY - topY) / resolution);

    field = new float[cols][rows];
  }

  void setColor(color c) {
    drawColor = c;
  }

  abstract void generate();

  // Bilinear interpolation over the field grid (smooth angles).
  float getAngle(float x, float y) {
    float gx = (x - leftX) / (float)resolution;
    float gy = (y - topY)  / (float)resolution;

    // clamp to valid cell range (need x0+1, y0+1)
    gx = constrain(gx, 0, cols - 1.001f);
    gy = constrain(gy, 0, rows - 1.001f);

    int x0 = floor(gx);
    int y0 = floor(gy);
    int x1 = min(x0 + 1, cols - 1);
    int y1 = min(y0 + 1, rows - 1);

    float tx = gx - x0;
    float ty = gy - y0;

    float a00 = field[x0][y0];
    float a10 = field[x1][y0];
    float a01 = field[x0][y1];
    float a11 = field[x1][y1];

    // IMPORTANT: angles wrap; but for typical flowfields in [-PI..PI] this is usually fine.
    // If you see discontinuities, switch to vector interpolation (cos/sin blend).
    float ax0 = lerp(a00, a10, tx);
    float ax1 = lerp(a01, a11, tx);
    return lerp(ax0, ax1, ty);
  }
}


class LinearGradientField extends FlowField {
  LinearGradientField(int w,int h,float u,float o,float s){
    super(w,h,u,o,s);
    generate();
  }

  void generate() {
    for (int c=0;c<cols;c++){
      for (int r=0;r<rows;r++){
        field[c][r] = (r / float(rows)) * PI;
      }
    }
  }
}

class LinearGradientField2 extends FlowField {
  LinearGradientField2(int w,int h,float u,float o,float s){
    super(w,h,u,o,s);
    generate();
  }

  void generate() {
    for (int c=0;c<cols;c++){
      for (int r=0;r<rows;r++){
        field[c][r] = (c / float(cols)) * HALF_PI;
      }
    }
  }
}


class RadialField extends FlowField {
  float cx, cy;

  RadialField(int w,int h,float u,float o,float s){
    super(w,h,u,o,s);
    cx = w * 0.5;
    cy = h * 0.5;
    generate();
  }

  void generate() {
    for (int c=0;c<cols;c++){
      for (int r=0;r<rows;r++){
        float x = leftX + c * resolution;
        float y = topY + r * resolution;
  
        float a = atan2(y - cy, x - cx);
  
        // tangential direction => circles / curves
        field[c][r] = a + HALF_PI;   // use -HALF_PI to reverse direction
      }
    }
  }
}


class NoiseField extends FlowField {
  float scale;
  float zoff;
  float angleMult;

  NoiseField(int w, int h, float under, float over, float resScale,
             float scale, float angleMult) {

    super(w, h, under, over, resScale);

    this.scale = scale;
    this.angleMult = angleMult;
    this.zoff = random(99999);

    generate();   // <-- NOW correct
  }

  void generate() {
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        float x = leftX + c * resolution;
        float y = topY + r * resolution;
        float n = noise(x * scale, y * scale);
        field[c][r] = n * angleMult;
      }
    }
  }
}
