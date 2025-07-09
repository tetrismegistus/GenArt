String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
}


void draw() {
  background(#2E282A);
  textSize(14);
  strokeWeight(1);
  stroke(0);
  fill(0);
  float h = hour() - 12;
  text(h + ":" + minute() + ":" + second(), 20, 20);


  float hx = cos(radians(h*30 - 90)) * 100;
  float hy = sin(radians(h*30 - 90)) * 100;
  float mx = cos(radians(minute()*6 - 90)) * 150;
  float my = sin(radians(minute()*6 - 90)) * 150;
  float sx = cos(radians(second()*6 - 90)) * 180;
  float sy = sin(radians(second()*6 - 90)) * 180;
  
  strokeWeight(1);
  for (int t = 0; t < 60; t++) {
    stroke(0);
    float x = cos(radians(6 * t)) * 200;
    float y = sin(radians(6 * t)) * 200;
    stroke(#CD5334);
    line(width/2 + x, height/2 + y, width/2 + sx, height/2 + sy);
    stroke(#EDB88B);
    line(width/2 + x, height/2 + y, width/2 + mx, height/2 + my);
    if ( 6 * t % 5 == 0) {
      stroke(#17BEBB);
      line(width/2 + x, height/2 + y, width/2 + hx, height/2 + hy);
      
    }
    
  }
  
    strokeWeight(.1);
  noFill();
  //fill(0, 0, 100);
  beginShape();
  vertex(width/2 + mx, height/2 + my);
  vertex(width/2 + sx, height/2 + sy);
  vertex(width/2 + hx, height/2 + hy);
  vertex(width/2 + mx, height/2 + my);
  endShape();
  
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
