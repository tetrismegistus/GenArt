Walker w;

void setup() {
  size(800, 800);
  w = new Walker();
  background(255);
  
}


void draw() {
  stroke(frameCount % 255, 0, 0, 100);
  w.step();
  w.display();
  
  
  
}
