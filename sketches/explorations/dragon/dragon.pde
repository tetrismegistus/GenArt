void setup() {
  size(1500, 1200);
  blendMode(SCREEN);
  colorMode(HSB, 360, 100, 100, 1);
}

void draw() {
  background(0);
  translate(width - width/4, height/3);
  Dragon(30, 7, random(360), 90);
  save("test.png");
  noLoop();
}


void Dragon(float sz, int level, float h, float angl) {
  float s = 50;
  color c = color(color(h, s, 100),1);
  stroke(c);
  strokeWeight(10);
  noFill();

  if (level == 0) {
    float toss = random(1);
    neonLine(0, 0, sz, 0, h);
    if (random(1) > .5) {
      stroke(c, random(1));
      strokeWeight(random(10));
      circle(sz, 0, random(50));
    } else {
      
      if (toss > 0 && toss < .25) {
        stroke(c, random(1));
        strokeWeight(random(10));
        arc(sz, 0, 100, 100, radians(90), radians(180));
      } 
      toss = random(1);
      if (toss > .25 && toss < .50) {
        stroke(c, random(1));
        strokeWeight(random(10));
        arc(sz, 0, 100, 100, radians(180), radians(270));
      } 
      toss = random(1);
      if (toss > .50 && toss < .75) {
        stroke(c, random(1));
        strokeWeight(random(10));
        arc(sz, 0, 100, 100, radians(270), radians(360));
      } 
      toss = random(1);
      if (toss > .75 && toss < 1) {
        stroke(c, random(1));
        strokeWeight(random(10));
        arc(sz, 0, 100, 100, radians(0), radians(90));
      }

    }
    if (toss > .25) {
      translate(sz, 0);
      neonLine(0, 0, 0, sz, h);
      stroke(c, random(1));
      strokeWeight(random(10));
      circle(sz, 0, random(50));
    }
      translate(0, sz);
      neonLine(sz, 0, 0, 0, h);
      stroke(c, random(1));
      strokeWeight(random(10));
      circle(sz, 0, random(50));
        if(random(1) > .5) {
          stroke(c, random(1));
          strokeWeight(random(10));
          circle(0, sz, random(50));
        }
    
    translate(sz, 0);
    
  } else {
    Dragon(sz, level-1, h, -abs(angl));
    rotate(radians(angl));
    Dragon(sz, level-1, h, abs(angl));
  }
}
