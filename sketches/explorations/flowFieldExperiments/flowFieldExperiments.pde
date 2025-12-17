int CANVAS_WIDTH = 2500;
int CANVAS_HEIGHT = 2000;

ArrayList<FlowField> fields;
ArrayList<Agent> agents;

int NUM_AGENTS = 10000;
int STEPS_PER_AGENT = 150;
float STEP_LENGTH = 10;

void settings() {
  size(CANVAS_WIDTH, CANVAS_HEIGHT);
}

void setup() {
  background(#FDFDFF);

  fields = new ArrayList<FlowField>();

  // Add various flowfields (stack them)
  
  fields = new ArrayList<FlowField>();

  FlowField f1 = new NoiseField(CANVAS_WIDTH, CANVAS_HEIGHT, -0.5, 1.5, 0.01, 1.5, TWO_PI);
  f1.setColor(#62929E);
  fields.add(f1);
  
  FlowField f2 = new NoiseField(CANVAS_WIDTH, CANVAS_HEIGHT, -0.5, 1.5, 0.01, .01, TWO_PI);
  f2.setColor(#546A7B);
  fields.add(f2);
  

  
    FlowField f3 = new NoiseField(CANVAS_WIDTH, CANVAS_HEIGHT, -0.5, 1.5, 0.1, .01, TWO_PI);
  f2.setColor(#546A7B);
  fields.add(f3);
  
  FlowField f4 = new LinearGradientField2(CANVAS_WIDTH, CANVAS_HEIGHT, -0.5, 1.5, 0.01);
  f4.setColor(#393D3F23);
  fields.add(f3);

  // Prepare agents array (we'll reinitialize between fields)
  agents = new ArrayList<Agent>();

  noLoop(); // We'll manually render everything in draw()
}

void draw() {

  for (FlowField ff : fields) {

    // Optional: color per layer
    stroke(0, 20);

    // Re-seed agents randomly each layer
    initAgents();

    // Run agents through this field
    for (Agent a : agents) {
      a.walk(ff, STEPS_PER_AGENT);
    }
  }
  
  save("field.png");
}

// Create random agents
void initAgents() {
  agents.clear();
  for (int i = 0; i < NUM_AGENTS; i++) {
    float x = random(-100, CANVAS_WIDTH + 100);
    float y = random(-100, CANVAS_HEIGHT + 100);
    agents.add(new Agent(x, y, STEP_LENGTH));
  }
}
