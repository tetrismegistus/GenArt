ArrayList<Circle> CIRCLES1 = new ArrayList<Circle>();
color backg =#FEFBEA;


void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
  CIRCLES1 = PackCircles(100000, CIRCLES1);
}


void draw() {
  background(#09122c);
  textSquare(0, 0, width, #FFFFFF); 
  //stipCirc(width/2, height/2, 200, color(random(255), 0, 0, random(10, 255)));
  
  for (Circle c : CIRCLES1) {
        c.render();
  }
  noLoop();
  save("test.png");
}

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

void stipCirc(float x1, float y1, float R, color c) {
  int cap = ((int) R * (int) R) * 4;
  for (int i = 0; i < cap; i++) {
    float r = R * sqrt(random(0, 1));
    float theta = random(0, 1) * 2 * PI;
    float x = (x1) + r * cos(theta);
    float y = (y1) + r * sin(theta);
    CompositePoint p1 = new CompositePoint(x, y);
    CompositePoint center = new CompositePoint(x1, y1);
    float d = p1.distance(center);
    float mapped_d = map(d, 0, R, 100, 20);
    float h = hue(c);
    
    strokeWeight(.5 + abs(randomGaussian()));
    stroke(color(h, 100, mapped_d));
    
    point(x, y);
  }
  noLoop();  

}
