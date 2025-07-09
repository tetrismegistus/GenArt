String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

ArrayList<Float> xPoints = new ArrayList<Float>();

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);

  for (int j = 0; j < 200; j++) {


    xPoints.add(width/2 + randomGaussian() * 100);
  }
}


void draw() {

  background(#E0C9A6);
  float mark1 = random(100, 150);
  float mark2 = random(200, 250);
  float step = random(10, 20);

  for (float y = 50; y < height - 50; y+=step) {
    step = random(10, 20);
    for (float xP : xPoints) {
      strokeWeight(random(.1, 2));
      stroke(360, 100, random(30));
      noFill();
      float offset = random(-2, 2);
      if (y > mark1 && y < mark2) {
        offset += random(10, 20);
      }
      circle(xP + offset, y, random(2, 3));
    }
  }

  save(getTemporalName("", ".png"));
  noLoop();
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));
}


String getTemporalName(String prefix, String suffix) {
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}
