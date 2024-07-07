import java.util.Map;
import java.lang.Math;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
  background(#819BCB);

  HashMap<Character,String> rules = new HashMap<Character,String>();
  rules.put('F', "FF-F+F-FF");
  
  strokeWeight(1);
  
  
  Turtle t = new Turtle(width/2 + 25, height/2 + 50, 60, 6, rules);
  t.executeInstString("F--F--F--F");
  println("ding");
  noLoop();
  
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
}


String getTemporalName(String prefix, String suffix){
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if(lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}
