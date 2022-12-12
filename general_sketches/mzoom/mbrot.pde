int calls = 0;
long lastTime;

double xmin = -1;
double xmax = 1;

double ymin = -1;
double ymax = 1;

double rangex = xmax - xmin;
double rangey = ymax - ymin;

double xcenter = 0.2785846945752798;
double ycenter = -0.008217742184605817;

double xscl, yscl;

int spacing = 5;
int mode = 2;

int iterations = 500;

void setup() {

  size(1000, 1000);
  //noStroke();
  xscl = 0.002;
  yscl = 0.002;
  colorMode(HSB, 360, 100, 100, 1);
  ellipseMode(CORNER);
}


void draw() {
  background(0);  
  double[] z = new double[2];
  if (mode == 1) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        z[0] = xcenter + x * xscl;
        z[1] = ycenter + y * yscl;
        float col = mandelbrot(z, iterations);
        if (col == 500.) {
          
          stroke(0, 0, 10.6);
          //double h = map(col, 0, 500, 0, 360);
          //stroke(h, 100, 100);
        } else {
          float i = map(col, 0, iterations, 0, 1);
          
          color c = lerpColor(color(325, 98.1, 40.4), 
                              color(65.6, 70.6, 53.3), i);
          
          float h = hue(c);
          float s = saturation(c);
          float b = map(col, 0, 100, 0, iterations);
          stroke(h,s,b + 50);
        }
        point(x, y);
      }
    }
  } else {
    for (int x = 0; x < width; x+=spacing) {
      for (int y = 0; y < height; y+=spacing) {
        z[0] = xcenter + x * xscl;
        z[1] = ycenter + y * yscl;
        float col = mandelbrot(z, iterations);
        if (col == iterations) {
          fill(0);
          
        } else {
          noStroke();
          float i = map(col, 0, iterations, 0, 1);
          
          color c = lerpColor(color(325, 98.1, 40.4), 
                              color(65.6, 70.6, 53.3), i);
          
          float h = hue(c);
          float s = saturation(c);
          float b = map(col, 0, 100, 0, iterations);
          fill(h,s,b + 50, random(.5, 1));
        }
        circle(x, y, random(2, spacing*2));
      }
    }
  }
  xscl = xscl*.99;
  yscl = yscl*.99;
  saveFrame("output/####.png");
  //noLoop();
}

int mandelbrot(double[] z, int num) {
  int count = 0;
  double[] z1 = z;
  while (count < num) {
    if (magnitude(z1) > 2.0) {
      return count;
    }
    z1 = cAdd(cMult(z1, z1), z);
    count += 1;
  }
  return num;
}


double[] cAdd(double[] a, double[] b) {
  double[] s = {a[0] + b[0], a[1] + b[1]};
  return s;
}


double[] cMult(double[] u, double[] v) {
  double[] p = {u[0] * v[0] - u[1] * v[1],
    u[1] * v[0] + u[0] * v[1]};
  return p;
}


double magnitude(double[] z) {
  return Math.sqrt(Math.pow(z[0], 2) + Math.pow(z[1], 2));
}


void keyPressed() {
  // What does all these key presses do? 
  if (key == '1') {
    mode = 1;
  }

  if (key == '2') {
    mode = 2;
  }
  
  if (key == '+') {
    xscl = xscl*.9;
    yscl = yscl*.9;
    
  }
  
  if (key == '-') {
    xscl = xscl*2;
    yscl = yscl*2;
    
  }
  
  if (key == 's') {
    save(getTemporalName("output/", ".png"));
  }
  if (key == CODED) {
    if (keyCode == RIGHT) {
      xcenter += xscl * 10;            
    } else if (keyCode == LEFT) {
      xcenter -= xscl * 10;
    } else if (keyCode == UP) {
      ycenter -= yscl * 10;
    } else if (keyCode == DOWN) {
      ycenter += yscl * 10;
    }
    
  }
  
  println("xscl: " + xscl);
  println("yscl: " + yscl);
  println("xcenter: " + xcenter);
  println("ycenter: " + ycenter);
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
