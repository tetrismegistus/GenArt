int calls = 0;
long lastTime;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
  blendMode(MULTIPLY);
}


void draw() {
  
  noFill();
  color fc = color(random(360), random(20, 100), random(30, 70)); 
  float fhue = hue(fc);
  float fbrt = brightness(fc);
  float fsat = saturation(fc);
  float sw = .1;
  background(color(fhue + 160 % 360, 10, 100));
  for (int i = 100; i < height - 100; i+= 40) {
    fhue = hue(fc);
    fc = color(fhue + 5 % 360, fbrt, fsat); 
    float mod1 = constrain(randomGaussian(), -10, 10);
    float mod2 = constrain(randomGaussian(), -10, 10);
    drawLine(100 + mod1, i, width - 100 + mod2, 100, fc, sw);
    sw += .1;
  }
  save(getTemporalName("lineStudy_",".png"));
  
  noLoop();
}


void drawLine(float x1, float y1, float x2, float y2, color fc, float sw) {
  float fhue = hue(fc);
  float fbrt = brightness(fc);
  float fsat = saturation(fc);
  sw = constrain(sw, 0, 1);
  sw = map(sw, 0, 1, 0, 20);
  
  for (float i = y1; i < y1+sw; i+= .5) {
    
    
    beginShape();
    for (float j = x1 + random(-3, 3); j < x2 + random(-3, 3); j+=1) {
     float mod = randomGaussian();
     color adjFc = color(fhue, fsat, fbrt + constrain(randomGaussian() + 20, 10, 40));
     stroke(adjFc, random(.1, 1));
     strokeWeight(constrain(.9 + mod, .1, 1));      
      
      curveVertex(j, i+ constrain(mod, -1, 1));
    
    }
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
