float xmin = -.25;
float xmax = .25;

float ymin = -1;
float ymax = -.5;

float rangex = xmax - xmin;
float rangey = ymax - ymin;

float xscl, yscl;

void setup() {
    
    size(600, 600);
    //noStroke();
    xscl = rangex/width;
    yscl = rangey/height;
    colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
  float[] z = new float[2];
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      z[0] = xmin + x * xscl;
      z[1] = ymin + y * yscl;
      float col = mandelbrot(z, 100);
      if (col == 100.) {
        stroke(0);
      } else {
        stroke(360 - 15  * col, 255, 255);
      }
      point(x, y);
      
    }
  }
}
        

int mandelbrot(float[] z, int num) {
  int count = 0;
  float[] z1 = z;
  while (count < num) {
    if (magnitude(z1) > 2.0) {
      return count;
    }
    z1 = cAdd(cMult(z1, z1), z);
    count += 1;
  }
  return num; 
}


float[] cAdd(float[] a, float[] b) {
  float[] s = {a[0] + b[0], a[1] + b[1]};
  return s;
}


float[] cMult(float[] u, float[] v) {
  float[] p = {u[0] * v[0] - u[1] * v[1],
               u[1] * v[0] + u[0] * v[1]};
  return p;
}


float magnitude(float[] z) {
  return sqrt(pow(z[0], 2) + pow(z[1],2));
}
