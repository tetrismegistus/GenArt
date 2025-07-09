ArrayList<PVector> points = new ArrayList<PVector>();
float x = 1.0;
float y = 0.0;
float z = 1.0;

float sigma = 10.0;
float rho = 28.0; 
float beta = 8.0/3.0;

float hue = 0;

void setup() {
  size(800, 800, P3D);
  colorMode(HSB, 360, 100, 100, 1);
  points.add(new PVector(x, y, z));
}


void draw() {
  background(123);
  
  camera(1000, 500, 1500, width/2, height/2, width/2, 
       0.0, 1.0, 0.0);
  translate(width/2, height/2);

  stroke(0, 0, 0);
  
  box(800);
  
    
  
  noFill();
  float hue = 0;
  beginShape();
  for (PVector p : points) {
    stroke(hue, 100, 100); 
    vertex(p.x, p.y, p.z);
    hue += 0.1 % 360;
  }
  endShape();
  
  float dt = 0.01;
  float dx = (sigma * (y - x)) * dt;
  float dy = (x * (rho - z) - y) * dt;
  float dz = (x * y - beta * z) * dt;
  x += dx;
  y += dy;
  z += dz;   
  points.add(new PVector(x * 5, y * 5, z * 5));
  
  beginShape();
  for (PVector p : points) {
    stroke(0, 0, 0, .5); 
    vertex(p.x, 400, p.z);

  }
  endShape();
  
  beginShape();
  for (PVector p : points) {
    stroke(0, 0, 0, .5); 
    vertex(p.x, p.y, -400);

  }
  endShape();
  
    beginShape();
  for (PVector p : points) {
    stroke(0, 0, 0, .5); 
    vertex(-400, p.y, p.z);

  }
  endShape();
  
}

void keyPressed() {
  if (key == 's') {
    save("test.png");
  } 
}
