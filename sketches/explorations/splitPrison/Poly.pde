class TexturedPoly {
  Geometry geometry;
  int clr;
  PVector min;
  PVector max;

  TexturedPoly(Geometry geometry, int clr) {
    this.geometry = geometry;
    this.clr = clr;
    calculateBoundingBox();
  }

  void calculateBoundingBox() {
    Envelope envelope = geometry.getEnvelopeInternal();
    min = new PVector((float) envelope.getMinX(), (float) envelope.getMinY());
    max = new PVector((float) envelope.getMaxX(), (float) envelope.getMaxY());
  }

  boolean isInsidePolygon(float px, float py) {
    Coordinate point = new Coordinate(px, py);
    return geometry.contains(geometryFactory.createPoint(point));
  }

  PVector findNearestEdge(float px, float py) {
    float minDist = Float.MAX_VALUE;
    PVector nearestEdge = null;

    Coordinate[] coords = geometry.getCoordinates();
    for (int i = 0; i < coords.length - 1; i++) {
      Coordinate v1 = coords[i];
      Coordinate v2 = coords[i + 1];

      PVector pv1 = new PVector((float) v1.x, (float) v1.y);
      PVector pv2 = new PVector((float) v2.x, (float) v2.y);

      PVector edge = PVector.sub(pv2, pv1);
      PVector toPoint = PVector.sub(new PVector(px, py), pv1);
      float t = PVector.dot(toPoint, edge) / edge.magSq();
      t = constrain(t, 0, 1);
      PVector projection = PVector.add(pv1, PVector.mult(edge, t));
      float dist = PVector.dist(new PVector(px, py), projection);

      if (dist < minDist) {
        minDist = dist;
        nearestEdge = projection;
      }
    }

    return nearestEdge;
  }
  
  void display(PGraphics pg, int fillColor, int strokeColor, float offset, boolean enableFill) {
    // Ensure we only try to draw polygonal geometries
    if (!(geometry instanceof Polygon)) {
      return;
    }
  
    Polygon polygon = (Polygon) geometry;
  
    pg.beginDraw();
    if (enableFill) {
      pg.fill(fillColor);
    } else {
      pg.noFill();
    }

    pg.stroke(strokeColor);

    // --- Draw the outer boundary ---
    pg.beginShape();
    Coordinate[] exterior = polygon.getExteriorRing().getCoordinates();
    for (Coordinate c : exterior) {
      pg.vertex((float) c.x + offset, (float) c.y + offset);
    }
  
    // --- Draw holes (if any) ---
    for (int i = 0; i < polygon.getNumInteriorRing(); i++) {
      Coordinate[] hole = polygon.getInteriorRingN(i).getCoordinates();
      pg.beginContour();
      for (Coordinate c : hole) {
        pg.vertex((float) c.x + offset, (float) c.y + offset);
      }
      pg.endContour();
    }
  
    pg.endShape(CLOSE);
    pg.endDraw();
  }



}
