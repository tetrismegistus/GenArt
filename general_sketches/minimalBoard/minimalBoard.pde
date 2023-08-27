import java.util.Random;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

LazyGui gui;
OpenSimplexNoise oNoise;

Board board;
final ColorPalette PAL_A = new ColorPalette(new color[] {#D64045, #1D3354});
final ColorPalette PAL_B = new ColorPalette(new color[] {#9ED8DB, #467599});
final float DEFAULT_TILE_SIZE = 5;

int MAX_TILE_WIDTH  = 10;
int MAX_TILE_HEIGHT = 10;
int OCTAVES = 4;            
int outputWidth = 1000;
int outputHeight = 1000;
int previewWidth = 1000;
int previewHeight = 1000;
float PERSISTENCE = 0.5f;   
float FILL_THRESHOLD = 0;
float NOISE_SCALE = 0.002;
float TILE_SIZE = 5; 
float STROKEWEIGHT = 1;
float PADDING = 0.01;
float COLOR_THRESH = 0.0;
boolean useNoiseForPalette = true;

color BACKGROUND_COLOR = #E9FFF9;
PGraphics outputBuffer;


void setup() {
  Random rand = new Random();
  long randomLongValue = rand.nextLong();
  oNoise = new OpenSimplexNoise(randomLongValue);
  size(1000, 1000, P2D);  
  gui = new LazyGui(this);  
  genBoard();
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
    genBoard();
  }
  if(gui.button("rerender")){
    displayBoard();
  }
  
  image(outputBuffer, 0, 0, previewWidth, previewHeight);    
}


void genBoard() {
  Random rand = new Random();
  long randomLongValue = rand.nextLong();
  oNoise = new OpenSimplexNoise(randomLongValue);       
  
  board = new Board(50, 50, 380, 380, DEFAULT_TILE_SIZE, PAL_A, PAL_B);
  board.fillBoard();       
}

void displayBoard() {
  outputBuffer = createGraphics(outputWidth, outputHeight, P2D); 
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
