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
        curveVertex(x, y + constrain(mod, -1, 1)); //<>//
       
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


void neonLine(float x1, float y1, float x2, float y2, float h) {
  
  float s = 100;  
  float mag = 10;
  float mod = constrain(randomGaussian() * mag, -10, 10);
    float mod1 = constrain(randomGaussian() * mag, -10, 10);
  if (slope(x1, y1, x2, y2) == 0) {
    
    for (int i = 0; i < 10; i++) {
      
      float bi = map(i, 0, 10, 100, 0);
      stroke(color(h, s, bi));
      line(x1 + mod, i + y1, x2 + mod1, i + y2);
    }
    for (int i = 0; i < 10; i++) {
      float bi = map(i, 0, 10, 100, 0);
      stroke(color(h, s, bi));
      line(x1 + mod,  y1 - i, x2 + mod1, y2 - i);
    }
  } else {
    for (int i = 0; i < 10; i++) {
      float bi = map(i, 0, 10, 100, 0);
      stroke(color(h, s, bi));
      line(x1 + i, y1 + mod, x2 + i, y2 + mod1);
    }
    for (int i = 0; i < 10; i++) {
      float bi = map(i, 0, 10, 100, 0);
      stroke(color(h, s, bi));
      line(x1 - i,  y1 + mod, x2 - i, y2 + mod1);
    }
  
  }
  
}
