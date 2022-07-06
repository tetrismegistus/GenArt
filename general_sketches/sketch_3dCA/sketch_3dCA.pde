int cols, rows;
float scl = 5;
float r = 0;
float z = 0;
int[][] field;
int[][] copyfield;

void setup() {
  size(1000, 1000, P3D);
  background(#120c6e); 
  frameRate(10);
  cols = 100;
  rows = 100;
  field = new int[cols][rows];  
  for (int y = 1; y < rows - 1; y++) {    
    for (int x = 1; x < cols - 1; x++) {           
      float coinToss = random(1);
      if (coinToss > .5) {
        field[y][x] = 1;
      } else {
        field[y][x] = 0;
      }                                     
    }  
  }

 
}


void draw() {
  copyfield = new int[cols][rows];
  translate(width/2, height/2);
  //noStroke();
  //background(#120c6e);
  
  rotateX(PI/4);
  rotateZ(r);
  translate(-500/2, -500/2);
  camera(1000, 1000,500, 0, 0, 100, 0, 0, -1); 
  
  for (int y = 1; y < rows - 1; y++) {    
    for (int x = 1; x < cols - 1; x++) {      
      float d = dist(x, y, z, 0, 0, 400);
      if (field[y][x] == 1) {
        
        fill(d, 91,90, d);      
        drawCell(((x-1) * scl), ((y-1) * scl), scl, 5);
      } else {
        //fill(20, 13, 20, d);      
        //drawCell(((x-1) * scl), ((y-1) * scl), scl, 10);
      }
      noFill();
      
      
    }  
  }
  
  for (int y = 1; y < rows - 1; y++) {    
    for (int x = 1; x < cols - 1; x++) { 
      int nw = field[y - 1][x - 1];
      int n  = field[y - 1][x    ];
      int ne = field[y - 1][x + 1];
      int e  = field[y    ][x + 1];
      int se = field[y + 1][x + 1];
      int s  = field[y + 1][x    ];
      int sw = field[y + 1][x - 1];
      int w  = field[y    ][x - 1];
      int i =  field[y][x];
      int population = nw + n + ne + e + se + s + sw + w;   //<>//
      
      if ((i == 1) && (population >=2) && (population <= 3)) { //<>//
        copyfield[y][x] = 1;
      } else if ((i == 0) && (population == 3)) {
        copyfield[y][x] = 1;
      } else {
        copyfield[y][x] = 0;
      }                            
    } //<>//
  }
  arrayCopy(copyfield, field);
  

  r += radians(1);  //<>//
  z += scl;
  
  if (r <= radians(359)) {    
    saveFrame("frames/####.png");
  }
  
  
}

void mousePressed(){
  save("test.png");
}


void drawCell(float x, float y, float w, float d) {
  pushMatrix();
  translate(x, y, z);
  box(w, w, d);
  popMatrix();    
}
