/*
SketchName: default.pde
 Credits: Literally every tutorial I've read and SparkyJohn
 Description: My default starting point for sketches
 */

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;
float max = 50;
void setup() {
  size(1800, 1800);
  colorMode(HSB, 360, 100, 100, 1);
  //blendMode(SCREEN);
  noLoop();
}

void draw() {
  background(350, 0, 100);
  noStroke();
  c1(width / 10, -height * .001, max, 0);


  save("output/"+getTemporalName(sketchName, saveFormat));
}

void c1(float x1, float y1, float r, float angle) {
  if (r < .5) return;

  float nextAngle = angle + radians(2); // constant angle step
  float x2 = x1 + cos(nextAngle) * 2 * r;
  float y2 = y1 + sin(nextAngle) * 2 * r;

  float second = angle + radians(120); // constant angle step
  float x3 = x1 + cos(second) * 2 * r;
  float y3 = y1 + sin(second) * 2 * r;

  c1(x2, y2, r * .97, nextAngle); // shrink + rotate
  c2(x3, y3, r * 2, second);
}


void c2(float x1, float y1, float r, float angle) {
  if (r < .1) return;

  noFill();
  float alpha = map(r, max, 1, 2, .8);
  fill(200, map(r, 0, max, 100, 0), map(r, 1, max, 30, 100), alpha);
  circle(x1, y1, r);

  float nextAngle = angle - radians(1); // constant angle step
  float x2 = x1 + cos(nextAngle) * 2 * r;
  float y2 = y1 + sin(nextAngle) * 2 * r;


  c2(x2, y2, r * .99, nextAngle); // shrink + rotate
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
