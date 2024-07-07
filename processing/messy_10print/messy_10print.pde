int calls = 0;
long lastTime;

void setup() {
  size(1000, 1000);
  colorMode(HSB, 360, 100, 100, 1);
  blendMode(MULTIPLY);
}

void draw() {
    translate(height/2, height/2);
 rotate(PI/4.0);
 translate(-height/2, -height/2);
  color fc = color(random(360), random(20, 100), random(30, 70)); 
  float fhue = hue(fc);
  float fbrt = brightness(fc);
  float fsat = saturation(fc);
  //float sw = .1;
  background(color(fhue + 160 % 360, 10, 100));
  
  for (int x = 200; x < width - 200; x+=40) {
    fhue = hue(fc);
    fc = color(fhue + 5 % 360, fbrt, fsat);
    for (int y = 200; y < height - 200; y+=40) {
      
      if (random(1) > .5) {
        myLine(x, y, x+40, y+40, 1, fc);
      } else {
        myLine(x, y+40, x+40, y, 1, fc);
      }
    }
  }
  save(getTemporalName("lineStudy_",".png"));
  noLoop();
}


void myLine(float x1, float y1, float x2, float y2, float sw, color fc) {
  sw = constrain(sw, 0, 1);
  sw = map(sw, 0, 1, 0, 20);
  float fhue = hue(fc);
  float fbrt = brightness(fc);
  float fsat = saturation(fc);
  //noFill();
  fill(fc, random(.5, .8));
  
  for (float j = 0; j < sw; j+= .5) {
  
    float x1adj = random(-3, 3) + x1;
    float x2adj = random(-3, 3) + x2;
    beginShape();
    curveVertex(x1adj, y1 +j);
    float lngth = x2 - x1;    
    for (int i = 0; i <= lngth; i++) {
      float mod = randomGaussian();
      float x = lerp(x1adj, x2adj, i/lngth);
      float y = lerp(y1, y2, i/lngth) + j;
      color adjFc = color(fhue, fsat, fbrt + constrain(randomGaussian() + 20, 10, 40));
      
      stroke(adjFc, random(.1, 1));
      strokeWeight(constrain(.9 + mod, .1, 1)); 
      curveVertex(x, y + constrain(mod, -1, 1));    
    }
    curveVertex(x2adj, y2 + j);
    endShape();
 
  }
}

String getTemporalName(String prefix, String suffix){
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if(lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}
