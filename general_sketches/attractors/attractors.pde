/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/
import geomerative.*;

RFont font;
LazyGui gui;

String textTyped = "Aric";
String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;


ArrayList<Particle> nodes = new ArrayList<>();
ArrayList<Attractor> attractors = new ArrayList<>();

boolean randomParticles;
boolean gridParticles;
boolean textParticles;
boolean randomAttractors;
float partXSpace;
float partYSpace;
float partYStart;
float partXStart;
float partXEnd;
float partYEnd;
float border = 5;
int numParticles;
float ramp;
float strength;
boolean dispTrail;
int fontSize;
float radius;

color[] pal = {#114B5F, #456990, #F45B69, #6B2737};

Attractor a;

void setup() {
  size(800, 800, P2D);
  gui = new LazyGui(this);
  RG.init(this);  
  colorMode(HSB, 360, 100, 100, 1);  
  initParticles();
}


void draw() {
  gui.pushFolder("scene");

  drawBackground();
  initState();
  a.pos.x = mouseX;
  a.pos.y = mouseY;
  dispTrail = gui.toggle("dispTrail", false);
  radius = gui.slider("radius", 200, 10, width/2);
  
  stroke(gui.colorPicker("stroke", color(0x000000)).hex);
  if (gui.button("fancyRender")) {
    drawBackground();    
    for (Particle p: nodes) {
      Brush b = new Brush(5, 0, 0, pal[(int) random(pal.length)]);
      for (PVector t : p.trail) {
        b.cx = t.x;
        b.cy = t.y;
        b.render();
        
      }      
      
    }
    save(getTemporalName(sketchName, saveFormat));
  }
  
  boolean running = gui.toggle("running", false);
  if (running) {
    for (Particle p: nodes) {
      if (mousePressed) {        
        a.attract(p);
      }
      p.update();
      p.render();
    }
  } else {
    for (Particle p: nodes) {    
      p.render();
    }
  }
  
  
  // go one level up from the current folder
  gui.popFolder();
  
}

void initState() {
  gui.pushFolder("init");

  gui.pushFolder("random");
  randomParticles = gui.toggle("Random Particles", false);    
  numParticles = gui.sliderInt("numParticles", 30, 1, 1000);
  gui.popFolder();
  
  gui.pushFolder("grid");
  gridParticles = gui.toggle("Grid Particles", true);
  partXSpace = gui.slider("partXSpace", 50, 1, 300);
  partYSpace = gui.slider("partYSpace", 50, 1, 300);
  partXStart = gui.slider("partXStart", border, border, width - border);
  partYStart = gui.slider("partYStart", border, border, height - border);
  partXEnd = gui.slider("partXEnd", width-border, border, width - border);
  partYEnd = gui.slider("partYEnd", height-border, border, height - border);
  gui.popFolder();
  
  gui.pushFolder("text");
  textParticles = gui.toggle("Text Particles", false);
  textTyped = gui.text("text", "Aric");
  fontSize = gui.sliderInt("fontSize", 200, 10, 400);  
  gui.popFolder();
  
  ramp = gui.slider("ramp", .1, -1, 1);
  strength = gui.slider("strength", .1, -1, 1);
      
  if (gui.button("reInit")) {
    initParticles();
  }
  gui.popFolder();
}

void initParticles() {
  a = new Attractor(width/2, height/2);
  a.ramp = ramp;
  a.strength = strength;
  a.radius = radius;
  nodes = new ArrayList<>();
  if (gridParticles) {
    for (float x = partXStart; x < partXEnd; x+= partXSpace) {
      for (float y = partYStart; y < partYEnd; y+= partYSpace) {
        Particle p = new Particle(x, y);
        //p.velocity = new PVector(random(-3, 3), random(-3, 3)); 
        nodes.add(p);
      }
    }
  } else if (randomParticles) {
    for (int i = 0; i < numParticles; i++) {
      Particle p = new Particle(random(5, width - 5), random(5, height - 5));
      nodes.add(p);
    }
  } else if (textParticles) {
    font = new RFont("FreeSans.ttf", fontSize, RFont.LEFT);
    RCommand.setSegmentLength(10);
    RCommand.setSegmentator(RCommand.UNIFORMLENGTH);
    RPoint[] pnts = getPnts(textTyped);
    for (RPoint pnt : pnts) {
      Particle p = new Particle(pnt.x + 50, pnt.y + 200);
      nodes.add(p);
    }
  }
  
}



void drawBackground() {
  gui.pushFolder("background");
  // the controls are ordered on screen by which gets called first
  // so it can be better to ask for all the values before any if-statement branching
  // because this way you can enforce any given ordering of them in the GUI
  // and avoid control elements appearing suddenly at runtime at unexpected places
  int solidBackgroundColor = gui.colorPicker("solid", color(0xFFFFFF)).hex;
  PGraphics gradient = gui.gradient("gradient");
  boolean useGradient = gui.toggle("solid\\/gradient"); // here '\\' escapes the '/' path separator
  if (useGradient) {
    image(gradient, 0, 0);
  } else {
    background(solidBackgroundColor);
  }
  gui.popFolder();
}


RPoint[] getPnts(String text) {
  RGroup grp;
  grp = font.toGroup(text);
  grp = grp.toPolygonGroup();
  RPoint[] pnts = grp.getPoints();
  return pnts;
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
