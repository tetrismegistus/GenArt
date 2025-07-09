import java.util.*;

String sketchName = "mySketch";
String saveFormat = ".png";
long lastTime;
int calls = 0;


ArrayList<Mover> paintGlobs = new ArrayList<>();

PVector gravity = new PVector(0, 0, 0.2);  
float frictionCoefficient = .2;

float bgNoiseCoEff = .00065;

float g = 0.004;

color[] p = {#2D2D2A, #4C4C47, #848FA5, #C14953};


PVector canvas = new PVector(0, -10, 0);
PVector painter = new PVector(0, 300, 0);


HashMap<Character, ArrayList<PVector>> asciiMap;
int cols = 120;
int rows = 65;
float tileSize = 30;
float gutterWidth = 40;
int gutterStartCol, gutterEndCol;
final ColorPalette PAL_A = new ColorPalette(new int[] {0xD64045, 0x1D3354});
final ColorPalette PAL_B = new ColorPalette(new int[] {0x9ED8DB, 0x467599});
String newlineMarker = "<NEWLINE>";
Board page;
String[] lines;
ArrayList<String> words = new ArrayList<>();
OpenSimplexNoise oNoise = new OpenSimplexNoise((long) random(0, 255));

void setup() {
  size(3840, 2160, P3D);  
  colorMode(HSB, 360, 100, 100, 1);
  
  smooth(8);
  page = new Board(100, 100, rows, cols, tileSize, PAL_A, PAL_B, 10, 10, this);
  
  int shape1Sides = (int) random(3, 12);
  
  asciiMap = new HashMap<>();
  generateAsciiMap();
  lines = loadStrings("data/input.txt");
  int middleX = cols / 2;
  gutterStartCol = (int) (middleX - (gutterWidth / (tileSize)));
  gutterEndCol = (int) (middleX + (gutterWidth / (tileSize)));
  
  for (int row = 0; row < rows; row++) {
      for (int col = gutterStartCol; col <= gutterEndCol; col++) {
          TileRect tr = page.tryPlaceGutterTile(col, row);
          if (tr != null) {
              page.rects.add(tr);
          }
      }
  }
  
  
  // Parsing lines into words
  for (String line : lines) {
      String[] lineWords = splitTokens(line, " ,.!?");
      words.addAll(Arrays.asList(lineWords));
      words.add(newlineMarker);
  }

  for (int j = 0; j < 40; j++) {
    painter = new PVector(random(0, width), 400, random(0, height));          
    
    for (int i = 0; i < (int) random(30, 60); i++) {
      int pidx = (int) random(p.length);      
      paintGlobs.add(new Mover(constrain(randomGaussian(), .3, 10), painter.x, painter.y, painter.z, p[pidx])); 
    }
  }

  
  for (int i = 0; i < 450; i++) {
      
      for (Mover paintGlob : paintGlobs) {          
          
        if (paintGlob.location.y >= canvas.y) { 
          
          if (paintGlob.location.x < width/2) {
            // this is so wrong but makes interesting output occasionally 
            gravity = new PVector(map(noise(paintGlob.location.x * .01), 0, 1, -1, 1), 
            map(noise(paintGlob.location.z * .01), 0, 1, -1, 1));            
            paintGlob.location.y = canvas.y;
            paintGlob.acceleration = new PVector(paintGlob.acceleration.x, 0, paintGlob.acceleration.z);
            paintGlob.velocity = new PVector(paintGlob.velocity.x, 0, paintGlob.velocity.z);      

          } else if (paintGlob.location.z < height - height/4){            
            gravity = new PVector(0, 0, 0.1);  
            paintGlob.location.y = canvas.y;
            paintGlob.acceleration = new PVector(paintGlob.acceleration.x, 0, paintGlob.acceleration.z);
            paintGlob.velocity = new PVector(paintGlob.velocity.x, 0, paintGlob.velocity.z);
            PVector friction = paintGlob.velocity.copy();
            friction.mult(-1);
            friction.setMag(frictionCoefficient);
            paintGlob.applyForce(friction);        
                      
          } else {
            gravity = new PVector(random(-1, 1), 0, random(-1, 1));
            paintGlob.location.y = canvas.y;
            paintGlob.acceleration = new PVector(paintGlob.acceleration.x, 0, paintGlob.acceleration.z);
            paintGlob.velocity = new PVector(paintGlob.velocity.x, 0, paintGlob.velocity.z);
            PVector friction = paintGlob.velocity.copy();
            friction.mult(-1);
            friction.setMag(frictionCoefficient);
            paintGlob.applyForce(friction);   
                      
          }
          
        }
        paintGlob.applyForce(gravity);  
        paintGlob.update();      
      }
  }   
}


void draw() {
  background(#E5DCC5);
  for (Mover paintGlob : paintGlobs) {    
    if (paintGlob.location.y >= canvas.y) {       
      paintGlob.midRender();
    }
  }
  
  for (int i = 0; i < (int) random(30, 80); i++) {
    grid(random(width), random(height), random(width/2), random(height/2), random(2, 10));    
  }
    
  
  
        
  int wordIndex = 0;
  boolean inRightColumn = false;
  int startRow = 0, startCol = 0;

  for (int row = startRow; row < rows; row++) {

      // Set up the left and right column boundaries.
      int endCol = inRightColumn ? cols : gutterStartCol;
      startCol = inRightColumn ? gutterEndCol : 0;

      // Loop through each column.
      for (int col = startCol; col < endCol; ) {

          // If we've placed all the words, we can exit the loop.
          if (wordIndex >= words.size()) {
              break;
          }

          String currentWord = words.get(wordIndex);

          // If we encounter a newline marker, skip to the next row.
          if (currentWord.equals("<NEWLINE>")) {
              row++;
              col = startCol;
              wordIndex++;
              continue;
          }

          // Try to place and draw the word.
          boolean wasPlaced = placeAndDrawWord(currentWord, col, row, tileSize, 1, page);

          // If successfully placed, move to the next word.
          if (wasPlaced) {
              wordIndex++;
              // Increment the column based on the word's length, if necessary
              //col += 1;
          } else {
              col+=2; // Otherwise, move one column to the right
          }
      }

      // If we've reached the bottom of the left column, switch to the right column.
      if (!inRightColumn && row == rows - 1) {            
          row = startRow - 1;  // Reset to the beginning row (it will be incremented by the for loop)
          inRightColumn = true;  // Switch to the right column.
          
      }

      // If we've placed all the words, we can exit the loop.
      if (wordIndex >= words.size()) {
          break;
      }
  }



  // Render the board
  page.render(0, asciiMap);
  
  
  strokeWeight(.4);
  
  float p1Gap = .01;
  double n1 = -p1Gap * 2;
  double n2 = n1 + p1Gap + constrain(randomGaussian(), 0, p1Gap);
  double n3 = n2 + p1Gap + constrain(randomGaussian(), 0 , p1Gap);
  double n4 = n3 + p1Gap + constrain(randomGaussian(), 0, p1Gap);
  
int octaves = 8; // Number of octaves
float lacunarity = 2.0; // Lacunarity determines frequency increase between octaves
float persistence = 0.5; // Persistence determines amplitude decrease between octaves

for(float x = 0; x < width; x+=.5) {
  for (float y = 0; y < height; y +=.5) {
    double n = 0;
    float amplitude = 1.0;
    float frequency = 1.0;
    
    // Iterate through octaves
    for (int o = 0; o < octaves; o++) {
      n += oNoise.eval(x * bgNoiseCoEff * frequency, y * bgNoiseCoEff * frequency) * amplitude;
      amplitude *= persistence;
      frequency *= lacunarity;
    }
    
    if (n >= n1 && n <= n2) {
      stroke(p[0]);
      point(x, y);
    } else if (n >= n2 && n <= n2) {
      stroke(p[1]);
      point(x, y);
    } else if (n >= n2 && n <= n3) {
      stroke(p[2]);
      point(x, y);
    } else if (n >= n3 && n <= n4) {
      stroke(p[3]);
      point(x, y);
    }     
  }
}
  save(getTemporalName(sketchName, saveFormat));
  println("...phew!");
  noLoop();
 
}


void imageFilter(String imagePath) {  
  PImage img = loadImage(imagePath);
  img.loadPixels();
  for (int x = 0; x < img.width; x+=2) {
    for (int y = 0; y < img.height; y+=2) {
      int loc = x + y*img.width;
      float b = map(brightness(img.pixels[loc]), 0, 100, 0, 1);
      boolean toPaint = b > 1.0 - random(1) + .1;
      if (toPaint) {
        painter.x = x;
        painter.z= y;
        if (random(1) > .4) {
        for (int j = 0; j < 1; j++) {
          //painter = new PVector(random(-400, 400), 400, random(0, 500));          
          
          for (int i = 0; i < 2; i++) {
            int pidx = (int) random(p.length);
            
            paintGlobs.add(new Mover(constrain(randomGaussian(), .1, 1), painter.x, painter.y, painter.z, p[pidx])); 
          }
        }
      }
      }
    }
  }
}



void textCircle(float x, float y, float D, color fg) {
  noStroke();
  ellipseMode(CENTER);  
  //circle(x, y, D);
  int cap = (int)D/2 * 200;
  for (int i = 0; i < cap; i++) {
    float theta1 = random(1) * TWO_PI;
    float x1 = x + cos(theta1) * D/2 + randomGaussian() * 1;
    float y1 = y + sin(theta1) * D/2 + randomGaussian() * 1;
    float theta2 = random(1) * TWO_PI;
    float x2 = x + cos(theta2) * D/2 + randomGaussian() * 1;
    float y2 = y + sin(theta2) * D/2 + randomGaussian() * 1;
    strokeWeight(.8);
    stroke(fg);
    line(x1, y1, x2, y2);   
  }     
}


void keyReleased() {
  if (key == 's' || key == 'S') {
    
    saveFrame(getTemporalName(sketchName, saveFormat));
  }
    
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

color white_noise_dithering(color in) {
  float h = hue(in);
  float s = 0;
  float b = map(brightness(in), 0, 100, 0, 1);
  b = b > 1.0 - random(1) ? 100 : 0; 
  return color(h, s, b);
}

void grid(float x, float y, float w, float h, float spacing) {
  strokeWeight(1);
  stroke(0);
  for (float currentX = x; currentX < x + w; currentX+=spacing) {
    for (float currentY = y; currentY < y + h; currentY+=spacing) {
      point(currentX, currentY);
    }
  }
}

private void generateAsciiMap() {
        float radius = 35;
        int k = 30;
        float centerX = 100 / 2.0f;
        float centerY = 100 / 2.0f;
        PoissonDiscSampler sampler = new PoissonDiscSampler(100, 100);

        for (char c = 32; c <= 126; c++) {
            ArrayList<PVector> allSamples = sampler.poissonDiskSampling(radius, k);

            // Move points towards the center.
            for (PVector point : allSamples) {
                float dx = centerX - point.x;
                float dy = centerY - point.y;
                point.x += dx * 0.5f;
                point.y += dy * 0.5f;
            }

            ArrayList<PVector> selectedSamples = new ArrayList<>();
            int pointAdj = (int) randomGaussian();
            for (int i = 0; i < Math.min(pointAdj + 5, allSamples.size()); i++) {
                PVector sample = allSamples.get(i);
                sample.x /= 100;
                sample.y /= 100;
                selectedSamples.add(sample);
            }

            /* rotate by angle
            selectedSamples.sort(new Comparator<PVector>() {
                @Override
                public int compare(PVector vec1, PVector vec2) {
                    PVector centroid = computeCentroid(selectedSamples);
                    PVector v1 = new PVector(vec1.x - centroid.x, vec1.y - centroid.y);
                    PVector v2 = new PVector(vec2.x - centroid.x, vec2.y - centroid.y);

                    float angle1 = atan2(v1.y, v1.x);
                    float angle2 = atan2(v2.y, v2.x);

                    return Float.compare(angle1, angle2);
                }
            });
             */


            asciiMap.put(c, selectedSamples);
        }
    }



    private PVector computeCentroid(ArrayList<PVector> points) {
        float cx = 0;
        float cy = 0;
        for (PVector point : points) {
            cx += point.x;
            cy += point.y;
        }
        return new PVector(cx / points.size(), cy / points.size());
    }
    
    
        public void addMetaShape(int blockWidth, int circleX, int circleY, int sides) {

        MetaShape ms = new MetaShape(blockWidth, blockWidth, sides, this);


        int radius = blockWidth / 2;  // Random radius between 5 and 20
        TileCircle tc = page.tryPlaceCircle(circleX, circleY, radius);

        if (tc != null) {
            tc.setMetaShape(ms);
            page.circles.add(tc);
        }
    }
    
    
    boolean placeAndDrawWord(String word, int startX, int startY, float tileSize, float gap, Board page) {

        TileRect tr = page.tryPlaceWord(word, startX, startY, tileSize, gap);
        if (tr != null) {
            tr.word = word;
            tr.tileSize = tileSize;
            tr.gap = gap;
            page.rects.add(tr);
            return true;
        }
        return false;
    }
