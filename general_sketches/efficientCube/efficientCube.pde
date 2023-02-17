/*
SketchName: default.pde
Credits: Literally every tutorial I've read and SparkyJohn
Description: My default starting point for sketches
*/

String sketchName = "mySketch";
String saveFormat = ".png";

int calls = 0;
long lastTime;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 1);
  noLoop();
}


void draw() {
  background(#09122c);
  textSquare(0, 0, width, #FFFFFF);
  float x1 = width/2;
  float y1 = 100;
  float x2 = width/2;
  float y2 = height - 100; 
  float D1 = dist(x1, y1, x2, y2);
 
  float diameter = D1/4;
  
  int sides = 6;
  
  
  PVector[] vertices = polygonVertices(width/2, height/2, sides, diameter);
  PVector[] vertices2 = polygonVertices(width/2, height/2, sides, diameter*2);
  
  noFill();
  drawCircles(vertices, diameter);
  drawCircles(vertices2, diameter);
  textCircle(width/2, height/2, diameter, #1c5d99, #FEFBEA);
  drawPolyConnections(vertices);
  drawPolyConnections(vertices2);
  connectPolys(vertices, vertices2);
  
  save(getTemporalName(sketchName, saveFormat));
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
    
  PVector[] corners = new PVector[sides]; 
  
  for (int i = 0; i < sides; i++) {
    float step = radians(360/sides);
    corners[i] = new PVector(sz * cos(i*step) + x, sz * sin(i*step) + y);      
  } 
  
  return corners;     
}

void drawPolyConnections(PVector[] vertices) {
  for (int i = 0; i < vertices.length; i++) {
    for (int j = 0; j < vertices.length; j++) {
      lerpLine(vertices[i].x, vertices[i].y, vertices[j].x, vertices[j].y, #fd5e53);         
    }      
  }
}

void connectPolys(PVector[] v1, PVector[]v2) {
  for (int i = 0; i < v1.length; i++) {
    for (int j = 0; j < v2.length; j++) {
      lerpLine(v1[i].x, v1[i].y, v2[j].x, v2[j].y, #fd5e53);         
    }      
  }

}

void drawCircles(PVector[] vertices, float diameter) {
  for (int v = 0; v < vertices.length; v++) {
    textCircle(vertices[v].x, vertices[v].y, diameter, #1c5d99, #FEFBEA);
  }
}
