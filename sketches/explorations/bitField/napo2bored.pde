
void setup() {
  size(512, 512);
  colorMode(HSB, 360, 100, 100, 1);
  noStroke();
}


void draw() {
  background(200, 10, 100);
  
  for (int x = 0; x < 256; x++) {
    for (int y = 0; y < 256; y++) {
      float notMod = (x ^ y) % 40;
      if (notMod != 0) {
        float h = map(notMod, 0, 40, 0, 100);
        fill(200, h, 100);
        rect(x * 2, y * 2, 2, 2);
      }
    
    }
  }
  save("test.png");
  
}
