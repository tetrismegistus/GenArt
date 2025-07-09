/* 
JAN. 2. (credit: Monokai)

Layers upon layers upon layers.
*/

import com.krab.lazy.*;
import java.util.Random;

String sketchName = "mySketch";
String saveFormat = ".png";

LazyGui gui;
OpenSimplexNoise oNoise;

int calls = 0;
long lastTime;

Board[] boards; // Array to hold multiple boards
int numBoards = 3; // Number of boards to generate and display


String inputImageFilename = "20240905_185612_a0d361c2.jpg";
float[] a = {0.5, 0.5, 0.5}; // RGB for the base color (grey in the example)
float[] b = {0.5, 0.5, 0.5}; // RGB for the amplitude of the cosine function
float[] c = {1.0, 1.0, 1.0}; // Frequency of the cosine function
float[] d = {random(.1), random(.05, .15), 0.20}; // Phase shift of the cosine function
int sizeOfPalette = 100;

Board board;
ColorPalette PAL_A;
ColorPalette PAL_B;
float DEFAULT_TILE_SIZE = 4;

int MAX_TILE_WIDTH  = 100;
int MAX_TILE_HEIGHT = 100;
int OCTAVES = 4;            
int outputWidth = 1404;
int outputHeight = 1872;
int previewWidth = 702;
int previewHeight = 936;
float PERSISTENCE = 0.5f;   
float FILL_THRESHOLD = 0;
float NOISE_SCALE = 0.002;
float TILE_SIZE = 10; 
float STROKEWEIGHT = 1;
float PADDING = 0.00;
float COLOR_THRESH = 0.0;
float padX, padY;
int rows, cols;
boolean useNoiseForPalette = true;

color BACKGROUND_COLOR = #000000;
PGraphics outputBuffer;
PGraphics[] boardBuffers;
PImage original;

void settings() {
  original = loadImage(inputImageFilename);
  original.filter(GRAY);
  // Set the maximum dimensions for the preview
  int maxPreviewWidth = 2000; // Change this value as needed
  int maxPreviewHeight = 1000; // Change this value as needed

  // Calculate the aspect ratio of the original image
  float aspectRatio = (float) original.width / original.height;

  // Scale preview dimensions while maintaining aspect ratio
  if (original.width > original.height) {
    previewWidth = maxPreviewWidth;
    previewHeight = (int) (maxPreviewWidth / aspectRatio);
  } else {
    previewHeight = maxPreviewHeight;
    previewWidth = (int) (maxPreviewHeight * aspectRatio);
  }

  // Set the output dimensions to the original size
  outputWidth = original.width;
  outputHeight = original.height;

  // Use the scaled preview dimensions for the canvas
  size(previewWidth, previewHeight, P2D);
}


void setup() {
  Random rand = new Random();
  color[] p = getPalette(sizeOfPalette);  
  color[] p_A = new color[sizeOfPalette / 2];
  color[] p_B = new color[sizeOfPalette / 2];
  System.arraycopy(p, 0, p_A, 0, sizeOfPalette / 2);
  System.arraycopy(p, sizeOfPalette / 2, p_B, 0, sizeOfPalette / 2);

  PAL_A = new ColorPalette(p_A);
  PAL_B = new ColorPalette(p_B);
  
  long randomLongValue = rand.nextLong();
  oNoise = new OpenSimplexNoise(randomLongValue);
  
  float marginRatio = 0;
  padX = outputWidth * marginRatio;
  padY = outputHeight * marginRatio;
  
  rows = (int) ((outputWidth - padX * 2) / DEFAULT_TILE_SIZE);
  cols = (int) ((outputHeight - padY * 2) / DEFAULT_TILE_SIZE);

  gui = new LazyGui(this);

  // Initialize the boards and buffers
  boards = new Board[numBoards];
  boardBuffers = new PGraphics[numBoards];
  for (int i = 0; i < numBoards; i++) {
    genBoard(i, padX, padY, cols, rows);
    boardBuffers[i] = createGraphics(outputWidth, outputHeight, P2D); // Create buffer for each board
  }

  displayAllBoards();
}


