void drawNoiseBackground() {
  noiseBackground = createGraphics(width, height, P2D);
  noiseBackground.beginDraw();
  noiseBackground.endDraw();
  noiseBackground.beginDraw();
  //noiseBackground.background(0);
  noiseBackground.fill(255);
  
  
  for (float x = 0; x < width; x++) {
    for (float y = 0; y < height; y++) {
      float n = getNoise(x * .003, y * .003, 8, zoff);
      float mn = map(n, -1, 1, 100, 175);
      noiseBackground.stroke(mn);
      noiseBackground.point(x, y);
    }
  }
  noiseBackground.endDraw();
}


void drawEarthBackground() {
  eBack = drawArchipelago(width/2 - (width/3)/2, height/2 - (width/3)/2, width/3, width/3);
}


PGraphics drawArchipelago(float x_, float y_, float w_, float h_) {  
  field = new float[cols][rows];  
  PGraphics mask = createGraphics(width, height, P2D);
  
  mask.beginDraw();
  mask.endDraw();
  mask.beginDraw();
  
  mask.background(#b6b6b6);
   
  mask.image(noiseBackground, 0, 0);
  mask.stroke(0);
  mask.strokeWeight(1.5);
  mask.noFill();
  
  mask.pushMatrix();
  mask.translate(x_, y_);
  float xoff = 0;  
  for (int i = 0; i < cols; i++) {
    xoff += inc;
    float yoff = 0;
    for (int j = 0; j < rows; j++) {
      
      field[i][j] = (float) getNoise(xoff, yoff, 8, zoff);
      yoff += inc;
    }
  }
      
   for (int i = 0; i < w_; i++) {
    for (int j = 0; j < h_; j++) {
      float x = i * rez;
      float y = j * rez;
      PVector a = new PVector(x + rez*0.5, y);
      PVector b = new PVector(x + rez, y + rez*0.5);
      PVector c = new PVector(x + rez*0.5, y+rez);
      PVector d = new PVector(x, y + rez*0.5);
      
            
      strokeWeight(2);
      
      int state = (int) getState(ceil(field[i][j]), 
                           ceil(field[i+1][j]),
                           ceil(field[i+1][j+1]),
                           ceil(field[i][j+1]));
                           
      switch (state) {
      case 1:  
        line(c, d, mask);
        break;
      case 2:  
        line(b, c, mask);
        break;
      case 3:  
        line(b, d, mask);
        break;
      case 4:  
        line(a, b, mask);
        break;
      case 5:  
        line(a, d, mask);
        line(b, c, mask);
        break;
      case 6:  
        line(a, c, mask);
        break;
      case 7:  
        line(a, d, mask);
        break;
      case 8:  
        line(a, d, mask);
        break;
      case 9:  
        line(a, c, mask);
        break;
      case 10: 
        line(a, b, mask);
        line(c, d, mask);
        break;
      case 11: 
        line(a, b, mask);
        break;
      case 12: 
        line(b, d, mask);
        break;
      case 13: 
        line(b, c, mask);
        break;
      case 14: 
        line(c, d, mask); 
        break;
      }

    }    
  }  
  mask.popMatrix();  
  //mask.filter(gradientShader);
  //mask.filter(noiseShader);
  mask.endDraw();
  return mask;
}
