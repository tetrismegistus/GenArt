String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float diameter = 500;


void setup() {
  size(2000, 2000);
  colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
  background(#5b7c99);
  textSquare(50, 50, 1900, #FEFBEA);
  //ellipseMode(CENTER);
  float d = 1800/2;
  float flowerCenterX = width/2;
  float flowerCenterY = height/2;  
  
  float cCenterX = width/2;
  float cCenterY = flowerCenterY - (100 + d/2);  
  float angle = atan2(cCenterX - flowerCenterX, cCenterY - flowerCenterY);
  float h = degrees(angle + 360) % 360;
  float s = map(dist(flowerCenterX, flowerCenterY, cCenterX, cCenterY), 0, d/2, 0, 100); 
  myCircle c1 = new myCircle(flowerCenterX, 100 + d/2, d, color(h, s, 100));  
  
  cCenterX = flowerCenterX;
  cCenterY = 100 + d/2 * 2;
  angle = atan2(cCenterX - flowerCenterX, cCenterY - flowerCenterY);
  h = degrees(angle + 360) % 360;  
  s = map(dist(flowerCenterX, flowerCenterY, cCenterX, cCenterY), 0, d/2, 0, 100);
  myCircle c2 = new myCircle(width/2, cCenterY, d, color(h, s, 100));  
  
  PVector[] intersections = c1.intersections(c2);
  cCenterX = intersections[0].x;
  cCenterY = intersections[0].y;
  angle = atan2(cCenterX - flowerCenterX, cCenterY - flowerCenterY);
  h = degrees(angle + 360) % 360;
  s = map(dist(flowerCenterX, flowerCenterY, cCenterX, cCenterY), 0, d/2, 0, 100);
  myCircle c3 = new myCircle(cCenterX, cCenterY, d, color(h, s, 100));
    
  cCenterX = intersections[1].x;
  cCenterY = intersections[1].y;
  angle = atan2(cCenterX - flowerCenterX, cCenterY - flowerCenterY);
  h = degrees(angle + 360) % 360;
  s = map(dist(flowerCenterX, flowerCenterY, cCenterX, cCenterY), 0, d/2, 0, 100);
  myCircle c4 = new myCircle(cCenterX, cCenterY, d, color(h, s, 100));  
  
  cCenterX = flowerCenterX;
  cCenterY = 100 + d/2 * 3;
  angle = atan2(cCenterX - flowerCenterX, cCenterY - flowerCenterY);
  h = degrees(angle + 360) % 360;
  s = map(dist(flowerCenterX, flowerCenterY, cCenterX, cCenterY), 0, d/2, 0, 100);
  myCircle c5 = new myCircle(width/2, 100 + d/2 * 3, d, color(h, s, 100));
  intersections = c5.intersections(c2);
  
  cCenterX = intersections[0].x;
  cCenterY = intersections[0].y;
  angle = atan2(cCenterX - flowerCenterX, cCenterY - flowerCenterY);
  h = degrees(angle + 360) % 360;
  s = map(dist(flowerCenterX, flowerCenterY, cCenterX, cCenterY), 0, d/2, 0, 100);
  myCircle c6 = new myCircle(cCenterX, cCenterY, d, color(h, s, 100)); 
  
  cCenterX = intersections[1].x;
  cCenterY = intersections[1].y;
  angle = atan2(cCenterX - flowerCenterX, cCenterY - flowerCenterY);
  h = degrees(angle + 360) % 360;
  s = map(dist(flowerCenterX, flowerCenterY, cCenterX, cCenterY), 0, d/2, 0, 100);
  myCircle c7 = new myCircle(cCenterX, cCenterY, d, color(h, s, 100));  
  
  
  cCenterX = flowerCenterX;
  cCenterY = 100 + d/2 * 2;
  angle = atan2(cCenterX - flowerCenterX, cCenterY - flowerCenterY);
  h = degrees(angle + 360) % 360;
  s = map(dist(flowerCenterX, flowerCenterY, cCenterX, cCenterY), 0, d/2, 0, 100);
  myCircle c8 = new myCircle(cCenterX, cCenterY, 1800, color(h, s, 20));
  
  c1.render();
  
  c2.render();
  c3.render();
  c4.render();
  c5.render();
  c6.render();
  c7.render();
  c8.render();
  noLoop();
  
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


class myCircle {
  float x, y, r;
  color c;
  
  myCircle(float x1, float y1, float r1, color c1) {
    x = x1;
    y = y1;
    r = r1;
    c = c1;
  }
  
  void render() {
    //ellipseMode(CENTER);
    noFill();
    textCircle(x, y, r, c);
  }
  
  PVector[] intersections(myCircle c2) {        
    // https://gist.github.com/xaedes/974535e71009fa8f090e
    // thanks!
    float dx = c2.x - x;
    float dy = c2.y - y;
    float d = dist(x, y, c2.x, c2.y);
    
    float r1 = r/2;
    float r2 = c2.r/2;
    
    
    if ((d > r + c2.r) || 
        (d < abs(r - c2.r)) || 
        (d == 0 && r == c2.r)) {
          return null;
    }
    
    float a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
        
    float h = sqrt(r1 * r1 - a * a);
    float xm = x + a * dx / d;
    float ym = y + a * dy / d;
    float xs1 = xm + h * dy / d;
    float xs2 = xm - h * dy / d;
    float ys1 = ym - h * dx / d;
    float ys2 = ym + h * dx / d;

    PVector[] results = new PVector[2];
    results[0] = new PVector(xs1, ys1);
    results[1] = new PVector(xs2, ys2);    
    
    return results; 
  }
}
