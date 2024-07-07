ArrayList<PVector> points = new ArrayList<PVector>();
float scale = 1 / 2000.;
int numberOfAngles =4;
OpenSimplexNoise noise;

void setup () {
  noise = new OpenSimplexNoise((long) random(MAX_INT));
  size(4288, 2848);
  for (int i = 0; i <= width; i++) {
    float t = pos_t(i); 
    PVector p = new PVector(pos_x(t) * 75, -pos_y(t) * 75);
    points.add(p);
  }  
  colorMode(HSB, 360, 100, 100, 1);
  float hueBack = random(360);
  background(hueBack, random(50), 15);
  stroke((hueBack + 180) % 360 , random(50, 100), 100);
}

void draw() {
  translate(width/2, height/2);
  for (int i = 0; i < points.size(); i++) {
    PVector p = points.get(i);
    for (int k = 0; k < 500; k++)
    {
      //strokeWeight(random(0.15, 1));
      point(p.x, p.y);
      float nv = map((float) noise.eval(p.x * scale, p.y * scale), -1, 1, 0, 1);
      float angleMultiplier = floor(numberOfAngles * nv) / float(numberOfAngles);
      float angle = TWO_PI * angleMultiplier;
      p.add(PVector.fromAngle(TWO_PI * (p.x / width * angle) / (2 + 5 * p.y / height)).mult(.5));

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


float pos_t (float n) {
  return lerp(-PI,PI,n/400);
}

float pos_x(float n){
  return 16*pow(sin(n),3);
}


float pos_y(float n){
  return 13*cos(n)-5*cos(2*n)-2*cos(3*n)-cos(4*n);
}
