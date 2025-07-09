import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

AgentManager agentManager = new AgentManager();
TrailManager trailManager = new TrailManager();

PVector gravity = new PVector(0, 0.01);
PVector wind = new PVector(0.0,0);

ArrayList<ColliderRect> rects = new ArrayList<ColliderRect>();

float combLength = 300;
float toothSpace = 20;

PostFX fx;


void setup() {
  size(800, 800, P3D);
  fx = new PostFX(this);
  colorMode(HSB, 360, 100, 100, 1);  
  blendMode(SCREEN);
  for (float x = 0; x < height; x+=5) {
    PVector pos = new PVector(x, 0);
    PVector vel = new PVector(0, 0);
    PVector acc = new PVector(0, 0);
    float mh = map(x, 0, width, 0, 360);
    Agent a = new Agent(pos, acc, vel, color(mh, 100, 100, .5));
    agentManager.agents.add(a);
  }
  
  
  float startx = random(width - combLength);
  float cy = random(100, height - 100);
  for (float x = startx; x < startx + combLength; x += toothSpace) {
    ColliderRect rect;
    rect = new ColliderRect(new PVector(random(width), random(height)), random(10, 100), random(10, 100));
    rects.add(rect);  
  }
  
  //ColliderRect rect;
  //rect = new ColliderRect(new PVector(0, height - height/4), width/8, height/4);
  //rects.add(rect);
  
}
  


void draw() {
  background(0);
  //wind = new PVector(random(-0.1, 0.1),0);
  fill(100, 100, 0, .5);

  for (ColliderRect r : rects) 
  {
    r.display();
  }
  
  
  agentManager.moveAgents();
  agentManager.removeAgents();
  trailManager.displayTrails();
      fx.render()
    .bloom(0.5, 20, 40)
    .chromaticAberration()    
    .compose();

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
