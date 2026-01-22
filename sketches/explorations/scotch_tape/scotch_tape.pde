int CANVAS_WIDTH = 2500;
int CANVAS_HEIGHT = 2000;

ArrayList<FlowField> fields;
ArrayList<Agent> agents;

color[] agentColors = {#2667FF, #252627, #BB0A21};
int agentColorIndex = 0;
PGraphics canvas;

int NUM_AGENTS = 100;
int STEPS_PER_AGENT = 500;
float STEP_LENGTH = 10;

void settings() {
  size(CANVAS_WIDTH, CANVAS_HEIGHT, P2D);
}

void setup() {
  colorMode(HSB, 360, 100, 100, 1);
  canvas = createGraphics(CANVAS_WIDTH * 2, CANVAS_HEIGHT * 2, P2D);
  canvas.beginDraw();
  canvas.colorMode(HSB, 360, 100, 100, 1);
  canvas.background(#D3D4D9);
  parchmentTexture(50000);
  
  fields = new ArrayList<FlowField>();
  FlowField f1 = new NoiseField(CANVAS_WIDTH * 2, CANVAS_HEIGHT * 2, -.5, .5, .001, .004, TWO_PI);
  fields.add(f1);
  
  FlowField f2 = new LinearGradientField2(CANVAS_WIDTH * 2, CANVAS_HEIGHT * 2, -.5, .5, .001);
  fields.add(f2);
  
  FlowField f3 = new NoiseField(CANVAS_WIDTH * 2, CANVAS_HEIGHT * 2, -.5, .5, .001, .0004, TWO_PI);
  fields.add(f3);
  

  
  agents = new ArrayList<Agent>();
  
  for (FlowField ff : fields) {


    // Re-seed agents randomly each layer
    initAgents();

    // Run agents through this field
    for (Agent a : agents) {
      a.walk(ff, STEPS_PER_AGENT);
    }
    
      for (Agent a : agents) {
        a.draw(canvas);
      }
  }
  canvas.endDraw();
  
  noLoop(); // We'll manually render everything in draw()
}

void draw() {
  background(#F6F8FF);
  strokeWeight(6);
  stroke(agentColors[2]);
  noFill();
  rect(100, 100, (CANVAS_WIDTH) - 200, (CANVAS_HEIGHT) - 200);
  image(canvas, 100, 100, (CANVAS_WIDTH) - 200, (CANVAS_HEIGHT) - 200);
  println("done");
  save("out.png");
}

void initAgents() {
  agents.clear();

  color c = agentColors[agentColorIndex];
  agentColorIndex = (agentColorIndex + 1) % agentColors.length;

  for (int i = 0; i < NUM_AGENTS; i++) {
    float x = random(-100, CANVAS_WIDTH * 2 + 100);
    float y = random(-100, CANVAS_HEIGHT * 2 + 100);
    agents.add(new Agent(x, y, STEP_LENGTH, c));
  }
}

void parchmentTexture(int numCircles) {
  canvas.noFill();
  canvas.stroke(42, 87, 9, 0.02);
  float radBase = 200;
  float curveSpread = 100;
  for (int i = 0; i < numCircles; i++) {
    float x = random(width * 2 + radBase);
    float y = random(height * 2 + radBase);
    float rad = randomGaussian() * curveSpread + radBase;
    canvas.circle(x, y, rad);
  }
}
