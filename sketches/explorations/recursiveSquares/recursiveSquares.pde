String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float pad;

color sqCol1 = #763626;
color sqCol2 = #90AFC5;

int maxDepth = 4;

void setup() {
  size(800, 800);
  pad = 800/10;
  colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
  background(#336B87);
  noFill();
  stroke(100, 0, 100);
  textSquare(pad, pad, width-pad*2, #0B132B);
  createCell(pad, pad, width-pad*2, width-pad*2, maxDepth, 0);
  noLoop();

}


void createCell(float posX, float posY, float w, float h, int d, int colCounter) {
  if (d > 0) {
    
      createCell(posX, posY, w/2, h/2, d - (int) random(1, 3), colCounter+1);    
      createCell(posX+w/2, posY, w/2, h/2, d - (int) random(1, 3), colCounter+1);
      createCell(posX, posY + h/2, w/2, h/2, d - (int) random(1, 3), colCounter+1);
      createCell(posX+w/2, posY + h/2, w/2, h/2, d - (int) random(1, 3), colCounter+1);
     
  
  } else {
    println(colCounter);
    pushMatrix();
    translate(posX, posY);
    rotate(radians(random(-10, 10)));
    color sqCol = lerpColor(sqCol1, sqCol2, map(colCounter, 2, 4, 0, 1)); 
    if (random(1) > .5) {
      textSquare(0, 0, w, sqCol);
    } else {
      fill(sqCol);
      square(0 - w/8 ,0 -w/8, w);
    }
    popMatrix();

  }
}
  
    
  
void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
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


void textSquare(float x1, float y1, float sz, color fg) {
  rectMode(CORNER);
  noStroke();

  
  for (int ln = 0; ln < sz * 200; ln++) {
    IntList sides = new IntList();
    
    for (int i = 0; i < 4; i++) {
      sides.append(i);
    }
    sides.shuffle();
    
    int[] chosenSides =  new int[2];
    chosenSides[0] = sides.get(0);
    chosenSides[1] = sides.get(1);
    
    
    
    stroke(0);
    
    PVector[] points = new PVector[2];
    for (int i = 0; i < chosenSides.length; i++) {
      PVector p = new PVector();
      float adj = map(random(.5), 0, .5, 0, sz);
      switch(chosenSides[i]) {
        case 0:
          p.x = x1 + adj;
          p.y = y1;
          break;
        case 1:
          p.x = x1;
          p.y = y1+ adj;
          break;
        case 2:
          p.x = x1 + adj;
          p.y = y1 + sz;
          break;
        case 3:
          p.x = x1 + sz;
          p.y = y1 + adj;  
          break;
      }
      points[i] = p;
    }
    strokeWeight(.05);
    stroke(fg, .05);
    
    line(points[0].x + randomGaussian() * 2, points[0].y + randomGaussian() * 2, points[1].x + randomGaussian() * 2, points[1].y + randomGaussian() * 2);

    //noStroke();
  }
}

void textCircle(float x, float y, float D, color fg) {
  noStroke();
  ellipseMode(CENTER);
  
  //circle(x, y, D);
  int cap = (int)D/2 * 200;
  for (int i = 0; i < cap; i++) {
    float theta1 = random(1) * TWO_PI;
    float x1 = x + cos(theta1) * D/2 + randomGaussian() * 2;
    float y1 = y + sin(theta1) * D/2 + randomGaussian() * 2;
    float theta2 = random(1) * TWO_PI;
    float x2 = x + cos(theta2) * D/2 + randomGaussian() * 2;
    float y2 = y + sin(theta2) * D/2 + randomGaussian() * 2;
    strokeWeight(.08);
    stroke(fg, .1);
    line(x1, y1, x2, y2);   
  }
  
}
