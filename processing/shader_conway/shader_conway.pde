PGraphics pg1, pg2;
PGraphics current, next;
PShader golShader, renderingShader;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float perlinThreshold = 0.5; // Adjust as needed
color color1 = #C5D1EB; // You can adjust these colors
color color2 = #395B50;
color deadColorVal = #232528; // Default to black, but you can adjust this

void setup() {
  size(1000, 1000, P2D);
  noStroke();

  golShader = loadShader("gol_simulation.frag");
  renderingShader = loadShader("gol_visualization.frag"); // Assuming the name of your rendering shader
  
  pg1 = createGraphics(width, height, P2D);
  pg2 = createGraphics(width, height, P2D);

  // Initializing with a random pattern
  pg1.beginDraw();
  pg1.background(0);
  for (int x = 0; x < pg1.width; x++) {
    for (int y = 0; y < pg1.height; y++) {
      if (random(1) > 0.5) {
        pg1.set(x, y, color(255, 0, 0));
      }
    }
  }
  pg1.endDraw();

  current = pg1;
  next = pg2;
}

void draw() {
  // Compute next state with golShader
  next.beginDraw();
  next.shader(golShader);
  golShader.set("currentStateTexture", current);
  golShader.set("texelSize", 1.0 / width, 1.0 / height);
  golShader.set("perlinThreshold", perlinThreshold);
  golShader.set("time", frameCount * 0.001); // Adjust speed factor as needed
  next.rect(0, 0, width, height);
  next.endDraw();

  // Render the simulation with renderingShader
  shader(renderingShader);
  renderingShader.set("currentStateTexture", next);
  renderingShader.set("texelSize", 1.0 / width, 1.0 / height);
  renderingShader.set("color1", red(color1)/255.0, green(color1)/255.0, blue(color1)/255.0, alpha(color1)/255.0);
  renderingShader.set("color2", red(color2)/255.0, green(color2)/255.0, blue(color2)/255.0, alpha(color2)/255.0);
  renderingShader.set("deadColor", red(deadColorVal)/255.0, green(deadColorVal)/255.0, blue(deadColorVal)/255.0, alpha(deadColorVal)/255.0);
  rect(0, 0, width, height);

  // Swap the buffers
  PGraphics tmp = current;
  current = next;
  next = tmp;
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
