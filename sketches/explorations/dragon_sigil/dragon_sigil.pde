PFont hebFont;
char[] chars = {'ל', 'ו', 'י', 'ת', 'ן'};
color[] cols = {color(127, 164, 166), color(245, 221, 154), color(178, 251, 113), color(233, 156, 99), color(143, 182, 149)};
int charIndex = 0;
int lineCharIndex = 1;
int charIndex3 = 2;


void setup() {
  size(6000, 3000);
  blendMode(SCREEN);
  colorMode(HSB, 360, 100, 100, 1);
  hebFont = createFont("Rubik-Regular.ttf", 80);
  textFont(hebFont);
}

void draw() {
  background(0);
  translate(width/4, height/1.5);
  Dragon(80, 10, random(360), 90);
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
    
    //neonLine(0, 0, sz, 0, h);
    
      stroke(c, random(1));
      strokeWeight(random(10));
      //circle(sz, 0, random(50));
      fill(cols[charIndex], 20);
      text(chars[charIndex], 0, 0);
      charIndex = (charIndex + 1) % chars.length;
    translate(sz, 0);
    
  } else {
    Dragon(sz, level-1, h, -abs(angl));
    rotate(radians(angl));
    Dragon(sz, level-1, h, abs(angl));
  }
}
