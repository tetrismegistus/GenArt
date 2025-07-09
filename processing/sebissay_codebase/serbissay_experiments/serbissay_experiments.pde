float scale = 1 / 50.;
int numberOfAngles = 4;
OpenSimplexNoise noise;

void setup()
{
  noiseSeed(1); // fixed seed so that we can compare our results throughout our experimentations
  noise = new OpenSimplexNoise((long) random(1));
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
  float hueBack = random(360);
  background(hueBack, random(50), 30);
  stroke((hueBack + 180) % 360 , random(50, 100), 100);
  
  noLoop();
}

void draw()
{
  for (int i = 0; i < width; i += 5)
  {
    for (int j = 0; j < height; j += 5)
    {
      PVector p = new PVector (i, j); // Instead of a fixed number of random points, we'll just work with points on a grid
      for (int k = 0; k < 200; k++)
      {
        point(p.x, p.y);
 
        float n = map((float) noise.eval(p.x * scale, p.y * scale), -1, 1, 0, 1);
        float angleMultiplier = floor(numberOfAngles * n) / float(numberOfAngles);
        float angle = TWO_PI * angleMultiplier;
        p.add(PVector.fromAngle(angle));
      }
    }
  }

  saveFrame("render.png");
  println("done");
}
