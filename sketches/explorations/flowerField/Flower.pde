class Flower {
  float x0, x1, y0, y1, x2, y2, x3, y3;
  float curveFactor, budSize;
  color budColor;
  color stemColor;
  // Definition of cubic Bezier curve startPoint (P0), controlPoints(P1 & P2) and endPoint(P3)
  // Thanks Sebastian
  Flower(float r, float x, color bc, color sc) {
    budSize = r;    
    float endy2 = random(100, height);
    float curveAdj = map(endy2, 100, 600, 0, 10);    
    curveFactor = r * curveAdj;    
    x0 = x;
    y0 = height;
    x1 = x + 0.25 * curveFactor;
    y1 = height - 200;
    x2 = x + curveFactor;    
    y2 = height - endy2;
    x3 = x + 3 * curveFactor;
    float y3Adj = map(endy2, 0, endy2, 0, 100);
    y3 = height - (endy2 + y3Adj);
    budColor = bc;
    stemColor = sc;
  }
  
  void render() {
    //draw stem
    float stemBrushWidth = 2;
    Brush stemBrush = new Brush(stemBrushWidth, 0, 0, stemColor);
    for (float t = 0; t <= 1; t += BRUSH_STEP) {
      stemBrush.cx = getXBezPoint(t);
      stemBrush.cy = getYBezPoint(t);      
      stemBrush.render();
    }
    if (random(1) > .8) {
      drawSpiral();
    } else {
      float t = 1;
      float cx = getXBezPoint(t);
      float cy = getYBezPoint(t);
      polygon(cx, cy, (int)random(3, 15), budSize * 3, budColor);
    }
  }  
  
  void drawSpiral() {
    float r = 0;
    float b = .027;
    float t = 1;
    float cx = getXBezPoint(t);
    float cy = getYBezPoint(t);
    float spiralBrushWidth = 3;
    Brush spiralBrush = new Brush(spiralBrushWidth, cx, cy, budColor);
  
  
    for (float i = 0; i < budSize * 100; i++) {
      r = .1 + b * radians(i);
      spiralBrush.render();                 
      spiralBrush.cx = spiralBrush.cx + cos(radians(i)) * r;
      spiralBrush.cy = spiralBrush.cy + sin(radians(i)) * r;
    }

 
  }
  
  float getYBezPoint(float t) {
    return pow(1 - t, 3) * y0 + 3 * sq(1 - t) * t * y1 + 3 * (1 - t) * sq(t) * y2 + pow(t, 3) * y3;
  }
  
  float getXBezPoint(float t) {
    return pow(1 - t, 3) * x0 + 3 * sq(1 - t) * t * x1 + 3 * (1 - t) * sq(t) * x2 + pow(t, 3) * x3;  
  }
  
  
}
