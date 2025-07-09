import java.util.Random;

String sketchName = "mySketch";
String saveFormat = ".png";

LazyGui gui;
OpenSimplexNoise oNoise;

int calls = 0;
long lastTime;

float[] a = {0.5, 0.5, 0.5}; // RGB for the base color (grey in the example)
float[] b = {0.5, 0.5, 0.5}; // RGB for the amplitude of the cosine function
float[] c = {1.0, 1.0, 1.0}; // Frequency of the cosine function
float[] d = {random(.1), random(.05, .15), 0.20}; // Phase shift of the cosine function
int sizeOfPalette = 100;

Board board;
ColorPalette PAL_A;
ColorPalette PAL_B;
float DEFAULT_TILE_SIZE = 4;

int MAX_TILE_WIDTH  = 10;
int MAX_TILE_HEIGHT = 10;
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
float PADDING = 0.01;
float COLOR_THRESH = 0.0;
float padX, padY;
int rows, cols;
boolean useNoiseForPalette = true;

color BACKGROUND_COLOR = #E9FFF9;
PGraphics outputBuffer;

void settings() {
  size(previewWidth, previewHeight, P2D);
}


void setup() {
  Random rand = new Random();
  color[] p = getPalette(sizeOfPalette);  
  color[] p_A = new color[sizeOfPalette / 2];
  color[] p_B = new color[sizeOfPalette / 2];
  System.arraycopy(p, 0, p_A, 0, sizeOfPalette / 2);
  System.arraycopy(p, sizeOfPalette / 2, p_B, 0, sizeOfPalette / 2);
 
  BACKGROUND_COLOR=p_B[3];
  PAL_A = new ColorPalette(p_A);
  PAL_B = new ColorPalette(p_B);
  
  
  long randomLongValue = rand.nextLong();
  oNoise = new OpenSimplexNoise(randomLongValue);
  
  float marginRatio = .05;
  padX = outputWidth * marginRatio;
  padY = outputHeight * marginRatio;
  
  rows = (int) ((outputWidth - padX * 2) / DEFAULT_TILE_SIZE);
  cols = (int) ((outputHeight - padY * 2) / DEFAULT_TILE_SIZE);

  gui = new LazyGui(this);  
  genBoard(padX, padY, cols, rows);
  displayBoard();
}



void draw() {
  background(BACKGROUND_COLOR);
  useNoiseForPalette = gui.toggle("Use Noise for Palette", useNoiseForPalette);
  NOISE_SCALE = gui.slider("NOISE_SCALE", NOISE_SCALE, 0.00001, 0.1);
  FILL_THRESHOLD = gui.slider("FILL_THRESHOLD", FILL_THRESHOLD, -1.0, 1.0);
  COLOR_THRESH = gui.slider("COLOR_THRESH", COLOR_THRESH, -1.0, 1.0);
  OCTAVES = gui.sliderInt("OCTAVES", OCTAVES, 1, 10); // Example with a max of 10 octaves
  PERSISTENCE = gui.slider("PERSISTENCE", PERSISTENCE, 0.1, 1.0);  
  STROKEWEIGHT = gui.slider("STROKEWEIGHT", STROKEWEIGHT, 1, 10);  
  MAX_TILE_WIDTH = gui.sliderInt("MAX_TILE_WIDTH", MAX_TILE_WIDTH, 2, 100);
  MAX_TILE_HEIGHT = gui.sliderInt("MAX_TILE_HEIGHT", MAX_TILE_HEIGHT, 2, 100);
  PADDING = gui.slider("PADDING", PADDING, 0, .45); 
  
  if(gui.button("regen")){
    genBoard(padX, padY, cols, rows);
  }
  if(gui.button("rerender")){
    displayBoard();
  }
  
  image(outputBuffer, 0, 0, previewWidth, previewHeight);    
}


void genBoard(float x, float y, int cols, int rows) {
  Random rand = new Random();
  long randomLongValue = rand.nextLong();
  oNoise = new OpenSimplexNoise(randomLongValue);       
  
  board = new Board(x, y, cols, rows, DEFAULT_TILE_SIZE, PAL_A, PAL_B);
  board.fillBoard();       
}

void displayBoard() {
  outputBuffer = createGraphics(outputWidth, outputHeight, P2D); 
     
  outputBuffer.beginDraw();
  outputBuffer.clear();
  outputBuffer.strokeWeight(STROKEWEIGHT);
  outputBuffer.colorMode(HSB, 360, 100, 100, 1);       
  outputBuffer.background(BACKGROUND_COLOR);
  board.render(PADDING);      
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