void draw() {
  outputBuffer.background(BACKGROUND_COLOR);
  useNoiseForPalette = gui.toggle("Use Noise for Palette", useNoiseForPalette);
  NOISE_SCALE = gui.slider("NOISE_SCALE", NOISE_SCALE, 0.00001, 0.1);
  FILL_THRESHOLD = gui.slider("FILL_THRESHOLD", FILL_THRESHOLD, -1.0, 1.0);
  COLOR_THRESH = gui.slider("COLOR_THRESH", COLOR_THRESH, -1.0, 1.0);
  OCTAVES = gui.sliderInt("OCTAVES", OCTAVES, 1, 10);
  PERSISTENCE = gui.slider("PERSISTENCE", PERSISTENCE, 0.1, 1.0);  
  STROKEWEIGHT = gui.slider("STROKEWEIGHT", STROKEWEIGHT, 1, 10);  
  MAX_TILE_WIDTH = gui.sliderInt("MAX_TILE_WIDTH", MAX_TILE_WIDTH, 2, 100);
  MAX_TILE_HEIGHT = gui.sliderInt("MAX_TILE_HEIGHT", MAX_TILE_HEIGHT, 2, 100);
  PADDING = gui.slider("PADDING", PADDING, 0, .45); 
  
  if(gui.button("regen")){
    for (int i = 0; i < numBoards; i++) {
      genBoard(i, padX, padY, cols, rows);
    }
  }
  if(gui.button("rerender")){
    displayAllBoards();
  }
  
  image(outputBuffer, 0, 0, previewWidth, previewHeight);    
}




void genBoard(int index, float x, float y, int cols, int rows) {
  Random rand = new Random();
  long randomLongValue = rand.nextLong();
  oNoise = new OpenSimplexNoise(randomLongValue);

  boards[index] = new Board(x, y, cols, rows, DEFAULT_TILE_SIZE, PAL_A, PAL_B);
  boards[index].fillBoard();
}

void displayAllBoards() {
  // Clear the output buffer
  outputBuffer = createGraphics(outputWidth, outputHeight, P2D); 
  outputBuffer.beginDraw();
  outputBuffer.clear();
  outputBuffer.strokeWeight(STROKEWEIGHT);
  outputBuffer.colorMode(HSB, 360, 100, 100, 1);       
  outputBuffer.background(BACKGROUND_COLOR);
  outputBuffer.endDraw();

  // Render each board into its own buffer
  for (int i = 0; i < boards.length; i++) {
    float redBand = (i == 0) ? 50 : 0;  // Only the first board affects the red channel
    float greenBand = (i == 1) ? 50 : 0; // Only the second board affects the green channel
    float blueBand = (i == 2) ? 50 : 0;  // Only the third board affects the blue channel

    // Render the board to its buffer
    PGraphics buffer = boardBuffers[i];
    buffer.beginDraw();
    buffer.clear();
    buffer.strokeWeight(STROKEWEIGHT);
    buffer.colorMode(HSB, 360, 100, 100, 1);
    buffer.background(0, 0); // Transparent background
    boards[i].render(PADDING, redBand, greenBand, blueBand, buffer); // Pass the buffer to the render method
    buffer.endDraw();
  }

  // Combine the buffers into the output buffer
  outputBuffer.beginDraw();
  for (int i = 0; i < boardBuffers.length; i++) {
    outputBuffer.blend(boardBuffers[i], 0, 0, outputWidth, outputHeight, 0, 0, outputWidth, outputHeight, ADD);
  }
  outputBuffer.endDraw();
}



void keyReleased() {
  if (key == 's' || key == 'S') outputBuffer.save(getTemporalName(sketchName, saveFormat));  
}


String getTemporalName(String prefix, String suffix) {
  // Thanks! SparkyJohn @Creative Coders on Discord
  long time = System.currentTimeMillis();
  if (lastTime == time) {
    calls ++;
  } else {
    lastTime = time;
    calls = 0;
  }
  return prefix + time + (calls>0?"-"+calls : "")  +suffix;
}

color[] getPalette(int size) {
  color[] palette = new color[size];
  for (int i = 0; i < size; i++) {
    float t = map(i, 0, size - 1, 0, 1); // Map the index to a t value between 0 and 1
    palette[i] = colorFromCosine(t);
  }
  return palette;
}

// Function to calculate the color from the cosine function
color colorFromCosine(float t) {
  float red = 255 * (a[0] + b[0] * cos(TWO_PI * (c[0] * t + d[0])));
  float green = 255 * (a[1] + b[1] * cos(TWO_PI * (c[1] * t + d[1])));
  float blue = 255 * (a[2] + b[2] * cos(TWO_PI * (c[2] * t + d[2])));
  return color(red, green, blue);
}
