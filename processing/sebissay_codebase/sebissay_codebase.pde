int seed = 12051993;
float scale = 1 / 200.;

void setup()
{
  randomSeed(seed);
  noiseSeed(int(random(MAX_INT)));

  size(1920, 1080);
  background(245);
  stroke(17.5, 15, 15, 10);
}

void draw()
{
  for (int i = 0; i < 100; i++)
  {
    PVector p = new PVector(width * random(random(1), 1), random(height));
    for (int k = 0; k < 200; k++)
    {
      point(p.x, p.y);
      float angle = noise(10. * noise(p.x * scale, p.y * scale), .1 * noise(p.x * scale, p.y * scale, random(min(width, height)) * scale));
      p.add(PVector.fromAngle(TWO_PI * int(27 * p.x / width * angle) / (2 + 5 * p.x / width)).mult(.5));

      if (!(p.x > 0 && p.x < width && p.y > 0 && p.y < height))
      {
        break;
      }
    }
  }


}
