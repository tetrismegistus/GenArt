Chemical[][] grid;
Chemical[][] next;

float dA = 1.0;
float dB = 0.5;
float feed = 0.055;
float k = 0.062;
ArrayList<PVector> points = new ArrayList<PVector>();
String img = "d02.jpg";

class Chemical {
  float a, b;
  
  Chemical(float a_, float b_) {
    a = a_;
    b = b_;
  }
}

void setup() {
  size(800, 800);
  
  
  grid = new Chemical[width][height];
  next = new Chemical[width][height];
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      grid[x][y] = new Chemical(1, 0);    
      next[x][y] = new Chemical(1, 0);
    }  
  }
  
  
  
  for (int i = 0; i <= width; i++) {
    float t = pos_t(i); 
    PVector p = new PVector((pos_x(t) + width/2), (-pos_y(t) + height/2));
    points.add(p);
  }  
  
  
  for (PVector p : points) {
    if (p != null) {
      next[(int)p.x][(int)p.y] = new Chemical(1, 1);
      grid[(int)p.x][(int)p.y] = new Chemical(1, 1);
    }
   
  }
  
}


void draw() {
  for (int x = 1; x < width - 1; x++) {
    for (int y = 1; y < height - 1; y++) {
      float a = grid[x][y].a;
      float b = grid[x][y].b;
      next[x][y].a = a + (dA*laplaceA(x, y) - a*b*b + feed*(1-a))*1;
      next[x][y].b = b + (dB*laplaceB(x, y) + a*b*b - (k+feed)*b)*1;      
      
      next[x][y].a = constrain(next[x][y].a, 0, 1);
      next[x][y].b = constrain(next[x][y].b, 0, 1);
    }  
  }
  
  
  loadPixels();
  for (int x = 1; x < width - 1; x++) {
    for (int y = 1; y < height - 1; y++) {
      int loc = x + y * width;
      int c = color((next[x][y].a - next[x][y].b) * 255, 46, 85);
      pixels[loc] = c;
    }  
  }
  updatePixels();
  
  swap();

}


float laplaceA(int i, int j) {
  float laplaceA = 0;
  Chemical spot = grid[i][j];
  float a = spot.a;
  laplaceA += a*-1;
  laplaceA += grid[i+1][j].a*0.2;
  laplaceA += grid[i-1][j].a*0.2;
  laplaceA += grid[i][j+1].a*0.2;
  laplaceA += grid[i][j-1].a*0.2;
  laplaceA += grid[i-1][j-1].a*0.05;
  laplaceA += grid[i+1][j-1].a*0.05;
  laplaceA += grid[i-1][j+1].a*0.05;
  laplaceA += grid[i+1][j+1].a*0.05;
  return laplaceA;  
}

float laplaceB(int i, int j) {  
  Chemical spot = grid[i][j];
  float b = spot.b;
  float laplaceB = 0;
      laplaceB += b*-1;
      laplaceB += grid[i+1][j].b*0.2;
      laplaceB += grid[i-1][j].b*0.2;
      laplaceB += grid[i][j+1].b*0.2;
      laplaceB += grid[i][j-1].b*0.2;
      laplaceB += grid[i-1][j-1].b*0.05;
      laplaceB += grid[i+1][j-1].b*0.05;
      laplaceB += grid[i-1][j+1].b*0.05;
      laplaceB += grid[i+1][j+1].b*0.05;
  return laplaceB;  
}

PVector[] getPImageVectors(PImage img) {
  PVector[] points = new PVector[img.width * img.height];
  img.loadPixels();
  for (int x = 0; x < img.width - 1; x += 1) {    
    for (int y = 0; y < img.height - 1; y += 1) {
      int loc1 = x + y * img.width;
      int loc2 = x + (y + 1) * img.width;
      int loc3 = (x + 1) + y * img.width;
      float b1 = brightness(img.pixels[loc1]);
      float b2 = brightness(img.pixels[loc2]);
      float b3 = brightness(img.pixels[loc3]);
      float diff1 = abs(b1-b2);
      float diff2 = abs(b1-b3);
      
      if (diff1 < 5 && diff2 < 5) {
        points[loc1] = new PVector(x, y);
      } 
    }
  }
  return points;
}


void swap() {
  Chemical[][] temp;
  temp = grid;
  grid = next;
  next = temp;  
}


float pos_t (float n) {
  return lerp(-PI,PI,n/400);
}

float pos_x(float n){
  return 16*pow(sin(n),3);
}


float pos_y(float n){
  return 13*cos(n)-5*cos(2*n)-2*cos(3*n)-cos(4*n);
}

void keyPressed() {
  if (key == 's') {
    save("test.png");
  } 
}
