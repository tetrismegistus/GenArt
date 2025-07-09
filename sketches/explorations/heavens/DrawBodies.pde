PVector drawSun() {
  
  PVector sun = PVector.fromAngle(sunTheta).mult(width * .45).add(width/2, height/2);
 
  drawStars();
  int d = 0;
  for (float theta = 0; theta < TWO_PI; theta += radians(3)) {
    float t = spokeDeltas.get(d) + theta; 
    float x = (width * 1.5) * cos(t);
    float y = (height * 1.5) * sin(t);
    line(sun.x, sun.y, x, y);
    d++;
  } 

  fill(#FFFFFF);
  float innerSpokeRad = width/5;
  
  stroke(0);
  strokeWeight(1.5);
  for (float theta = radians(5); theta < TWO_PI; theta += radians(15)) {
    PVector v = PVector.fromAngle(theta);
    PVector v2 = PVector.fromAngle(theta + radians(15));    
    PVector v3 = PVector.fromAngle(theta + radians(7.5));
    v.mult(innerSpokeRad/2);
    v.add(sun.x, sun.y);
    v2.mult(innerSpokeRad/2);
    v2.add(sun.x, sun.y);
    v3.mult(innerSpokeRad/1.2);
    v3.add(sun.x, sun.y);
    triangle(v.x, v.y, v2.x, v2.y, v3.x, v3.y);
    point(v.x, v.y);
  }
  noStroke();
  circle(sun.x, sun.y, innerSpokeRad * 1.01);
  
  
  stroke(0);
  strokeWeight(1.5);
  circle(sun.x, sun.y, width/6);
  for (int i = 0; i < 5000; i++) {
    PVector rp = new PVector(sunSpots[i].x * (width/6)/2 + sun.x, sunSpots[i].y * (width/6)/2 + sun.y);
    point(rp.x, rp.y);    
  }  
  return sun;
}

void drawEarth(PVector sun) {
  PVector earth = new PVector(width/2, height/2);    
  PGraphics mask = createGraphics(width, height, P2D);  
  mask.beginDraw();
  
  mask.background(0);
  mask.fill(255);
  mask.circle(earth.x, earth.y, width/3 + 5);  
  mask.endDraw();
  
  //eBack.mask(mask);  
  
  PGraphics shaderLayer = createGraphics(width, height, P2D);
  shaderLayer.beginDraw();
  shaderLayer.endDraw();
  shaderLayer.beginDraw();
  shaderLayer.image(eBack, 0, 0);
  gradientShader.set("angle", (float) sunTheta);
  shaderLayer.filter(gradientShader);
  shaderLayer.endDraw();
  shaderLayer.mask(mask);
  image(shaderLayer, 0, 0);

  noFill();
  strokeWeight(1.5);
  int numCircles = 20;
  float maxRadius = (width/3 + 5)/2;

  for (int i = 0; i < numCircles; i++) {
    float t = (float)i / (numCircles - 1);
    // Use a square function to adjust the spacing
    float radius = maxRadius * (1 - sq(t - 1));;
    ellipse(width/2, height/2, radius * 2, radius * 2);
  }
  strokeWeight(1.5);
  circle(earth.x, earth.y, width/3 + 5);
}

void drawMoon() {
  PVector moon = PVector.fromAngle(moonTheta).mult(width * .25).add(width/2, height/2);
  circle(moon.x, moon.y, width/12);
  
  for (int i = 0; i < 1000; i++) {
    PVector rp = new PVector(moonSpots[i].x * width/24 + moon.x, moonSpots[i].y * width/24 + moon.y);
    point(rp.x, rp.y);    
  } 
  
  
  
  noFill();
  
  //circle(shadow.x, shadow.y, width/12);
  
  
}


void drawStars() {
  circle(width/2, height/2, width/2 + width * .45);
  circle(width/2, height/2, width/2 + width * .35);
  float row1r = (width/2 + width * .42) / 2;
  for (float t = 0; t < TWO_PI; t+= radians(5)) {
    float x = (row1r) * cos(t) + width/2;
    float y = (row1r) * sin(t) + height/2;
    star(x, y, 8, 6);    
  }
  
  
  float row2r = (width/2 + width * .38) / 2;
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(3));
  for (float t = 0; t < TWO_PI; t+= radians(5)) {
    float x = (row2r) * cos(t);
    float y = (row2r) * sin(t);
    star(x, y, 8, 6);    
  }
  popMatrix();
  
  
}


void star ( float cx, float cy, float radius, int n) {
  // draw a star at <cx, cy> of radius with n points
  float delta = 2*PI/n;
  float idelta = delta/2;
  float iRadius = radius/2;
  float theta = 0.0;
  fill(#FFFFFF);
  beginShape();
  for (float i = 0; i < n; i++ ) {
    vertex(cx + radius*cos(theta), cy + radius*sin(theta));
    vertex(cx + iRadius*cos(theta+idelta), cy + iRadius*sin(theta+idelta));
    theta += delta;
  }
  endShape(CLOSE);
}
