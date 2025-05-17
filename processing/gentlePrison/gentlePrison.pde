import com.krab.lazy.*;

import java.util.Random;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

LazyGui gui;

ArrayList<Board> boards = new ArrayList<Board>();

final ColorPalette PAL_A = new ColorPalette(new color[] {#D64045, #1D3354});
final ColorPalette PAL_B = new ColorPalette(new color[] {#9ED8DB, #467599});
final color BACKGROUND_COLOR = #E9FFF9;
final float DEFAULT_TILE_SIZE = 5;

boolean useNoiseForPalette = true;  // Default to true
int OCTAVES = 4;               // Default value
float PERSISTENCE = 0.5f;     // Default value
int MAX_TILE_WIDTH = 10;
int MAX_TILE_HEIGHT = 20;
int DEFAULT_MAX_DEPTH = 0;
float FILL_THRESHOLD = 0;
float PADDING = 0.01;
float NOISE_SCALE = 0.001;
float STROKEWEIGHT = 1;

PGraphics outputBuffer;

OpenSimplexNoise oNoise;

int outputWidth = 2000;
int outputHeight = 2000;
int previewWidth = 1000;
int previewHeight = 1000;

void setup() {    
  colorMode(HSB, 360, 100, 100, 1);
  size(1000, 1000, P3D);
  
  smooth(8);    
  gui = new LazyGui(this);
  genBoard();
}


void draw() {    
  background(BACKGROUND_COLOR);
  useNoiseForPalette = gui.toggle("Use Noise for Palette", useNoiseForPalette);
  NOISE_SCALE = gui.slider("NOISE_SCALE", NOISE_SCALE, 0.00001, 0.01);
  FILL_THRESHOLD = gui.slider("FILL_THRESHOLD", FILL_THRESHOLD, -1.0, 1.0);
  OCTAVES = gui.sliderInt("OCTAVES", OCTAVES, 1, 10); // Example with a max of 10 octaves
  PERSISTENCE = gui.slider("PERSISTENCE", PERSISTENCE, 0.1, 1.0);
  PADDING = gui.slider("PADDING", PADDING, 0, .45);
  STROKEWEIGHT = gui.slider("STROKEWEIGHT", STROKEWEIGHT, 1, 10);
  DEFAULT_MAX_DEPTH = gui.sliderInt("MAX_DEPTH", DEFAULT_MAX_DEPTH, 0, 3);
  MAX_TILE_WIDTH = gui.sliderInt("MAX_TILE_WIDTH", MAX_TILE_WIDTH, 2, 100);
  MAX_TILE_HEIGHT = gui.sliderInt("MAX_TILE_HEIGHT", MAX_TILE_HEIGHT, 2, 100);
  if(gui.button("rerender")){
    genBoard();
  }
  image(outputBuffer, 0, 0, previewWidth, previewHeight);    
}

void genBoard() {
  Random rand = new Random();
  long randomLongValue = rand.nextLong();
  oNoise = new OpenSimplexNoise(randomLongValue);
  boards.clear(); 
  
  outputBuffer = createGraphics(outputWidth, outputHeight, P2D);   
  outputBuffer.beginDraw();
  outputBuffer.clear();
  outputBuffer.strokeWeight(STROKEWEIGHT);
  outputBuffer.colorMode(HSB, 360, 100, 100, 1);  
  outputBuffer.ellipseMode(CENTER);    
  outputBuffer.background(BACKGROUND_COLOR);
  
  Board b = new Board(50, 50, 380, 380, DEFAULT_TILE_SIZE, PAL_A, PAL_B, 0, DEFAULT_MAX_DEPTH);
  
  b.fillBoard();
  boards.add(b);
      
  for (Board board: boards) {    
    board.render(PADDING);
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
