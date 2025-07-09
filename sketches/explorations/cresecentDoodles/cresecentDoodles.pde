import org.locationtech.jts.geom.*;
import org.locationtech.jts.geom.util.*;
import org.locationtech.jts.operation.overlay.OverlayOp;
import org.locationtech.jts.operation.buffer.BufferOp;
import org.locationtech.jts.algorithm.construct.LargestEmptyCircle;
import org.locationtech.jts.operation.polygonize.Polygonizer;
import org.locationtech.jts.algorithm.ConvexHull;

import java.util.*;

GeometryFactory geometryFactory = new GeometryFactory();
ArrayList<MyCircle> circles = new ArrayList<>();
ArrayList<MyCircle> gridCircles = new ArrayList<>();
List<Polygon> polygons = new ArrayList<>();
String sketchName = "mySketch";
String saveFormat = ".png";
int calls = 0;
long lastTime;

color[] p = {#294c60, #adb6c4, #ffefd3, #ffc49b};
int numLines = 4;  // Number of random lines
float splitWidth = 4;
float gridRad = 200;
int packs = 100;


void setup() {
  size(1000, 1000, P2D);
  smooth(8);
  
    // 1. Create outer square

  
  float r = gridRad;
  for (float x = r; x <= width-r; x+=r) {
    for (float y = r; y <= height-r; y+=r) {      
      gridCircles.add(new MyCircle(x, y, r -20));
    }
  }
  
  for (int i = 0; i < packs; i++) {
    packCircle(random(10, r * 2));
  }
  
  for (int j = 0; j < circles.size(); j++) {
    for (int i = 0; i < gridCircles.size(); i++) {
      
      MyCircle c1 = circles.get(j);
      MyCircle c2 = gridCircles.get(i);
      if (circlesIntersect(c1, c2)) {      
        GeometryFactory geomFactory = new GeometryFactory();
        Point center1 = geomFactory.createPoint(new Coordinate(c1.x, c1.y));
        Point center2 = geomFactory.createPoint(new Coordinate(c2.x, c2.y));
        Geometry circle1 = center1.buffer(c1.r/2);
        Geometry circle2 = center2.buffer(c2.r/2);
          
        Geometry crescent;
        
        crescent = circle2.difference(circle1);
        polygons.add((Polygon)crescent);
        
        
      }
    }      
  }
  List<Polygon> splits = createSplits(numLines, splitWidth);
  polygons = splitPolygons(polygons, splits);
  
  
}

void draw() {
  background(#001B2E);
  
  noStroke();
  smoothAndDraw(polygons, p);
  save(getTemporalName(sketchName, saveFormat));  
  noLoop();
}

boolean circlesIntersect(MyCircle c1, MyCircle c2) {
  float d = dist(c1.x, c1.y, c2.x, c2.y);
  return d < (c1.r/2 + c2.r/2) && d > abs(c1.r/2 - c2.r/2);
}

void drawGeometry(Geometry geom) {
  beginShape();
  for (Coordinate coord : geom.getCoordinates()) {
    vertex((float) coord.x, (float) coord.y);
  }
  endShape(CLOSE);
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
