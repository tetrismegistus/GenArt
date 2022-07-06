String sketchName = "crepuscular";
String saveFormat = ".png";

int calls = 0;
long lastTime;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);

}


void draw() {
  background(#5b7c99);
  textSquare(50, 50, 700, #FEFBEA);
  //fill(255, 0, 0, .1);
  noFill();
  stroke(#fd5e53, .8);
  strokeWeight(10);
  textCircle(width/2, height/2, 400, #fd5e53);
  for (int cirPoint = 1; cirPoint < 360; cirPoint++) {
    float ltheta = radians(cirPoint - 1);
    float theta = radians(cirPoint);
    float nx = width/2 + cos(theta) * 200;
    float ny = height / 2 + sin(theta)*200;
    float ox = width/2 + cos(ltheta) * 200;
    float oy = height / 2 + sin(ltheta)*200;    
    myLine(ox, oy, nx, ny);
    
  }
  
  stroke(255, 100, 50, .75);
  strokeWeight(10);
  myLine(100, height/2, 700, height/2);

  noLoop();
  
}


void myLine(float x1, float y1, float x2, float y2) {

  float tweakLimit = 30;
  
  float scale = 2;
  int nPoints = (int) 100;
  x1 = x1 + constrainedGauss(-tweakLimit, tweakLimit, scale);
  y1 = y1 + constrainedGauss(-tweakLimit, tweakLimit, scale);
  x2 = x2 + constrainedGauss(-tweakLimit, tweakLimit, scale);
  y2 = y2 + constrainedGauss(-tweakLimit, tweakLimit, scale);
  PVector[] lPoints = new PVector[nPoints + 2];
  

  lPoints[0] = new PVector(x1, y1);
  for (float i = 0; i < nPoints; i++) {
    float lp = i/nPoints;
    float px = lerp(x1, x2, lp) + constrainedGauss(-tweakLimit, tweakLimit, scale);
    float py = lerp(y1, y2, lp) + constrainedGauss(-tweakLimit, tweakLimit, scale);
    lPoints[(int)i + 1] = new PVector(px, py);        
  }
  lPoints[nPoints + 1] = new PVector(x2, y2);  

  lPoints = kernelSmoother(lPoints, 1);
  
  beginShape();
  for (PVector p: lPoints) {
    curveVertex(p.x, p.y);
  }
  endShape();
  dropSand(lPoints, 50);
    strokeWeight(.3);


}

PVector[] kernelSmoother(PVector[] inputs, int passes) {
  PVector[] outputs = new PVector[inputs.length];
  for (int j = 0; j < passes; j++)  {
    for (int i = 0; i < inputs.length; i++) {
      PVector p = inputs[i];
      float avgX = p.x;
      float avgY = p.y;
      if (i > 0 && i < inputs.length - 1) {
        PVector lst = inputs[i - 1];
        PVector nxt = inputs[i + 1];
        avgX = (lst.x + nxt.x)/2;
        avgY = (lst.y + nxt.y)/2;
      }
    outputs[i] = new PVector(avgX, avgY);  
    }
    arrayCopy(outputs, inputs);    
  }
    
      
  return inputs;
}


void dropSand(PVector[] inputs, int passes) {
  
  
  for (int i = 1; i < inputs.length; i++) {
      

    for (int p = 0; p < passes; p++) {
      PVector lst = inputs[i - 1].copy();
      PVector nxt = inputs[i].copy();
      lst.x += constrainedGauss(-10, 10, 2);
      lst.y += constrainedGauss(-10, 10, 2);
      nxt.x += constrainedGauss(-10, 10, 2);
      nxt.y += constrainedGauss(-10, 10, 2);

      //stroke(0);
      //line(lst.x, lst.y, nxt.x, nxt.y);
      for (int sand = 0; sand < 10; sand++) { //<>// //<>//
        float li = sand/10.;
        float lx = lerp(lst.x, nxt.x, li);
        float ly = lerp(lst.y, nxt.y, li);
        strokeWeight(.5);
        point(lx, ly);

    }
    }

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


float constrainedGauss(float low, float high, float scale) {
  return constrain(randomGaussian() * scale, low, high);
}



void textSquare(float x1, float y1, float sz, color fg) {
  rectMode(CORNER);
  noStroke();

  
  for (int ln = 0; ln < sz * 100; ln++) {
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
  int cap = (int)D/2 * 50;
  for (int i = 0; i < cap; i++) {
    float theta1 = random(1) * PI;
    float x1 = x + cos(theta1) * D/2 + randomGaussian() * 2;
    float y1 = y + sin(theta1) * D/2 + randomGaussian() * 2;
    float theta2 = random(1) * PI;
    float x2 = x + cos(theta2) * D/2 + randomGaussian() * 2;
    float y2 = y + sin(theta2) * D/2 + randomGaussian() * 2;
    strokeWeight(.08);
    stroke(fg, .1);
    line(x1, y1, x2, y2);   
  }
}
