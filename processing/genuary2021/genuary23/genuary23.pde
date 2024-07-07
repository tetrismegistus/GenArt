int[] p = {#2a9d8f, #e9c46a, #f4a261, #e76f51};
int sz;

void setup() {
  size(1000, 1000);
}

void draw() {
  background(color(#264653));
  //noFill();
  fill(255, 0, 0, 100);
  sz = width / 10;
  for(int y = 0; y < height; y += sz) {
    for(int x = 0; x < width; x += sz) {
      squig(x, y, sz, sz);
    }
  }
  save("gen.png");
  

  noLoop();
}


void squig(float x, float y, float w, float h) {
  noFill();
  pushMatrix();
  translate(x, y);
  
  stroke(color(p[round(random(0, p.length - 1))], 100));
  if (random(0, 1) > .3) {
    noStroke();
  }
  
  
    rect(0, 0, w, h);
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
  
  int fillIndex = round(random(0, p.length - 1));
  
  fill(color(p[fillIndex], 100));
  noStroke();
  bezier(x1, y1, x2, y2, x3, y3, x4, y4);  
  strokeWeight(random(.5, 1));
  stroke(color(p[fillIndex], 100));
  line(x1, y1, x2, y2);
    
  
  fill(color(p[(fillIndex + 2) % (p.length - 1)], 100));
  noStroke();
  bezier(x3, y3, x4, y4, x1, y1, x2, y2); 
  strokeWeight(random(.5, 1));
  stroke(color(p[(fillIndex + 3) % (p.length - 1)], 100));  
  line(x3, y3, x4, y4);    
  popMatrix();

}
