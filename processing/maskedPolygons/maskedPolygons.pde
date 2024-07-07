void setup() {
  size(512, 512);
}


void draw() {
  polygonGrid();
  PImage mask = createImageFromScreen();
  background(255);
  scribbleBackground(#800080);
  PImage img = createImageFromScreen();
  background(255);
  scribbleBackground(#FFD300);
  img.mask(mask);
  image(img, 0, 0);
}

void polygonGrid(){
  float psize = 40;
  float sides = 3;
  background(0);
  noStroke();
  for (int c = 0; c < 4; c++) {
    for (int r = 0; r < 4; r++) {
      pushMatrix();
      translate((psize*c+25)*3, (psize*r+25)*3);
      polygon(sides, psize);
      popMatrix();
      sides += 1;
    }
  }
}

void scribbleBackground(int colr) {
  for (int i = 0; i < 50 * mouseY; i++) {
    noFill();
    stroke(colr);
    circle(random(0, width), random(0, height), random(0, width/5));
  }
}

PImage createImageFromScreen(){
  PImage img = createImage(width, height, RGB);
  img.loadPixels();
  loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = pixels[i];
  }
  img.updatePixels();
  return img;  
}


void polygon(float sides, float sz){
  beginShape();
  noStroke();
  fill(255);
  for (int i = 0; i < sides; i++) {
    float step = radians(360/sides);
    vertex(sz * cos(i*step), sz*sin(i*step));
    
  }
  endShape(CLOSE);  
}

void mouseClicked() {
  save("poly.png");
}
