ArrayList<Walker> walkers = new ArrayList<Walker>();
int[] colors = {#BCD8C1, 
                #D6DBB2, 
                #E3D985, 
                #E57A44};

void setup() {
  size(800, 800);
  for (int i = 0; i <100; i++) {
    int c = colors[(int)random(0, 4)];
    walkers.add(new Walker(random(width), random(height), hue(c), saturation(c), brightness(c)));
  }
  colorMode(HSB, 360, 100, 100, 1);
   background(304, 52, 26);
  
}


void draw() {

  for (Walker w : walkers) {
    w.display();
    w.step();
    
  }
  
  
}
