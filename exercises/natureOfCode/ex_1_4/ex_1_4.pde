void setup() {
  size(800, 800);
  background(123);
}

void draw() {
  float x = randomGaussian() * 100 + width/2;
  float y = randomGaussian() * 100 + height/2;
  fill(random(255), random(255), random(255));
  noStroke();
  circle(x, y, randomGaussian() * 10);
}
