/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/
import processing.svg.*;

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float[][] grid;
float[][] averages2;
int left_x;
int right_x; 
int top_y; 
int bottom_y;
int resolution, num_columns, num_rows;

color[] p = {#173753, #6daedb, #2892d7, #1b4353, #1d70a2};

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
  
  left_x = int(width * -0.5);
  right_x = int(width * 1.5); 
  top_y = int(height * -0.5); 
  bottom_y = int(height * 1.5);
  resolution = int(width * 0.015); 
  num_columns = (right_x - left_x) / resolution; 
  num_rows = (bottom_y - top_y) / resolution;
  
  grid = new float[num_columns][num_rows];
  
  
  String[] lines = loadStrings("pg10.txt");
  String text = join(lines, ""); // Combine all lines into a single string    
  char[] characters = text.toCharArray(); // Convert the string to a char arr
  ArrayList<Float> thetas = new ArrayList<>();
  for (char c : characters) {
    if (c > 32 && c < 127) {      
      thetas.add(map(c, 32, 126, HALF_PI, 3 * HALF_PI));      
    }
  }
  
  int cidx = 0;
  for (int x = 0; x < num_columns; x++) {
    for (int y = 0; y < num_rows; y++) {            
      grid[x][y] = thetas.get(cidx);
      cidx++;
    }
  }  
  
  for (int i = 0; i < 10; i++) {
    grid = averageField(grid);
  }

  
}


float[][] averageField(float[][] grid) {
  float[][] averages;
  averages = new float[grid.length][grid[0].length];  
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[i].length; j++) {
        float sum = grid[i][j];
        int count = 1;
        for (int k = i - 1; k <= i + 1; k++) {
            for (int l = j - 1; l <= j + 1; l++) {
                if (k >= 0 && k < grid.length && l >= 0 && l < grid[k].length && (k != i || l != j)) {
                    sum += grid[k][l];
                    count++;
                }
            }
        }
        averages[i][j] = sum / count;
    }
  }
  return averages;
}


void draw() {
  
  background(#FFFFFF);
  for (float j = 100; j < width-50; j+= 5) {
    for (float k = 100; k <= height-100; k+= 5) {
      
        float x = j;
        float y = k;
        float step_length = .5;
        beginShape();
        //strokeWeight(random(.1, .5));
        noFill();        
        stroke(p[(int)random(p.length)]);
        strokeWeight(.5);
        int cap = 100;
        for (int i = 0; i < cap; i++) {
          curveVertex(x, y);
          float x_offset = x - left_x;
          float y_offset = y - top_y;
          int column_index = int(x_offset/resolution);
          int row_index = int(y_offset / resolution);
          float t = grid[column_index][row_index];
          float x_step = step_length * cos(t);
          float y_step = step_length * sin(t);
          x = x + x_step;
          y = y + y_step;
        }
        endShape();
      
    
    }
  }
  save(getTemporalName(sketchName, saveFormat));
  noLoop();  
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
