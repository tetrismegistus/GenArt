int[] colors = {#087e8b, #FF5A5F, #F5F5F5, #C1839F};

int r = 0;
int c = 0;
 
sLine[] lines = new sLine[42];

void setup() {
  size(512, 512);
  rectMode(CENTER);
  noFill();
  grid(width / 20, height/20);

}

void draw() {
    background(#3c3c3c);  
  stroke(0);
  /*
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(r));
  if (c == 255) {
    c = 0;
  } else {
    c++;
  }
  square(0, 0, 50);
  popMatrix();
  r++;
  */

  translate(width/2, height/2);
  for (sLine line : lines){
    
    line.render();
  }
  noLoop();



}


void grid(float xscl, float yscl){
  strokeWeight(1);
  int xmin = -10;
  int xmax = 10;
  int ymin = -10;
  int ymax = 10;
  int linesI = 0;
  for (int i = xmin; i < xmax + 1; i++) {
    lines[linesI] = new sLine(i*xscl, ymin*yscl, i*xscl, ymax*yscl, 20);
    lines[linesI + 1] = new sLine(xmin * xscl, i * yscl, xmax * xscl, i * yscl, 20);
    linesI += 2;
  }
}

class sLine {
  PVector[] vectors;
  int num_points;
  
  sLine(float x1, float y1, float x2, float y2, int num_points_) {
    num_points = num_points_;
    vectors = addVectors(x1, y1, x2, y2);    
    smoothVectors(1); //<>//
  }
  
  PVector[] addVectors(float x1, float y1, float x2, float y2) {
    PVector[] vectors = new PVector[num_points + 2];
    
    vectors[1] = new PVector(x1 + randomGaussian(), y1 + randomGaussian());
    vectors[0] = new PVector((x1 - 1) - randomGaussian(), (y1 - 1) - randomGaussian());
    for (int i = 2; i < num_points; i++){    
      float y = lerp(y1, y2, i/(float) num_points) + randomGaussian();    
      float x = lerp(x1, x2, i/(float) num_points) + randomGaussian();
      vectors[i] = new PVector(x, y);    
    }    
    vectors[num_points] = new PVector(x2 + randomGaussian(), y2 + randomGaussian());
    vectors[num_points + 1] = new PVector((x2 + 1) + randomGaussian(), (y2 + 1) + randomGaussian());
    return vectors;
  }
  
  void smoothVectors(int passes) {
    for (int p = 0; p <= passes; p++) {      
      for (int i = 2; i < vectors.length - 1; i ++) {
        float avgVectX = (vectors[i].x + vectors[i + 1].x) / 2;
        float avgVectY = (vectors[i].y + vectors[i + 1].y) / 2;
        vectors[i] = new PVector(avgVectX, avgVectY);
      }
    }  
  }
  
  void render() {
    noFill();
    /*
    beginShape();    
    for (int i = 0; i < vectors.length; i++){        
      curveVertex(vectors[i].x, vectors[i].y);  
    }    
    endShape();*/
    variSegLine(vectors[0], vectors[vectors.length - 1]);
  }
}


void sloppyLine(float x1, float y1, float x2, float y2, int num_points) {
  noFill(); 
  PVector[] vectors = new PVector[num_points + 1];
  vectors[0] = new PVector(x1, y1);
  for (int i = 1; i < num_points; i++){    
    float y = lerp(y1, y2, i/(float) num_points) + randomGaussian();    
    float x = lerp(x1, x2, i/(float) num_points) + randomGaussian();
    vectors[i] = new PVector(x, y);    
  }
  vectors[num_points] = new PVector(x2, y2);
  
  beginShape();
  curveVertex((x1 - 1) + randomGaussian(), (y1 - 1) + randomGaussian());
  for (int i = 0; i < vectors.length; i++){        
    curveVertex(vectors[i].x, vectors[i].y); 

  }
  curveVertex((x2 - 1) + randomGaussian(), (y2 - 1) + randomGaussian());
  endShape();        
}



void variSegLine(PVector v1, PVector v2) {
  for (float i = 0; i <= 1; i+=.01) {
      float adj = constrain(i + randomGaussian() / 5, i, 1);
      PVector lp1 = PVector.lerp(v1, v2, i);
      PVector lp2 = PVector.lerp(v1, v2, adj);
      strokeWeight(random(.5, 10)); 
      stroke(pickColor(), random(100, 255));
      line(lp1.x, lp1.y, lp2.x, lp2.y);
      i = adj;
      

    }
}


int pickColor() {
  int i = round(random(0, colors.length  - 1));
  return colors[i];
}
