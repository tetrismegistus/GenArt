OpenSimplexNoise noise = new OpenSimplexNoise();
float uoff = 0;
float voff = 0;
float yoff = 0;
int totalFrames = 1000;
int counter = 0;
boolean record = false;

int cols, rows;
int scl = 15;
int w = 1200;
int h = 900;
float flying = 0;

float zrot = 0;

float[][] terrain;



void setup() {
  size(600, 600, P3D);
  colorMode(HSB, 360, 100, 100, 1);
  cols = w / scl;
  rows = h / scl;

  terrain = new float[cols][rows];
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map((float) noise.eval(xoff, yoff, uoff, voff), -1, 1, -25, 25);
      xoff += 0.01;
    }
    yoff +=  0.01;
  }
}

void draw() {
  float percent = 0;
  if (record) {
    percent = float(counter) / totalFrames;
  } else {
    percent = float(counter % totalFrames) / totalFrames;
  }
  render(percent);
  if (record) {
    saveFrame("frames/gif-"+nf(counter, 3)+".png");
    if (counter == totalFrames-1) {
      exit();
    }
  }
  counter++;
}

void render(float percent) {  
  float angle = map(percent, 0, 1, 0, TWO_PI * 2);
  uoff = map(cos(angle), -1, 1, 0, 1);
  voff = map(sin(angle), -1, 1, 0, 1);
  yoff = map(sin(angle), -1, 1, 0, 1);

  background(#F3C3D9);
  //noStroke();
  //noFill();




  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map((float) noise.eval(xoff, yoff, uoff, voff), -1, 1, -scl*4, scl*4);
      xoff += 0.1;
    }
    yoff +=  0.15;
  }

  translate(width/2, height/2);
  rotateX(PI/3);
  rotateZ(zrot);
  zrot += .001;
  translate(-w/2, -h/2);

  for (int y = 0; y < rows - 1; y++) {
    //beginShape(QUAD_STRIP);
    for (int x = 0; x < cols; x++) {

      float z = terrain[x][y];
      float c = map(z, -scl*4, scl*4, 0, 360);
      fill(c, 100, 100);
      pushMatrix();
      translate(x*scl, y*scl, z);
      box(scl);
      popMatrix();
      //vertex(x*scl, (y+1)*scl, terrain[x][y + 1]);
    }
    //endShape();
  }
}
