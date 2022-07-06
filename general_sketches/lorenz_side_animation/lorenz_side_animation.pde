import peasy.*;

ArrayList<PVector> points = new ArrayList<PVector>();
float x = .1;
float y = 0.0;
float z = 0.0;

float sigma = random(1, 100);
float rho = random(1, 300); 
float beta = random(20, 50)/random(1, 19);
PeasyCam cam;
float hue = 0;

void setup() {
  size(800, 800, P3D);
  colorMode(HSB, 360, 100, 100, 1);
  points.add(new PVector(x, y, z));
  //cam = new PeasyCam(this, 0, 0, 0, 50);
}


void draw() {
  background(0);
  
  //camera(1000, 500, 1500, width/2, height/2, width/2, 
       //0.0, 1.0, 0.0);
  translate(width/5, height/2);

  stroke(0, 0, 0);
  
  //box(800);
  
    
  
  noFill();
  float hue = 0;
  
  /*
  beginShape();
  for (PVector p : points) {
    stroke(hue, 100, 100); 
    vertex(p.x, p.y, p.z);
    
    hue += 0.1 % 360;
  }
  endShape();
  */
  
  float dt = 0.001;
  float dx = (sigma * (y - x)) * dt;
  float dy = (x * (rho - z) - y) * dt;
  float dz = (x * y - beta * z) * dt;
  x += dx;
  y += dy;
  z += dz;
  
  PVector point = new PVector(x, y, z);
  //float sinOff = map(noise(x * 0.01, y * 0.05, z * 0.09), 0, 1, 0, 20); 
  //PVector offset = new PVector(sinOff, sinOff, sinOff);
  //point.add(offset);
  points.add(point);
  
  /*
  beginShape();
  for (PVector p : points) {
    stroke(0, 0, 0, .5); 
    vertex(p.x, 400, p.z);

  }
  endShape();
  */
  
  /*
  beginShape();
  for (PVector p : points) {
    stroke(0, 0, 0, .5); 
    vertex(p.x, p.y, -400);

  }
  endShape();
  */
  
  
  strokeWeight(2);
    beginShape();
  for (PVector p : points) {
    
    stroke(hue, 100, 100); 
    fill(hue, 100, 100, .2);
    
    
    hue = hue + 0.1 % 360; 
    vertex(p.z, p.y);

  }
  endShape();
  saveFrame("frames/####.png");
  
}

void keyPressed() {
  if (key == 's') {
    save("test.png");
  } 
}
