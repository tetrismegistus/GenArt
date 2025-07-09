color[] p = new color[5];
int sz;


void setup() {
  size(1000, 1000);
  colorMode(HSB, 360, 100, 100, 1);
  for (int i = 0; i < 5; i++) { //<>//
    int hue = (int) random(0, 360);
    int sat = (int) random(0, 100);
    int brt = (int) 10*round(random(0, 10));
    float alpha = random(.5, 1.);
    if (i == 4) {
      hue += 180 % 360;
      alpha = 1.0;
    }
    color c = color(hue, sat, brt, alpha);
    p[i] = c;
  }
  
  
  
  
  
}

void draw() {
  background(p[4]);
  //noFill();
  fill(255, 0, 0, 100);
  sz = 400;
  for(int y = 100; y < height - 100; y += sz) {
    for(int x = 100; x < width - 100; x += sz) {
      float posMod = random(-50, 50);
      float szMod = random(-sz + 10, sz);
      float newX = constrain(x + posMod, 0, width - 100);
      float newY = constrain(y + posMod, 0, height - 100);
      squig(newX, newY, sz + szMod, sz + szMod);
    }
  }
  save("gen.png");
  

  noLoop();
}


void squig(float x, float y, float w, float h) {
  noFill();
  pushMatrix();
  translate(x, y);
  
  stroke(color(p[round(random(0, p.length - 2))], 100));
  if (random(0, 1) > .3) {
    noStroke();
  }
  
  

  float x1adj = randomGaussian() * w/4;
  float y1adj = randomGaussian() * h/4;    
  float x1 = random(w/4 + x1adj, w - w/4);
  float y1 = random(w/4 + y1adj, h - w/4); 
  float x2adj = randomGaussian() * w;
  float y2adj = randomGaussian() * h;
  float x2 = constrain(x1 + x2adj, 0, w);
  float y2 = constrain(y1 + y2adj, 0, h);
  float x3 = constrain(x1 + random(w/5, w), 0, w);
  float y3 = constrain(y1 + random(h/5, h), 0, h);
  float x4 = constrain(x3 + random(w/5, w), 0, w);
  float y4 = constrain(y3 + random(h/5, h), 0, h);
  noStroke();
  int fillIndex = round(random(0, p.length - 2));

  
  fill(color(p[fillIndex], 1));
  noStroke();
  bezier(x1, y1, x2, y2, x3, y3, x4, y4);  
  strokeWeight(random(.5, 1));
  stroke(color(p[fillIndex], 1));
  line(x1, y1, x2, y2);
    
  
  fill(color(p[(fillIndex + 2) % (p.length - 2)], 1));
  noStroke();
  bezier(x3, y3, x4, y4, x1, y1, x2, y2); 
  strokeWeight(random(.5, 1));
  stroke(color(p[(fillIndex + 3) % (p.length - 2)], 1));  
  line(x3, y3, x4, y4);    
  popMatrix();

}
