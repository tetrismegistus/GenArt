import java.util.Random;
import java.util.Arrays;


float hue = 0;
float sat = 0;
float bright1 = 0;
float bright2 = 0;
float[] brights = {bright1, bright2}; 
float xDivisor = 2.5;
float offset;

void setup() {
  size(800, 600);
  colorMode(HSB);
  rectMode(CENTER);
  offset = height/4;
  newColorTest();
}

void draw() {
  background(0, 0, 255);
  noStroke();
  fill(hue, sat, brights[0]);
  diamond(width/xDivisor, height/2, height/4);
  fill(hue, sat, brights[1]);
  diamond(width-width/xDivisor + offset, height/2, height/4);
}

void keyPressed() {
  if (key == 'n') {
    newColorTest();    
  }
  if (key == 'r') {
    reverseTest();
  }
  
  if (key == 's') {
    saveFrame("output.png");
  }
}

void mouseClicked() {
  if (offset == 0) {
    offset = height/4;
  } else {
    offset = 0;
  }
}


void reverseTest() {
  float temp = brights[0];
  brights[0] = brights[1];
  
}

void newColorTest() {
  hue = random(0, 255);
  sat = random(0, 100);
  brights[0] = random(0, 100);
  if (brights[0] == 100) {
    brights[1] = 97;
  } else if (brights[0] == 0) {
    brights[1] = 3;
  } else {
    brights[1] = brights[0] + 3;
  }
  shuffleArray(brights);
  
}


void diamond(float x, float y, float size) {
  pushMatrix();
  translate(x, y);
  rotate(radians(45));
  square(0, 0, size);
  popMatrix();
}



void shuffleArray(float[] array) {
 
  // with code from WikiPedia; Fisher–Yates shuffle 
  //@ <a href="http://en.wikipedia.org/wiki/Fisher" target="_blank" rel="nofollow">http://en.wikipedia.org/wiki/Fisher</a>–Yates_shuffle
 
  Random rng = new Random();
 
  // i is the number of items remaining to be shuffled.
  for (int i = array.length; i > 1; i--) {
 
    // Pick a random element to swap with the i-th element.
    int j = rng.nextInt(i);  // 0 <= j <= i-1 (0-based array)
 
    // Swap array elements.
    float tmp = array[j];
    array[j] = array[i-1];
    array[i-1] = tmp;
  }
}
