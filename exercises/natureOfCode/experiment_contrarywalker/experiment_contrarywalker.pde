
ArrayList<Walker> walkers = new ArrayList<Walker>();

void setup() {
  size(800, 800);
  for (int i = 0; i < 500; i++) {
    walkers.add(new Walker(random(width), random(height)));
  }
  background(255);
  
}


void draw() {
  stroke(frameCount % 255, 0, 0, 100);
  for (Walker w : walkers) {
    w.display();
    w.step();
    
  }
  
  
  
  
}
