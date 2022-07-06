int spacing = 10;

void setup(){
  size(600, 600, P3D);
  ellipseMode(CORNER);
  colorMode(HSB);
}
void draw(){
  background(123, 80, 100);  
  for (int y = 0; y < height; y+=spacing) { 
    for (int x = 0; x < width; x+=spacing) {      
      for (int z = 0; z < height; z+= spacing) {
        float hue = map(sin(z), -1, 1, 0, 255);
        float saturation = map(dist(0, 0, x, y), 0, width/ 2, 0, 100);
        
        float alpha = map(z, 0, height, 255, 0);
        fill(hue, saturation, 255, alpha);
        rotate(radians(random(1)));
        //stroke(hue, 100, 100, alpha);
        pushMatrix();
        translate(x, y, z);
        circle(0, 0, spacing);
        popMatrix();
      }      
    }
  }
  save("gen1.png");
  noLoop();
}
