String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float off = 0.01;
float PL = 2;

float ox, oy;
float border = .1;

float ix, iy;
ArrayList<PVector> contourPoints = new ArrayList<PVector>();
//OpenSimplexNoise noise;


void setup() {
  size(1000, 1000);
  colorMode(HSB, 360, 100, 100, 1);
  
  //noise = new OpenSimplexNoise((long) random(0, 255));
}


void draw() {
  background(#c2f2f2);
  
  
  //noFill();
  for (int i = 50; i < width- 50; i+=10) {
    dropAgent(i, height - 50);
  }
  
  
    
  fill(#E0E1E4);
  noStroke();
  //rect(0, 0, width, 50);
  //rect(0, height - 50, width, 50);
  //rect(0, 0, 50, height);
  //rect(width - 50, 0, 50, height);
  
  stroke(0, 0, 0, .5);
  strokeWeight(.1);
  noFill();
  for (int x = 50; x < width - 50; x += 50) {
    for (int y = 50; y < height - 50; y += 50) {
      rect(x, y, 50, 50);
    }
  }
  
  textSize(10);
  fill(0);
  /*
  int degreesLabel = (int) random(70);
  for (int x = 50; x <width - 50; x += 50) {
    text(degreesLabel+ "°", x, 48); 
    degreesLabel++;
    
  }
  
  
  degreesLabel = (int) random(70);
  pushMatrix();
  translate(47, 950);
  rotate(radians(270));
  for (int x = 0; x <900; x += 50) {
    text(degreesLabel + "°", x, 0); 
    degreesLabel++;
    
  }
  popMatrix();
  
  strokeWeight(1);
  pushMatrix();
  translate(50, 50);
  drawBorder();
  popMatrix();
  
  pushMatrix();
  translate(50, 950);
  drawBorder();
  popMatrix();
  
  pushMatrix();
  translate(50, 50);
  rotate(radians(90));
  drawBorder();
  popMatrix();
  
  pushMatrix();
  translate(950, 50);
  rotate(radians(90));
  drawBorder();
  popMatrix();
  */
  noLoop();
}

void drawBorder() {
  for (int x = 0; x < 900; x+= 50) {
    fill(#ad776d);
    stroke(#ad776d);
    rect(x, 0, 25, 2);
    fill(0);
    stroke(0);
    rect(x + 25, 0, 25, 2);
  }
}


void dropAgent(float x, float y) {
  
  float agentX = x;
  float agentY = y;
  float goalNoise = .5;
  
  //for (int i = 0; i < 25; i++){
   while (noise(agentX*off, agentY*off) < goalNoise-.01 && noContourNear(agentX, agentY)) {
      agentY--;
   }
    
  fill(#f5f3dc);
  strokeWeight(.1);
  
  if (noContourNear(agentX, agentY)) {
    stroke(#ad776d);    
    renderContour(agentX, agentY);    
  }
  
  noFill();
  for (float ny = agentY; ny > 50; ny--){
    loadPixels();
    int idx = (int)agentX + (int)ny * height;
    if (pixels[idx] == #f5f3dc && noContourNear(agentX, ny)) {
      stroke(#ad776d);
      noFill();
      strokeWeight(.1);
      //renderContour(agentX, agentY);
    } else {
      point(agentX, ny);
    }
  }
 
  
}

boolean noContourNear(float x, float y) {
  boolean valid = true;
  loadPixels();
  for (int j = 1; j < 15; j++) {
    for (int nA = 0; nA < 360; nA+=1) {
      float nX = j * cos(radians(nA)) + x;
      float nY = j * sin(radians(nA)) + y;
      int idx = (int)nX + (int)nY * width;

      if (idx > 0 && idx < width * height) {
        if (pixels[idx] == #ad776d) {
          valid = false;
          break;
        }
      }
    }
    if (!valid) {
      break;
    }
  }
  return valid;
}


void renderContour(float nx, float ny)
{
  ix = nx; 
  iy = ny;
  border = (float) noise(ix*off,iy*off);  

  beginShape();
  float d = 0; 
  float sx = ix; 
  float sy = iy;
  
  for(int i=0;i<50000;i++)
  {
    float od = d ; 
    float ox = ix ; 
    float oy = iy;
    
    // for the reverse of the direction (od + HALF_PI)
    // if direction is greater than the original and not near the goal height
    //    or we have traveled half a circle from the original direction
    //    we're done with the loop.  Other wise subtract .17 radians 
    //    from the direction
    for (d=od+HALF_PI; (d>od-HALF_PI && !nn()) || d == od+HALF_PI; d-=.17) {
      // in this way, once nn exaluates to true we can be sure we've found
      // the next point on the contour
      ix = ox+PL*cos(d) ; 
      iy = oy-PL*sin(d);
    }
    vertex(ix,iy);

    if (dist(ix,iy,sx,sy) < PL && i > 1) {
      if (i > 4) {
        endShape(CLOSE);
      } 
      break;
    }
  }
  noLoop();
}




void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
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

boolean nn() {
  return(abs(noise(ix*off,iy*off)-border) < .0035);
}
