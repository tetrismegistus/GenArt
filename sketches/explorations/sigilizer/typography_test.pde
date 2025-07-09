PFont hebFont;
char[] chars = {'ל', 'ו', 'י', 'ת', 'ן'};
color[] cols = {color(127, 164, 166), color(245, 221, 154), color(178, 251, 113), color(233, 156, 99), color(143, 182, 149)};
int charIndex = 0;
int lineCharIndex = 1;
int charIndex3 = 2;

void setup() {
  size(1000, 1000);
  hebFont = createFont("Rubik-Regular.ttf", 70);
  textFont(hebFont);  
  rectMode(CENTER);
  blendMode(SCREEN);
  ellipseMode(CENTER);
}

void draw() {  
  background(0);
  charIndex = 0;
  translate(width/2, height/2);  
  noFill();
  stroke(255);
  for (int l=0; l < chars.length; l++) {
    for (int i=0; i < chars.length * chars.length; i++) {
      float angle = radians(map(i, 0, chars.length * chars.length, 0, 360));  
      float x = ((l * 75) + 50) * cos(angle);
      float y = ((l * 75) + 50) * sin(angle);
      fill(cols[charIndex], 20);
      noStroke();
      if (random(1) > .25) {
        circle(x, y, ((l * 75) + 50));
      } else {
        square(x, y, ((l * 75) + 50));
      }
      fill(cols[charIndex]);
      text(chars[charIndex], x, y);
      fill(cols[charIndex], 20);

      charIndex = (charIndex + 1) % chars.length;       
    }
    charIndex = (charIndex + 1) % chars.length;

  }
  save("test.jpg");
  noLoop(); 
  
}
