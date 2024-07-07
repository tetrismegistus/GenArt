/*
SketchName: deJong.pde
Credits: https://www.algosome.com/articles/strange-attractors-de-jong.html
Description: experiments with De Jong Attractors
*/

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

int drawMode = 1;

int iterations = 7000;

ArrayList<Attractor> attractors = new ArrayList<Attractor>();


void setup() {
  size(800, 800, P3D);
  colorMode(HSB, 360, 100, 100, 1);
  for (int x = 40; x < width; x+= 40) {
    for (int y = 40; y < height; y+= 40) {
      Attractor a = new Attractor(x, y, 20, color(random(360), 100, 50));      
      attractors.add(a);
      //println(a.a + " " + a.b + " " + a.c + " " + a.d);
    }
    
  }
  for (int i = 0; i < iterations; i++) {
   for (Attractor atr : attractors) {
   
     atr.update();
   }
  }
    
  
  

}


void draw() {
  background(0, 0, 100);

  rotateX(radians(40));
  strokeWeight(.5);
  for (Attractor a : attractors) {
    a.display();    
  }
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
