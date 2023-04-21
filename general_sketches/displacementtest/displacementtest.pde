PImage displacementMap;
PImage colorTexture;
PShader myShader;
int gridSize = 4000;
float gridSpacing = .25;

void setup() {
  size(1600, 1000, P3D);
  displacementMap = loadImage("data/height.png");
  colorTexture = loadImage("data/color.png");
  myShader = loadShader("frag.glsl", "vert.glsl");
  myShader.set("displacementMap", displacementMap);
  myShader.set("colorTexture", colorTexture);
  noLoop();
}

void draw() {
  
  background(0);
  //lights();
  float cameraYOffset = -100;
  background(0);
  float cameraZOffset = 500;
  translate(width / 2, height / 2, cameraZOffset);
  translate(0, cameraYOffset, 0); // Move the camera along the Y-axis
  rotateX(-PI / 4);
  rotateY(-PI / 3);
  //rotateZ(-PI / 4);
  noStroke();
pointLight(255, 0, 0, -gridSize * gridSpacing / 2, -50, -gridSize * gridSpacing / 2); // Red light
pointLight(0, 255, 0, gridSize * gridSpacing / 2, -50, -gridSize * gridSpacing / 2); // Green light
pointLight(0, 0, 255, 0, -50, gridSize * gridSpacing / 2); // Blue light

pointLight(255, 255, 255, gridSize * gridSpacing / 2, -50, gridSize * gridSpacing / 2); // White light
pointLight(255, 255, 0, -gridSize * gridSpacing / 2, -50, gridSize * gridSpacing / 2); // Yellow light
pointLight(255, 0, 255, 0, -100, 0); // Magenta light
  for (int z = 0; z < gridSize; z++) {
    for (int x = 0; x < gridSize; x++) {
      int pixelColor = displacementMap.get(
        int(map(x, 0, gridSize, 0, displacementMap.width)),
        int(map(z, 0, gridSize, 0, displacementMap.height))
      );
      float minHeight = 0;
float maxHeight = 100;
float yPos = map(brightness(pixelColor), 0, 255, minHeight, maxHeight);

      int texColor = colorTexture.get(
        int(map(x, 0, gridSize, 0, colorTexture.width)),
        int(map(z, 0, gridSize, 0, colorTexture.height))
      );

      pushMatrix();
      translate((x - gridSize / 2) * gridSpacing, yPos / 2, (z - gridSize / 2) * gridSpacing);
      scale(1, yPos / 100, 1); // Normalize the height of the boxes to a range of 0 to 1
      fill(texColor);
      box(gridSpacing);
      popMatrix();
    }
  }
  save("test.png");
}
