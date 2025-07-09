int l = 80;
int[] colors = {#FAF0CA, #F4D35E, #EE964B, #F95738};

void setup() {
  size(1080, 2160);
}

void draw() {
  
  background(#0D3B66);
  for (int y = 0; y < height; y += l) {
    for (int x = 0; x < width; x += l) {
    
      if (random(1) > .5) {
        variSegLine(x, y, x+l, y+l);
      } else {
        variSegLine(x+l, y, x, y+l);
      }
      
    }
    
  }
  filter(BLUR, 2);
  save("test.png");
  noLoop();
  

}

void variSegLine(float x1, float y1, float x2, float y2) {
  PVector v1 = new PVector(x1, y1);
  PVector v2 = new PVector(x2, y2);
  for (float i = 0; i <= 1; i+=.01) {
      float adj = constrain(i + randomGaussian() / 5, i, 1);
      PVector lp1 = PVector.lerp(v1, v2, i);
      PVector lp2 = PVector.lerp(v1, v2, adj);
      strokeWeight(random(.5, 10)); 
      stroke(pickColor(), random(100, 255));
      line(lp1.x, lp1.y, lp2.x, lp2.y);
      i = adj;
      

    }
}

int pickColor() {
  int i = round(random(0, colors.length  - 1));
  return colors[i];
}
