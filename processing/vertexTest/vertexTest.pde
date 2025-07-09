float t = 0;

void setup() {
  colorMode(HSB, 360, 100, 100, 1);
  size(1000, 1000, P3D);
}

void draw() {
  background(0);

  translate(width/2, height/2);
  rotateY(t);
  rotateX(t);
  rotateZ(t);
  for (float x = -12; x < 12; x++) {
    for (float y = -12; y < 12; y++) {
      for (float z = -12; z < 12; z++) {
        float h = map(x, -12, 12, 0, 360);        
        float s = map(y, -12, 12, 0, 100);
        float b = map(z, -12, 12, 0, 100);
        fill(h, s, b);
        pushMatrix();        
        translate(x * 20, y * 20, z * 20);        
        box(10, 10, 10);
        popMatrix();
      }
    }  
  }

  t += .01;
}
