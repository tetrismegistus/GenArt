import processing.svg.*;

OpenSimplexNoise noise;

Ant[] ants = new Ant[75]; 

int img_scale = 1;
//float zoff = 0;
float inc = .005;
int totalFrames = 50;
int counter = 0;
boolean record = true;
float uoff = 0;
float voff = 0;
PFont font;
String[] quote = {"he dreams footnotes", "and they run away", "with his brains"};

void setup()
{
  size(1024, 768);
  noise = new OpenSimplexNoise();
  font = createFont("BASKVILL.TTF", 32);
  textFont(font);
  
  for (int i = 0; i < ants.length; i++) {
    int qIndex = (int) random(0, quote.length); 
    ants[i] = new Ant(random(0, width), random(0, height), 16, quote[qIndex]);
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
    saveFrame("frames/gif-"+nf(counter, 3)+".png");
    if (counter == totalFrames-1) {
      exit();
    }
  }
  counter++;

}



void render(float percent) {
  float angle = map(percent, 0, 1, 0, TWO_PI);
  uoff = map(cos(angle), -1, 1, 0, 1);
  voff = map(sin(angle), -1, 1, 0, 1);
  
  background(  32, 178, 170);

  
  for (int i = 0; i < ants.length; i++) {
    Ant a = ants[i];
    for (int l = 0; l < a.sentence.length(); l++)
      ants[i].step();
  }
  
  for (int i = 0; i < ants.length; i++) {
    Ant a = ants[i];
    for (int l = 0; l < a.sentence.length(); l++)
      ants[i].render(l);
  } 
  
  
  for (int i = 0; i < ants.length; i++) {
    ants[i].reset();      
  }

}

class Ant {
  ArrayList<PVector> locations; 
  PVector location;
  float xoff;
  float yoff;
  float inc;
  String sentence;

  float magnitude; 

  Ant(float x_, float y_, float m_, String s_) {
    location = new PVector(x_, y_);
    locations = new ArrayList<PVector>();
    locations.add(new PVector(location.x, location.y));
    inc = 0.01;
    xoff = x_ * inc;
    yoff = y_ * inc;
    sentence = new StringBuilder(s_).reverse().toString();
    magnitude = m_;
  }

  void step() {
    float n = (float) noise.eval(this.xoff, this.yoff, uoff, voff);
    float degrees = map(n, -1, 1, 0, 360);
    PVector velocity = new PVector(cos(radians(degrees)) * magnitude, 
      sin(radians(degrees)) * magnitude);
    location.add(velocity);

    this.xoff = location.x * inc;        
    this.yoff = location.y * inc;
    locations.add(new PVector(location.x, location.y));
  }

  void render(int index) {
    stroke(0);
    fill(0);    
    PVector vect = locations.get(index);
    text(sentence.charAt(index), vect.x, vect.y);
      
  }
  
  void reset() {
    this.location = new PVector(locations.get(0).x, locations.get(0).y);
    this.locations = new ArrayList<PVector>();
    this.locations.add(new PVector(location.x, location.y));
    this.xoff = location.x * inc;
    this.yoff = location.y * inc;    
  }
}
