import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

PostFX fx;
PGraphics pg;

int l = 40;
int[] colors = {#C9184A,
#FF4D6D,
#FFB3C6,
#FFF4EE};

void setup() {
  size(2000, 2000, P2D);
  fx = new PostFX(this);
 
  pg = createGraphics(2000, 2000);
  pg.beginDraw();
  pg.background(#000000);
  //pg.blendMode(SCREEN);
  for (int y = 0; y < height; y += l) {
    for (int x = 0; x < width; x += l) {
    
      if (random(1) > .5) {
        variSegLine(x, y, x+l, y+l);
      } else {
        variSegLine(x+l, y, x, y+l);
      }
      
    }
    
  }
  pg.endDraw();
}

void draw() {
  
  image(pg, 0, 0);
  filter(BLUR, 2);

  
    fx.render()
    .rgbSplit(100)
    //.bloom(10, 10, 10)
    .sobel()
    .compose();

  filter(DILATE);
  //filter(GRAY);
  save("out.png");
}

void variSegLine(float x1, float y1, float x2, float y2) {
  PVector v1 = new PVector(x1, y1);
  PVector v2 = new PVector(x2, y2);
  for (float i = 0; i <= 1; i+=.01) {
      float adj = constrain(i + randomGaussian() / 5, i, 1);
      PVector lp1 = PVector.lerp(v1, v2, i);
      PVector lp2 = PVector.lerp(v1, v2, adj);
      pg.strokeWeight(random(3, 10)); 
      pg.stroke(pickColor(), random(100, 255));
      pg.line(lp1.x, lp1.y, lp2.x, lp2.y);
      i = adj;
      

    }
}

int pickColor() {
  int i = round(random(0, colors.length  - 1));
  return colors[i];
}
