/*
SketchName: flowerField.pde
Credits: Sebastian, Me
Description: my first drawing since rehab
*/

color[] stemC = {#005f73, #0a9396, #94d2bd};
color[] budC = {#9b5de5, #f15bb5, #fee440, #00bbf9, #00f5d4};
final static float BRUSH_STEP = 0.001;

String sketchName = "flowerField";
String saveFormat = ".png";

int calls = 0;
long lastTime;
ArrayList<Flower> flowers = new ArrayList<Flower>();

void setup() {
  size(2500, 1500);
  colorMode(HSB, 360, 100, 100, 1);
  float numFlowers = random(50, 150);
  for (float f = 0; f < numFlowers; f++) {
    int stemCInt = (int) random(stemC.length); 
    int budCInt = (int) random(budC.length);    
    color stemColor = stemC[stemCInt];
    color budColor = budC[budCInt];
    Flower flower = new Flower(random(5, 25), random(0 - width/2, width), budColor, stemColor);
    flowers.add(flower);
  }
}


void draw() {
  background(color(#000000));
    for (float x=0; x < width; x+=1) {
      for (float y=0; y < height; y+=1) {        
        float h = 32;
        float s = map(x, 0, width, 100, 0);
        float b = map(y, 0, height, 100, 0);
        //noStroke();
        stroke(h, s, b, 0.5);
        point(x, y);        
      }
  }
  
  for (Flower f : flowers) {
    f.render();
  }
  print("done");
  save(getTemporalName(sketchName, saveFormat));
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
