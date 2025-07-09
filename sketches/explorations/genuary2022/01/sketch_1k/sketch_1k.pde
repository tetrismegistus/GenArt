void setup() {
  size(1000, 1000);  
  colorMode(HSB, 360, 100, 100, 1);
  blendMode(SUBTRACT);
  float hueBack = random(360);
  background(hueBack, random(10, 100), 80);
  stroke((hueBack + 180) % 360 , random(50, 100), 30);
  noStroke();
  noLoop();
}


void draw() {
  for (int i = 0; i < 5000; i++) {
    drawSomething();
  }
  for (int i = 0; i < 5000; i++) {
    drawSomethingElse();
  }
  save("test.png");
}


void drawSomething() {
  fill(random(255), random(255), random(255));
    
    float x = (randomGaussian() + (width/2)) * 100  % width;
    float y = (randomGaussian() + (height/2)) * 100  % height;
    square(x, y, randomGaussian() * 5);
  
  
}


void drawSomethingElse() {
  fill(random(255), random(255), random(255), random(100, 150));
  
  
    
    float x = random(width);
    float y = random(height);
    //noFill();
    //stroke(random(255), random(255), random(255));
    circle(x, y, 15 - dist(width/2, height/2, x, y)/ 50);
  
  
  
}
