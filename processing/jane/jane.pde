color[] pal = {#ff616a, #cf616a, #9f616a, #6f616a, #3f616a};

float R = 6371;
referencePoint p0;
referencePoint p1;
import java.util.Random;
import java.util.List;

import toxi.geom.*;
import toxi.geom.mesh2d.Voronoi;

import toxi.processing.*;

ToxiclibsSupport gfx;
List<DataPoint> points;

color yellow = color(255, 228, 4);
color green = color(0, 165, 78);
color cyan = color(148, 193, 214);
color red = color(237, 34, 40);
color white = color(255);
color black = color(0);
color[] colors = {yellow, cyan, red, white};

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

Table table;
  
void setup() {
  size(2500, 1700);
  points = new ArrayList<DataPoint>();
  p0 = new referencePoint(0, 0, 49.388407, -126.871423);
  p1 = new referencePoint(width, height, 24.114168,-65.230650);
  p0.setPos();
  p1.setPos();
  colorMode(HSB, 360, 100, 100, 1);
  table = loadTable("LIHTCPUB.CSV");
  table.setMissingFloat(0);
    for (int i = 0; i < table.getRowCount(); i++) {
    float[] row = table.getFloatRow(i);  
    float latitude = row[0];
    float longitude = row[1];    
    if (latitude != Float.NaN && longitude != Float.NaN) {
      PVector pos = latLngToScreenXY(latitude, longitude);
      if(pos.x > 0 && pos.x < width && pos.y > 0 && pos.y < height) {
        points.add( new DataPoint(pos, 5));
      }
 //<>//
        
     }
   }
   gfx = new ToxiclibsSupport(this);
  

}


void draw() {
  background(#EBD5B3);
  stroke(0);
  strokeWeight(.1);
  noFill();
  
  drawPoints(points);
  stroke(255);
  println("done");
  
  noLoop();
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(getTemporalName(sketchName, saveFormat));  
}


PVector latLngToGlobalXY(float lat, float lon) {
  float x = R * lon * cos((p0.lat + p1.lat)/2); //<>//
  float y = R*lat;
  return new PVector(x, y);
}

PVector latLngToScreenXY(float lat, float lon) {
  PVector pos = latLngToGlobalXY(lat, lon);
  float perX = ((pos.x - p0.pos.x)/(p1.pos.x-p0.pos.x));
  float perY = ((pos.y-p0.pos.y)/(p1.pos.y - p0.pos.y));
  return new PVector(p0.scrX + (p1.scrX - p0.scrX)*perX, p0.scrY + (p1.scrY - p0.scrY)*perY); 
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

void drawPoints(List<DataPoint> pts) {
  float cpx1 = 0;
  float cpy1 = 0;
  float cpx2 = width;
  float cpy2 = height;
  
  for (DataPoint p : pts) {    
    color c = pal[(int) random(pal.length)];        
    noFill();    
    stroke(pal[4], .5);    
    bezier(p.pos.x, p.pos.y, cpx1, cpy1, cpx2, cpy2, width/2, height/2);     
    fill(pal[4]);    
    noFill();
    
    //line(p.x, p.y, width/2, height/2);
  }
  
  
  for (DataPoint p : pts) {    
    color c = pal[(int) random(pal.length)];        
    noFill();    
    stroke(pal[4], .5);    
    weirdShape(p.pos.x, p.pos.y, c, 5);
    fill(pal[4]);    
    noFill();
    
    //line(p.x, p.y, width/2, height/2);
  }
}

void shuffleArray(int[] array) {
 
  // with code from WikiPedia; Fisher–Yates shuffle 
  //@ <a href="http://en.wikipedia.org/wiki/Fisher" target="_blank" rel="nofollow">http://en.wikipedia.org/wiki/Fisher</a>–Yates_shuffle
 
  Random rng = new Random();
 
  // i is the number of items remaining to be shuffled.
  for (int i = array.length; i > 1; i--) {
 
    // Pick a random element to swap with the i-th element.
    int j = rng.nextInt(i);  // 0 <= j <= i-1 (0-based array)
 
    // Swap array elements.
    int tmp = array[j];
    array[j] = array[i-1];
    array[i-1] = tmp;
  }
}

void weirdShape(float x, float y, int c, float srad) {
  pushMatrix();
  translate(x, y);
  
  
  noStroke();
  for (int i = 0; i < 10; i++)
  {
    beginShape();
    fill(c, .1);
    rotate(radians(random(360)));
    noiseSeed(i * 2214787);
    for (int d = 0; d < 360; d+=5) {
      
      float t = radians(d);
      float nx = cos(t) * srad + random(srad/8, srad/8);
      float ny = sin(t) * srad + random(srad/8, srad/8);
      float n = map(noise(nx * .1, ny * .1), 0, 1, -1, 1) * srad/10;
      point(nx + n, ny + n);
      curveVertex(nx + n, ny + n);
      //point(nx, ny);
    }
    endShape();
    
  }
  popMatrix();
}
