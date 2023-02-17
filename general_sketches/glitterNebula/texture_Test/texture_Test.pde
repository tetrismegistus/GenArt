OpenSimplexNoise noise;

// reserve memory space for 4000 particles
int isize = 5000; 
Particle[] particles = new Particle [isize];

PImage img; 
float zoff = 0.0;

float time = 0;
int totalFrames = 500;
int counter = 0;
boolean record = true;
float uoff = 0;
float voff = 0;



void setup() {
 noise = new OpenSimplexNoise((long) random(0, 255));
 //img = loadImage("test.jpg");
 size(600, 600); smooth(); noStroke();
 // loop through all 4000 particles and initialize
 //img.loadPixels();
 for (int i = 0; i < isize; i++) {   
   particles[i] = new Particle(color(random(100, 255), 0, 0));
 }
}

void draw() {
  float percent = 0;
  if (record) {
    percent = float(counter) / totalFrames;
  } else {
    percent = float(counter % totalFrames) / totalFrames;
  }
  render(percent);
  if (record) {
    saveFrame("frames/"+nf(counter, 3)+".png");
    if (counter == totalFrames-1) {
      exit();
    }
  }
  counter++;
 
}

void render(float percent) {
 float angle = map(percent, 0, 1, 0, TWO_PI*3);
 time = map(sin(angle), -1, 1, 0, 1);
 // dark blue background
 background(35, 27, 107);
 // always draw from center of canvas
 translate(width/2, height/2);
 // loop through all particles
 for (Particle p : particles) {
   // change position and draw particle
   p.move();
   p.show();
   
 }
 filter(BLUR, 1);
 zoff += 0.01;
}
// create a new class for our particle
class Particle {
 float x, y, size, directionX, directionY, step;
 int c;
 // initialize (called 'constructor')
 public Particle(int c_) {
   this.size = random(0.5, 4);
   this.x = randomGaussian() * 100;
   this.y = randomGaussian() * 100;
   float n = (float) noise.eval(this.x * step, this.y * step, zoff, time);
   this.directionX = n;
   this.directionY = n;   
   this.c = c_;
   this.step = 0.01;
   
 }
 
 
     
 
 public void move() {
   // add directionX to x, and directionY to y
   this.x += directionX;
   this.y += directionY;
   float n = (float) noise.eval(this.x * step, this.y * step, zoff, time);
   this.directionX = n;
     
 
   this.directionY = n;   
 }
 
 // draw the particle on the Processing canvas
 public void show() {
   // set individual particle color
   float n = (float) noise.eval(x * step, y * step, zoff, time);
   float c = map(n, -1, 1, 0, 255);
   int points = (int) map(n, -1, 1, 3, 5); 
   float size = map(n, -1, 1, .5, 4);
   fill(c, c, 0);
   // draw particle shape
   polygon(this.x, this.y, this.size, points);
 }
 
}


void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
