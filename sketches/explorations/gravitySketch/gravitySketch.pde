// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com
Attractor a;
Mover[] movers = new Mover[2];
Attractor[] attractors = new Attractor[2];

String sketchName = "mySketch";
String saveFormat = ".png";
long lastTime;
int calls = 0;

float tB = 50;
float lB = 50;
float rB = 750;
float bB = 750;

float g = 0.4;

color[] p = {#5BC0BE, #3A0F6B, #FFFFFF};

void setup() {
  size(800,800);
  colorMode(HSB, 360, 100, 100, 1);
  
  for (int i = 0; i < movers.length; i++) {
    int pidx = (int) random(p.length);
    movers[i] = new Mover(random(0.1,2), random(width), random(height), p[pidx]); 
  }
  
  for (int i = 0; i < attractors.length; i++) {
    attractors[i] = new Attractor(random(width), random(height)); 
  }
  
  for (int iter = 0; iter < 5000; iter++) {
  
  for (int i = 0; i < movers.length; i++) {
    for (int j = 0; j < movers.length; j++) {
      if (i != j) {
        PVector force = movers[j].attract(movers[i]);
        movers[i].applyForce(force);
      }
    }
    
    for (int k = 0; k < attractors.length; k++) {
      PVector aForce = attractors[k].attract(movers[i]);
      movers[i].applyForce(aForce);
      //attractors[k].display();
      
    }
    
    //PVector aForce = a.attract(movers[i]);
    //
    movers[i].update();    
    
  }
  }
  
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

void draw() {
  background(#FEFBEA);
  textSquare(50, 50, 700, #0B132B);
  //a.location.x = mouseX;
  //a.location.y = mouseY;
  //a.display();
  for (int i = 0; i < attractors.length; i++) {

    //PVector aForce = a.attract(movers[i]);
    //
    attractors[i].display();    
    
  }
  for (int i = 0; i < movers.length; i++) {

    //PVector aForce = a.attract(movers[i]);
    //
    movers[i].display();    
    
  }
  noLoop();
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
