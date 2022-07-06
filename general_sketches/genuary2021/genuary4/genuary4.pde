void setup() {
  size(600, 600);
}

void draw() {
  background(123);
  translate(width/2, height/2);
  
  for (int i = 0; i < 4; i ++) {    
    int x1 = int(random(-50, 50)); 
    int y1 = int(random(-50, 50));
    int x2 = int(random(-50, 50));
    int y2 = int(random(-50, 50));
    float lerppoint = random(1);
    float x3 = lerp(x1, x2, lerppoint);
    float y3 = lerp(y1, y2, lerppoint);
    float x4 = x3 + random(-50, 50);
    float y4 = y3 + random(-50, 50);
    new sLine(x1, y1, x2, y2, 10).render();
    new sLine(x3, y3, x4, y4, 10).render();    
    
    rotate(radians(180));
    new sLine(x1, y1, x2, y2, 10).render();
    new sLine(x3, y3, x4, y4, 10).render();

    rotate(radians(random(45)));
  }
  noLoop();
  
}


class sLine {
  PVector[] vectors;
  int num_points;
  
  sLine(float x1, float y1, float x2, float y2, int num_points_) {
    num_points = num_points_;
    vectors = addVectors(x1, y1, x2, y2);    
    smoothVectors(1);
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
    beginShape();    
    for (int i = 0; i < vectors.length; i++){        
      curveVertex(vectors[i].x, vectors[i].y);  
    }    
    endShape();  
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
