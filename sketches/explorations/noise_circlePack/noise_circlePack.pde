int attempts = 500;
ArrayList<Circle> CIRCLES1 = new ArrayList<Circle>();
float scale = 1 / 200.;
color innerCol;
color outerCol;
OpenSimplexNoise noise;

void setup() {
  
  randomSeed(int(random(MAX_INT)));
  //noiseSeed(int(random(MAX_INT)));
  noise = new OpenSimplexNoise((long) random(0, 255));

  size(4288, 2848);
  colorMode(HSB, 360, 100, 100, 1);
  float firstHue = random(360); 
  innerCol = color(firstHue, random(64), 100);
  outerCol = color((firstHue + 180) % 360, random(78), 100);
  float bgHue = random(360);
  print(bgHue);
  background(bgHue, 50, 20);
  CIRCLES1 = PackCircles(1000000, CIRCLES1);
}


void draw() {       
  
  
  for (int i = 0; i < 100; i++)
  {
    PVector p = new PVector(random(width), random(height));
    
    for (int k = 0; k < 200; k++)
    {
      strokeWeight(random(.01, 1));
      point(p.x, p.y);
      float d;
      float angle;
      PVector newVector;
      
      angle = (float) noise.eval(noise.eval(p.x * scale, p.y * scale * 2), noise.eval(p.x * scale, p.y * scale, random(min(width, height)) * scale));
      newVector = PVector.fromAngle(TWO_PI * int(p.x / width * angle) / int((2 + 5 / height))).mult(.5);
      stroke(outerCol);        
      for (Circle c : CIRCLES1) {
        if (c.contains(new CompositePoint(p.x, p.y))) {
          d = dist(p.x, p.y, c.center.x, c.center.y);
          
          angle = (float) noise.eval(10. * noise.eval(p.x * scale, p.y * scale), 10. * noise.eval(p.x * scale, p.y * scale));
          newVector = PVector.fromAngle(TWO_PI * int(10 * p.x / width * angle) / (2 + 5 * p.y / height)).mult(.5);
          stroke(innerCol);
          break;
        }        
      }                
      p.add(newVector);

      if (!(p.x > 0 && p.x < width && p.y > 0 && p.y < height))
      {
        break;
      }
    }
  }
  
  if (frameCount == 2000)
  {
    noLoop();
    saveFrame("render.png");
    println("done");
  }

}
