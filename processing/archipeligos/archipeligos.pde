import processing.svg.*;

//OpenSimplexNoise noise;
OpenSimplex2S noise;

float[][] field;
int awidth = 110;
int aheight = 110;
int acols = 8;
int arows = 8;
int rez = 1;
int cols, rows;
float inc = 0.1;
float zoff = 0.01;

void setup() {
  stroke(0);
  size(890, 890);
  
  cols= 1 + awidth / rez;
  rows = 1 + aheight /rez;  

}

void line(PVector v1, PVector v2) {
  line(v1.x, v1.y, v2.x, v2.y);
  
}

void draw() {
  background(255);
  for (int x=10; x < awidth * acols; x += awidth) {
    for (int y=10; y < aheight * arows; y += aheight) {
      long seed = (long) random(0, 10293801); 
      drawArchipelago(x, y, 100, 100, seed);    
    }
    
  }  
  save("archi.png");
  noLoop();

}

void drawArchipelago(int x_, int y_, float w_, float h_, long s_) {  
  field = new float[cols][rows];
  noise = new OpenSimplex2S((long) s_);
  noFill();
  rect(x_, y_, w_, h_);
  pushMatrix();
  translate(x_, y_);
  float xoff = 0;  
  for (int i = 0; i < cols; i++) {
    xoff += inc;
    float yoff = 0;
    for (int j = 0; j < rows; j++) {
      
      field[i][j] = (float) getNoise(xoff, yoff, 8, zoff);
      yoff += inc;
    }
  }
      
   for (int i = 0; i < w_; i++) {
    for (int j = 0; j < h_; j++) {
      float x = i * rez;
      float y = j * rez;
      PVector a = new PVector(x + rez*0.5, y);
      PVector b = new PVector(x + rez, y + rez*0.5);
      PVector c = new PVector(x + rez*0.5, y+rez);
      PVector d = new PVector(x, y + rez*0.5);
      
            
      strokeWeight(1);
      
      int state = (int) getState(ceil(field[i][j]), 
                           ceil(field[i+1][j]),
                           ceil(field[i+1][j+1]),
                           ceil(field[i][j+1]));
                           
      switch (state) {
      case 1:  
        line(c, d);
        break;
      case 2:  
        line(b, c);
        break;
      case 3:  
        line(b, d);
        break;
      case 4:  
        line(a, b);
        break;
      case 5:  
        line(a, d);
        line(b, c);
        break;
      case 6:  
        line(a, c);
        break;
      case 7:  
        line(a, d);
        break;
      case 8:  
        line(a, d);
        break;
      case 9:  
        line(a, c);
        break;
      case 10: 
        line(a, b);
        line(c, d);
        break;
      case 11: 
        line(a, b);
        break;
      case 12: 
        line(b, d);
        break;
      case 13: 
        line(b, c);
        break;
      case 14: 
        line(c, d);
        break;
      }

    }    
  }  
  popMatrix();

}



float getState(float a, float b, float c, float d) {
  return a * 8 + b * 4 + c * 2 + d * 1;
}


float getNoise(float xoff, float yoff, int octaves, double zoom){  
  double total = 0;
  double frequency = 1;
  double amplitude = 1;
  double maxValue = 0;  
  double persistence = .9;    
      
  for (int i=0; i < octaves; i ++){
    total += noise.noise3_Classic((xoff *  frequency) * zoom, (yoff *  frequency) * zoom, zoff * frequency * zoom) * amplitude;
    maxValue += amplitude;
    amplitude *= persistence;
    frequency *= 2;      
  }
  return (float) total;
  
}
