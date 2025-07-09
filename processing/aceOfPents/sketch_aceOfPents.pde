import java.util.Random;
import java.util.Arrays;

color yellow = color(255, 228, 4);
color green = color(0, 165, 78);
color cyan = color(148, 193, 214);
color red = color(237, 34, 40);
color[] colors = {yellow, green, cyan, red};
float sz = 300;

void setup() {
  size(293, 567);
  shuffleArray(colors);
  
}

void draw() {
  background(255);
  noFill();
  noStroke();
  translate(width/2, height/2);
  //shuffleArray(colors);
  fill(colors[0]);
  circle(0, 0, 1000);
  f(0, 0, sz);  
  if (sz < 1196) {
    sz += sz/100;
    println(sz);
  } else {    
    sz = 300;
    //exit();
  }
  //saveFrame("frames/####.png");

}


void f(float x, float y, float size) {
  //shuffleArray(colors);
  fill(colors[0]);
  circle(x,  y, size - size /4);
  fill(colors[1]);
  circle(x + size, y, size);
  fill(colors[2]);
  circle(x - size, y, size);
  fill(colors[3]);
  circle(x, y - size, size);
  fill(colors[1]);
  circle(x, y + size, size);
  if (size > 2) {     
    f(x + size, y, size / 3);
    f(x - size, y, size / 3);
    f(x, y + size, size / 3);
    f(x, y - size, size / 3);
    f(x, y, size / 4);
  } else {
    return;
  }  
}


void shuffleArray(int[] array) {
 
  // with code from WikiPedia; Fisher–Yates shuffle 
  //@ <a href="http://en.wikipedia.org/wiki/Fisher" target="_blank" rel="nofollow">http://en.wikipedia.org/wiki/Fisher</a>–Yates_shuffle
 
  Random rng = new Random();
 
  // i is the number of items remaining to be shuffled.
  for (int i = array.length; i > 1; i--) {
 
    // Pick a random element to swap with the i-th element.
    int j = rng.nextInt(i);  // 0 <= j <= i-1 (0-based array)
 
    // Swap array elements.
    int tmp = array[j];
    array[j] = array[i-1];
    array[i-1] = tmp;
  }
}
