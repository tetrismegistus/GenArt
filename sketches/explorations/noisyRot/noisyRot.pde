String sketchName = "bubbleChamber";
String saveFormat = ".png";
long lastTime;
int calls = 0;

PShader theShader;
PGraphics shaderTexture;

float theta = 0;
float cubeSize;

int outWidth = 3840;
int outHeight = 2160;

void setup() {
  // shaders require P2D or P3D mode to work
  size(1024, 768, P3D);
  
  // load the shader
  theShader = loadShader("noisyFrag.frag");

  // initialize the createGraphics layer
  shaderTexture = createGraphics(outWidth, outHeight, P3D);
  
  // Set the stroke and rect mode
  shaderTexture.stroke(0);
  shaderTexture.rectMode(CENTER);
}

void draw() {
  background(255);
  
  // set the active shader on the createGraphics layer
  shaderTexture.beginDraw();
  shaderTexture.shader(theShader);

  // send uniform values to the shader
  theShader.set("u_resolution", (float)width, (float)height);
  theShader.set("u_time", millis() / 1000.0);
  
  // render geometry on the shaderTexture layer
  shaderTexture.rect(0, 0, outWidth, outHeight);
  shaderTexture.endDraw();
  //shader(theShader);
  // pass the shader as a texture
  texture(shaderTexture);

  pushMatrix();
  translate(0, 0, 0);
  image(shaderTexture, 0, 0);
  popMatrix();
  
}

String getTemporalName(String prefix, String suffix) {
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls > 0 ? "-" + calls : "") + suffix;
}

void keyReleased() {
  if (key == 's' || key == 'S') {
    shaderTexture.save(getTemporalName(sketchName, saveFormat));
  }
}
