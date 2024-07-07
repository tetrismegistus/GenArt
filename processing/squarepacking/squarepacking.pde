PackedSquare ps, ps2;
int[] colors = {#087e8b, #FF5A5F, #F5F5F5, #C1839F};
ArrayList<PackedSquare> squares = new ArrayList<PackedSquare>();


class PackedSquare {
  float x, y, sd;  
  float[][] corners = new float[4][2];
  
  PackedSquare(float x_, float y_, float sd_) {
    x = x_;
    y = y_;
    sd = sd_;
    
    corners[0][0] = x - sd / 2;
    corners[0][1] = y - sd / 2;
    
    corners[1][0] = x + sd / 2;
    corners[1][1] = y - sd / 2;
    
    corners[2][0] = x - sd / 2; 
    corners[2][1] = y + sd / 2;
    
    corners[3][0] = x + sd / 2;
    corners[3][1] = y + sd / 2;

  }
  
  
  
  void render() {
    fill(pickColor(), 100);
    square(x, y, sd);
    pushMatrix();
    translate(x, y);
    for (int j = 0; j < sd; j += 20) {
          float x1 = 0 - j/2;
    float y1 = 0 - j/2;
    float x2 = j/2;
    float y2 = y1;
    float x3 = x1;
    float y3 = j/2;
    float x4 = j/2;
    float y4 = j/2;
    variSegLine(new PVector(x1, y1), new PVector(x2, y2));
    variSegLine(new PVector(x1, y1), new PVector(x3, y3));
    variSegLine(new PVector(x3, y3), new PVector(x4, y4));
    variSegLine(new PVector(x2, y2), new PVector(x4, y4));
    
      

  }
  popMatrix();

                       
  }
  
  boolean overlaps(PackedSquare other) {
    
    boolean xCheck = (corners[1][0] >= other.corners[0][0] && 
                      corners[0][0] <= other.corners[1][0]);
    boolean yCheck = (corners[2][1] >= other.corners[0][1] &&
                      corners[0][1] <= other.corners[2][1]);

    return xCheck & yCheck;
    
     //<>//
  }

  
}


void setup() {
  size(1024, 1024);
  rectMode(CENTER);
  squares = PackSquares(10000, squares);
  
   //<>//
}


void draw() { 
  background(#3c3c3c);
  for (PackedSquare ps2 : squares) {
    ps2.render();          
   }

  save("test.png");
  noLoop(); //<>//
}

int pickColor() {
  int i = round(random(0, colors.length  - 1));
  return colors[i];
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


ArrayList<PackedSquare> PackSquares(int attempts, ArrayList<PackedSquare> squareList){  
  for (int i = 0; i < attempts; i ++){
        
    boolean collides = false;
    while (!collides) {
      PackedSquare circle = new PackedSquare(random(0, width), random(0, height), random(20, 500));
      for (PackedSquare ps : squares) {
        boolean overlap = ps.overlaps(circle);
        if (overlap) {
          collides = true;
          break;        
        }            
      }
      if (!collides){
       squareList.add(circle);
      }           
    }
  }
  return squares;
}
