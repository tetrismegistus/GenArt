void textCircle(float x, float y, float D, color fg, color bg) {
  noStroke();
  ellipseMode(CENTER);
  fill(bg);
  //circle(x, y, D);
  int cap = (int)D/2 * 100;
  for (int i = 0; i < cap; i++) {
    float theta1 = random(1) * TWO_PI;
    float x1 = x + cos(theta1) * D/2;
    float y1 = y + sin(theta1) * D/2;
    float theta2 = random(1) * TWO_PI;
    float x2 = x + cos(theta2) * D/2;
    float y2 = y + sin(theta2) * D/2;
    strokeWeight(.1);
    stroke(fg, .1);
    line(x1, y1, x2, y2);   
  }
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
    line(points[0].x, points[0].y, points[1].x, points[1].y);

    //noStroke();
  }
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
      for (int sand = 0; sand < 10; sand++) { //<>//
        float li = sand/10.;
        float lx = lerp(lst.x, nxt.x, li);
        float ly = lerp(lst.y, nxt.y, li);
        strokeWeight(.5);
        point(lx, ly);

    }
    }

  }

}

float constrainedGauss(float low, float high, float scale) {
  return constrain(randomGaussian() * scale, low, high);
}
