OpenSimplexNoise noise;

float[][][] field;
int rows, cols, depth;
float scl, inc;
float r = 0;
float time = 0;

int totalFrames = 500;
int counter = 0;
boolean record = true;
float uoff = 0;
float voff = 0;


void setup() {
  
  noise = new OpenSimplexNoise((long) random(0, 255));
  rows = 10;
  cols = 10;
  depth = 10;
  scl = 10;
  inc = 0.1;
  field = new float[rows][cols][depth];
  size(500, 500, P3D);  
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
  float angle = map(percent, 0, 1, 0, TWO_PI*3);
  time = map(sin(angle), -1, 1, 0, 1);
  float xoff = 0;
  for (int x = 0; x < cols; x++){
    float yoff = 0;
    for (int y = 0; y < rows; y++){
      float zoff = 0;
      for (int z = 0; z < depth; z++){
        float n = (float) noise.eval(xoff, yoff, zoff, time);
        field[x][y][z] = n;
        zoff += inc;
      }
      yoff += inc;
    }  
    xoff += inc;
  }
  
  
  background(255);
  translate(width/2, height/2);
  //noStroke();
  //background(#120c6e);
  rotateX(PI/4);
  
  camera(150, 150, 100, 0, 0, 0, 0, 0, -1);
  //rotateZ(r);
  //rotate(r);
  for (int x = 0; x < cols; x++){    
    rotate(angle);
    for (int y = 0; y < rows; y++){
      
      for (int z = 0; z < depth; z++){

        float n = field[x][y][z]; 
        float sz;
        float b = map(n, -1, 1, 0, 255);
        float g = map(n, 0, 1, 0, 255);
        //float tr;

        if (n < 0) {
          sz = map(n, -1, 0, 0, scl/6);
        } else {
          sz = map(n, 0, 1, scl/6, scl);
        }
        if (sz > 1.5) {
          
        
          fill(0, b, g, 255);
          drawCell(x*scl, y*scl, z*scl, sz, sz);
        } else {
          fill(255, 255, 255, 0);
          drawCell(x*scl, y*scl, z*scl, scl, scl);
        }
        
      }
    }     
  }
  
  
  r += radians(1); 

}

void drawCell(float x, float y, float z, float w, float d) {
  pushMatrix();
  translate(x, y, z);
  box(w, w, d);
  popMatrix();    
}
