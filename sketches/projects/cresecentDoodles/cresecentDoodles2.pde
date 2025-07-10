import org.locationtech.jts.geom.*;
import org.locationtech.jts.geom.util.*;
import org.locationtech.jts.operation.overlay.OverlayOp;
import org.locationtech.jts.operation.buffer.BufferOp;
import org.locationtech.jts.algorithm.construct.LargestEmptyCircle;
import org.locationtech.jts.operation.polygonize.Polygonizer;
import org.locationtech.jts.algorithm.ConvexHull;

import java.util.*;

GeometryFactory geomFactory = new GeometryFactory();


void setup() {
  size(1000, 1000, P2D);
  smooth(8);
}

void draw() {
  background(#001B2E);

  Point center1 = geomFactory.createPoint(new Coordinate(100, 100));
  Point center2 = geomFactory.createPoint(new Coordinate(150, 150));
  Geometry circle1 = center1.buffer(100);
  Geometry circle2 = center2.buffer(100);
          
  Geometry crescent;
  
  crescent = circle2.difference(circle1);
  drawGeometry(crescent);
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
