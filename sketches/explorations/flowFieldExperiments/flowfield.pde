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

    resolution = int(w * scale);

    cols = (rightX - leftX) / resolution;
    rows = (bottomY - topY) / resolution;

    field = new float[cols][rows];
  }

  void setColor(color c) {
    drawColor = c;
  }

  abstract void generate();

  float getAngle(float x, float y) {
    int c = int((x - leftX) / resolution);
    int r = int((y - topY) / resolution);
    c = constrain(c, 0, cols - 1);
    r = constrain(r, 0, rows - 1);
    return field[c][r];
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
        field[c][r] = (c / float(cols)) * PI;
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
        field[c][r] = atan2(y - cy, x - cx);
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
