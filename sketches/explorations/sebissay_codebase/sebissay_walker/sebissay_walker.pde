float scale = 1 / 250.;
OpenSimplexNoise noise;
ArrayList<Walker> walkers = new ArrayList<Walker>();

void setup()
{
  
  //noiseSeed(1); // fixed seed so that we can compare our results throughout our experimentations
  noise = new OpenSimplexNoise((long) 1);
  randomSeed(1);
  size(4288, 2848);
  colorMode(HSB, 360, 100, 100, 1);
  blendMode(SUBTRACT);
  float hueBack = random(360);
  background(hueBack, random(50, 100), 80);
  stroke((hueBack + 180) % 360 , random(50, 100), 30);

  for (int i = 0; i < width; i += 20)
  {
    for (int j = 0; j < height; j += 20)
    {

      walkers.add(new Walker(random(width), random(height), 4));
    }
  }

}


void draw() {
  for (Walker w : walkers) {
    if (w.pos.x > 0 && w.pos.x < width && w.pos.y > 0 && w.pos.y < height)
    {
       strokeWeight(random(0.05, 1));
       w.draw();
       w.move();
    }
    
  }
  
  if (frameCount == 2000)
  {
    noLoop();
    saveFrame("render.png");
    println("done");
  }
}
