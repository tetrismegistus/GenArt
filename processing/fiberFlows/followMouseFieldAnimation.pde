ArrayList<Mover>  movers = new ArrayList<Mover>();
OpenSimplexNoise noise;
Mover mover;

void setup() {
  size(1000, 1000);
  colorMode(HSB, 360, 100, 100, 1);
  noise = new OpenSimplexNoise((long) random(0, 255));
  for (int i = 0; i < 250; i++) {
    movers.add(new Mover(width/2, height/2));
  }
}


void draw() {
  background(0);
  for (Mover m: movers) {
    m.update();
    m.checkEdges();
    m.display();
  }
  //saveFrame("frames/####.png");
    
}

class Mover {
  PVector location;
  PVector velocity;
  PVector acceleration;
  ArrayList<ArrayList<PVector>> pointList;
  float topspeed;
  int c;
  
  Mover(float x, float y) {
    pointList = new ArrayList<ArrayList<PVector>>();
    location = new PVector(x, y);
    topspeed = 10;
    ArrayList<PVector> points = new ArrayList<PVector>();
        
    points.add(new PVector(location.x, location.y));
    pointList.add(points);
    velocity = new PVector(random(-2, 2), random(-2, 2));
    acceleration = new PVector(-0.001, 0.1);
    c = color(random(255), random(255), random(255));
  }
  
  void update() {
    PVector mouse = new PVector(mouseX, mouseY);
    PVector dir = PVector.sub(mouse, location);
    dir.normalize();
    dir.mult(0.5);
    acceleration = dir;
    
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
    
    
    int size = 0;
    for (ArrayList<PVector> pl : pointList) {
      size += pl.size();
    }
    
    if (size <= 50) {
      int idx = pointList.size() > 0 ? pointList.size() - 1 : 0;
      ArrayList<PVector> pl = pointList.get(idx);
      pl.add(new PVector(location.x, location.y));                 
    } else {
      if (pointList.get(0).size() <= 0) {
        pointList.remove(0);               
      } else {
        ArrayList<PVector> pl = pointList.get(0);        
        pl.remove(0);
        int idx = pointList.size() > 0 ? pointList.size() - 1 : 0;
        pl = pointList.get(idx);
        pl.add(new PVector(location.x, location.y));
      }                   
    }
    
  }
  
  void display() {
    
    //ellipse(location.x, location.y, 16, 16);
    noFill();
    //strokeWeight(2);
    for (ArrayList<PVector> pl : pointList) {
      
      beginShape();
      for (PVector p : pl) {
        float d = dist(p.x, p.y, mouseX, mouseY);
        float cadj = map(d, 0, width/2, 0, 360); 
    
        stroke(cadj, 100, 100, .5);    
        curveVertex(p.x, p.y);
      
      }
      endShape();
      
    }

    //point(location.x, location.y);
  }
  
  void checkEdges() {
    if (location.x > width) {
      location.x = 1;
      pointList.add(new ArrayList<PVector>());
    } else if (location.x < 0) {
      location.x = width;
      pointList.add(new ArrayList<PVector>());
    }
    
     if (location.y > height) {
       location.y = 1;
       pointList.add(new ArrayList<PVector>());
       
     } else if (location.y < 0) {
       location.y = height;
       pointList.add(new ArrayList<PVector>());
     }
  }
}
