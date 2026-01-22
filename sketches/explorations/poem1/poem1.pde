/*
SketchName: poem1.pde
Credits: me me me
Description: A poem made visual
*/

String[] poem = {
    "These things from the sea:",
    "Crates of pirated DVDs",
    "MP3 players, and playboy magazines.",
    "",
    "Datagrams arrange in sequence;",
    "the write-head bobs up and down;",
    "molecules polarize on my screen.",
    "",
    "And still I get no action, no sex, and no music."
};

String sketchName = "poem1";
String saveFormat = ".png";

int calls = 0;
long lastTime;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
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
