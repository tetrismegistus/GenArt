int calls = 0;
long lastTime;

float xmin = -1.7;
float xmax = 1.7;

float ymin = -1.7;
float ymax = 1.7;

float rangex = xmax - xmin;
float rangey = ymax - ymin;

float xcenter = 0;
float ycenter = 0;

float xscl, yscl;

int spacing = 5;
int mode = 1;

int iterations = 2000;

float c1 = -0.8;
float c2 = 0.156;

float c1mod = -.001;
float c2mod = .001;

void setup() {

  size(500, 500);
  //noStroke();
  xscl = width/rangex;
  yscl = height/rangey;
  colorMode(HSB, 360, 100, 100, 1);
  ellipseMode(CORNER);
}


void draw() {
  translate(width/2, height/2);
  float x = xmin;
  while (x <= xmax) {
    float y = ymin;
    while (y <= ymax) {
      float[] z = {x, y};
      float[] c = {c1, c2};
      int col = julia(z, c, 100);
      color clr;
      if (col == 100) {
        clr = color(0, 0, 0);
      } else {
        float h = map(col, 0, 100, 0, 365);  
        float s = map(col, 0, 100, 50, 1000);
        clr = color(h, s, 100);        
      }
      stroke(clr);
      
      set((int)(x*xscl+ width/2), (int)(y*yscl + height/2), clr);
      
      y += 0.001;     
    }
    x += 0.001;
  }
  
  if (c1mod >= 1) {
      c1mod = -.001;
    } else if (c1mod <= -1) {
      c1mod = .001;
    }
    if (c2mod >= 1) {
      c2mod = -.001;
    } else if (c2mod <= -1) {
      c2mod = .001;
    }
     c1 += c1mod;
     c2 += c2mod;
  
  
  
}

int julia(float[] z, float[] c, int num) {
  int count = 0;
  float[] z1 = z;
  while (count <= num) {
    if (magnitude(z1) > 2.0) {
      return count;
    }
    z1 = cAdd(cMult(z1, z1), c);
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
  return sqrt(pow(z[0], 2) + pow(z[1], 2));
}

// what do these "keyPressed" funtions do? 
void keyPressed() {
  
  if (key == '1') {
    mode = 1;
  }

  if (key == '2') {
    mode = 2;
  }
  
  if (key == '+') {
    if (c1mod >= 1) {
      c1mod = -.001;
    } else if (c1mod <= -1) {
      c1mod = .001;
    }
    if (c2mod >= 1) {
      c2mod = -.001;
    } else if (c2mod <= -1) {
      c2mod = .001;
    }
     c1 += c1mod;
     c2 += c2mod;

    
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
