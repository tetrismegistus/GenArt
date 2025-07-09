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

int ref = #F7ECE1;
float h = 0;
float s = 0;
float b = 0;

PGraphics  buffer;

void setup() {
  size(1000, 1000, P2D);
  colorMode(HSB, 360, 100, 100, 1);
  
  buffer = createGraphics(2000, 2000, P2D);
  h = hue(ref);
  s = saturation(ref);
  b = brightness(ref);

  
}


void draw() {  
  background(0);
  buffer.smooth(8);
  buffer.beginDraw();
  buffer.colorMode(HSB, 360, 100, 100, 1);

  buffer.background(#242038);
  //textSquare(0, 0, width, #FFFFFF);
  float sz = width *.45;
  int sides = 3;
  for (int y = floor(sz*.4); y < buffer.height - (sz + 150); y+= sz + 150) {
    for (int x = floor(sz*.9); x < buffer.width; x+= sz + 150){
      metaShape(x, y, sz, sides);
      sides += 1;
    }
  }
  buffer.endDraw();
  image(buffer, 0, 0, width, height);    
  buffer.save(getTemporalName(sketchName, saveFormat));
  noLoop();
}

void metaShape(float x1, float y1, float h, int sides) {
  float x2 = x1;
  float y2 = y1 + h; 
  float D1 = dist(x1, y1, x2, y2);
 
  float diameter = D1/4;
 
  PVector[] vertices = polygonVertices(x1, y1 + h/2, sides, diameter);
  PVector[] vertices2 = polygonVertices(x1, y1 + h/2, sides, diameter*2);
  
  drawCircles(vertices, diameter);
  drawCircles(vertices2, diameter);
  buffer.noFill();
  buffer.strokeWeight(1.5);
  buffer.stroke(ref);
  buffer.circle(x1, y1 + h/2, diameter);
  drawPolyConnections(vertices);
  drawPolyConnections(vertices2);
  buffer.strokeWeight(2);
  connectPolys(vertices, vertices2);
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

PVector[] polygonVertices(float x, float y, int sides, float sz){   
  // collect vertices around the sides of a polygon
  PVector[] corners = new PVector[sides];   
  for (int i = 0; i < sides; i++) {
    float step = radians(360/sides);
    corners[i] = new PVector(sz * cos(i*step) + x, sz * sin(i*step) + y);      
  }   
  return corners;     
}

void drawPolyConnections(PVector[] vertices) {
  // draw lines between each vertex in a set of vertex
  buffer.strokeWeight(1);
  for (int i = 0; i < vertices.length; i++) {
    for (int j = 0; j < vertices.length; j++) {
      buffer.stroke(h,s, 100);
      if (i != j) buffer.line(vertices[i].x, vertices[i].y, vertices[j].x, vertices[j].y);         
    }      
  }
}

void connectPolys(PVector[] v1, PVector[]v2) {
 buffer.strokeWeight(.95);
  for (int i = 0; i < v1.length; i++) {
    for (int j = 0; j < v2.length; j++) {
      buffer.stroke(h,s, 80);
      if (i != j) buffer.line(v1[i].x, v1[i].y, v2[j].x, v2[j].y);         
    }      
  }

}

void drawCircles(PVector[] vertices, float diameter) {
  buffer.noFill();
  buffer.strokeWeight(1.5);
  buffer.stroke(ref);
  for (int v = 0; v < vertices.length; v++) {
    buffer.circle(vertices[v].x, vertices[v].y, diameter);
  }
}
