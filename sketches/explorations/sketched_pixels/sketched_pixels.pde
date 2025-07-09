PImage inputImage;
int skipSize = 25;
int calls = 0;
long lastTime;

void setup() {
  size(1536, 2048);
  inputImage = loadImage("andria2.jpeg");
  colorMode(HSB, 360, 100, 100, 1);
  //blendMode(SUBTRACT);
  //inputImage.filter(GRAY);
  rectMode(CENTER);
  ellipseMode(CENTER);
  noLoop();
  noFill();  
}


void draw() {
  background((20 + 180) % 360, 20, 100);
  

  for (int y = 100; y < inputImage.height - 100; y+=50) {
    for (int x = 100; x < inputImage.width - 100; x+=20) {      
      for (int i = 0; i < 1; i++) {
        int modIdxX = x;
        int modIdxY = y;
        
        color pix = inputImage.pixels[index(modIdxX, modIdxY)];
      
        
      
      float hue = hue(pix);
      float brt = brightness(pix);
      float sat = saturation(pix);
      //noStroke();
      
      fill(hue, brt, sat, random(.5));
      //fill(hue, brt, sat, .5);
          
      
      
        float cAmt = 5;
        float mag = 1;
        float c1X = constrain(randomGaussian() * 10, -cAmt, cAmt);
        float c1Y = constrain(randomGaussian() * 10, -cAmt, cAmt);

        //beginShape();
        
        myLine(modIdxX + c1X, modIdxY + c1Y, modIdxX+c1X, modIdxY+c1Y+skipSize * 2, 1, pix);
        
        
        //quad(x + c1X, y + c1Y, x+skipSize+c2X, y+c2Y, x+skipSize+c3X, y+skipSize + c3Y, x + c4X, y+skipSize + c4Y);
        //endShape();
      
      
      }
      
      
    }
  }
       
  
  
  
          

  save(getTemporalName("maze_",".png"));
  //save("test.png");
}

void mousePressed() {
  color hover = inputImage.pixels[index(mouseX, mouseY)];
  float hue = hue(hover);  
  float sat = saturation(hover);  
  float brt = brightness(hover);
  println(hue + " " + sat + " " + brt); 

}


int index(int x, int y) {
  return x + y * inputImage.width;
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

float slope(float x1, float y1, float x2, float y2)
{
    return (y2 - y1) / (x2 - x1);
}


void myLine(float x1, float y1, float x2, float y2, float sw, color fc) {
  sw = constrain(sw, 0, 1);
  sw = map(sw, 0, 1, 0, 20);
  float fhue = hue(fc);
  float fbrt = brightness(fc);
  float fsat = saturation(fc);
  noFill();
  float sl = slope(x1, y1, x2, y2);

  
  for (float j = -sw; j < sw; j+= .5) {
    
    float x1adj = random(-1, 1) + x1;
    float x2adj = random(-1, 1) + x2;
    float y1adj = random(-1, 1) + y1;
    float y2adj = random(-1, 1) + y2;
    beginShape();
    if (sl == 0.) {
        curveVertex(x1adj + j, y1adj);      
    } else {
        curveVertex(x1adj, y1adj +j); 
    }
    
    
    float lngth = sqrt(sq(x2 - x1) + sq(y2 - y1));  
    for (int i = 0; i <= lngth; i+=1) {
      float mod = randomGaussian();
      float x = lerp(x1adj, x2adj, i/lngth);
      float y = lerp(y1, y2, i/lngth);
      
      
      if (sl == 0.) {
        y +=j;      
      } else {
        x +=j; 
      }
      
      
      color adjFc = color(fhue, fsat, fbrt + constrain(randomGaussian() + 20, 10, 40));
      
      stroke(adjFc, random(.1, 1));
      strokeWeight(constrain(.9 + mod, .1, 1));
      if (sl == 0.) {
        curveVertex(x, y + constrain(mod, -1, 1));
       
      } else {
        curveVertex(x + constrain(mod, -1, 1), y);
         
      }
          
    }
    
    if (sl == 0.) {
        curveVertex(x2adj + j, y2adj);      
    } else {
        curveVertex(x2adj, y2adj + j); 
    }
    
    
    endShape();
 
  }
}
