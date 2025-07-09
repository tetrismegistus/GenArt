/*
SketchName: gen1_try2.pde
Description: Vertical or horizontal lines only.
*/

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

float leftMargin;
float rightMargin;
float innerGaps;
float measureLength;
color[] p = {#dde2c6, #bbc5aa, #a72608, #090c02};

void setup() {
  size(1000, 1300);
  colorMode(HSB, 360, 100, 100, 1);
  noLoop();
}

void draw() {
  background(#E6EED6);

  // Margins and staff setup
  leftMargin = width / 20;
  rightMargin = width - leftMargin;
  float topMargin = height / 10;
  float bottomMargin = height / 10;
  float availableHeight = height - (topMargin + bottomMargin); 
  int numStaffs = 6; 
  float staffHeight = availableHeight / numStaffs; 
  float innerStaffHeight = staffHeight * 0.6; 

  // Measure length setup
  float staffWidth = rightMargin - leftMargin;
  measureLength = staffWidth / 8.0;
  // Draw staffs
  for (int i = 0; i < numStaffs; i++) {
    float y1 = topMargin + i * staffHeight; // Starting Y for each staff
    float y2 = y1 + innerStaffHeight; // Ending Y for each staff
    drawStaff(y1, y2);
  }
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
