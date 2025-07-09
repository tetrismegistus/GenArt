long lastTime;
int calls;
color[] p = new color[5];
OpenSimplexNoise noise;
int[] morning = {#B86B77};



void initP() {
  //courtesy of @kaih.art
  int hue = (int) random(0, 360);
  int sat = (int) random(0, 100);
  for (int i = 0; i < 5; i++) {
   
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

void setup() {
  noise = new OpenSimplexNoise();
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1.);
  background(p[4]); 
  ellipseMode(CENTER);
  initP();

  noLoop();
}

void draw() {
  noStroke();
  background(0);
  
  fill(255);
  ellipse(width/2, height/2, width - 100, height - 100);
  PImage mask = createImageFromScreen(width, height, 0, 0);
 
  color skyColor1 = p[0]; 
  color skyColor2 = p[3];
  for (int y = 0; y < height/2 + height/4; y++) {
    float amount = map(y, 0, height/2 + height/4, 0, 1);
    color strokeColor = lerpColor(skyColor1, skyColor2, amount);
    stroke(strokeColor);  
    line(0, y, width, y); 
  }
  noStroke();
  
  color topCol = p[4]; 
  color bottomCol = color(77, 106, 126);
  
  int start = 400 + (int) randomGaussian();
  int layers = (int) random(1, 20); 
  for (int y = start; y < height; y += layers) {
    layers = (int) random(1, 20);
  

    float amount = map(y, height/2, height/2 + height/4, 0, 1);
    fill(lerpColor(topCol, bottomCol, amount));

    PerlinPeaks(0, y, random(0.5, 0.5), width, height, 3, (int) random(30, 100));
  }
  
  PImage img = createImageFromScreen(width, height, 0, 0);
  img.mask(mask);
  
  background(p[4]);
  image(img, 0, 0);
  img = createImageFromScreen(width, height, 0, 0);
  //img.filter(THRESHOLD,1);
  //img.filter(BLUR,15); //wider blur
  image(img, 0, 0);
  save(getTemporalName("impMount_",".png"));
}

void PerlinPeaks(int x1, int y1, float inc, int w, int h, int octaves, int variance) {  
    
  float xoff = x1;
  float yoff = y1;
  beginShape();
  for (int x = x1; x <= x1 + w; x+=10) {
    for (int y = y1; y < height; y+=10) {
      float n = (float) noise.eval(xoff, yoff);
      
      vertex(x, n,  , 1, y1+variance, y1-variance));
      yoff += inc;
    }
    xoff += inc;    
  }
  vertex(x1 + w, y1 + h);
  vertex(x1, y1 + h);
  //vertex(x1, map(noise(0), 0, 1, y1+variance, y1-variance));
  endShape();  
}


PImage createImageFromScreen(int w, int h, int x, int y){
  PImage img = createImage(w, h, HSB);
  img.loadPixels();
  int loc = x + y * width;
  loadPixels();
  for (int i = loc; i < img.pixels.length; i++) {
    img.pixels[i] = pixels[i];
  }
  img.updatePixels();
  return img;  
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == 's') {
      save(getTemporalName("impMount_",".png"));
    }
    
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
