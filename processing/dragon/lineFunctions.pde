float slope(float x1, float y1, float x2, float y2)
{
    return (y2 - y1) / (x2 - x1);
}

void neonLine(float x1, float y1, float x2, float y2, float h) {
  
  float s = 50;  
  float mag = 10;
  float limit = 10;
  
  if (slope(x1, y1, x2, y2) == 0) {
    
    for (int i = 0; i < 5; i++) {
      float mod = 0;
      float mod1 = 0;
      
      float bi = map(i, 0, 5, 100, 0);
      stroke(color(h, s, bi), random(1));
      line(x1 + mod, i + y1, x2 + mod1, i + y2);
    }
    for (int i = 0; i < 5; i++) {
      float mod = 0;
      float mod1 = 0;
      float bi = map(i, 0, 5, 100, 0);
      stroke(color(h, s, bi), random(1));
      line(x1 + mod,  y1 - i, x2 + mod1, y2 - i);
    }
  } else {
    for (int i = 0; i < 5; i++) {
      float mod = 0;
      float mod1 = 0;
      float bi = map(i, 0, 5, 100, 0);
      stroke(color(h, s, bi), random(1));
      line(x1 + i, y1 + mod, x2 + i, y2 + mod1);
    }
    for (int i = 0; i < 5; i++) {
      float mod = 0;
      float mod1 = 0;
      float bi = map(i, 0, 5, 100, 0);
      stroke(color(h, s, bi), random(1));
      line(x1 - i,  y1 + mod, x2 - i, y2 + mod1);
    }
  
  }
  
}
