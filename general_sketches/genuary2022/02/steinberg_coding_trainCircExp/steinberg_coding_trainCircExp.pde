
PImage kitten;

void setup() {
  size(800, 800);
  kitten = loadImage("d2.png");
  kitten.filter(GRAY);
  
  noLoop();
}

int index(int x, int y) {
  return x + y * kitten.width;
}

void draw() {
  
  for (int y = 0; y < kitten.height-1; y++) {
    for (int x = 1; x < kitten.width-1; x++) {
      color pix = kitten.pixels[index(x, y)];
      float oldR = red(pix);
      float oldG = green(pix);
      float oldB = blue(pix);
      int factor = 1;
      int newR = round(factor * oldR / 255) * (255/factor);
      int newG = round(factor * oldG / 255) * (255/factor);
      int newB = round(factor * oldB / 255) * (255/factor);
      fill(newR, newG, newB);
      circle(x, y, 10);

      float errR = oldR - newR;
      float errG = oldG - newG;
      float errB = oldB - newB;


      int index = index(x+1, y  );
      color c = kitten.pixels[index];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      r = r + errR * 7/16.0;
      g = g + errG * 7/16.0;
      b = b + errB * 7/16.0;
      fill(r, g, b);
      circle(x+1, y, 10); 

      index = index(x-1, y+1  );
      c = kitten.pixels[index];
      r = red(c);
      g = green(c);
      b = blue(c);
      r = r + errR * 3/16.0;
      g = g + errG * 3/16.0;
      b = b + errB * 3/16.0;
      fill(r, g, b);
      circle(x-1, y+1, 10);
      

      index = index(x, y+1);
      c = kitten.pixels[index];
      r = red(c);
      g = green(c);
      b = blue(c);
      r = r + errR * 5/16.0;
      g = g + errG * 5/16.0;
      b = b + errB * 5/16.0;
      fill(r, g, b);
      circle(x, y+1, 10);


      index = index(x+1, y+1);
      c = kitten.pixels[index];
      r = red(c);
      g = green(c);
      b = blue(c);
      r = r + errR * 1/16.0;
      g = g + errG * 1/16.0;
      b = b + errB * 1/16.0;
      fill(r,g,b);
      circle(x+1, y+1, 10);
    }
  }
  
  save("test.png");
}
