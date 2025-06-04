class TexturedPoly {
  Geometry geometry;
  color clr;
  PVector min;
  PVector max;

  TexturedPoly(Geometry geometry, color clr) {
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

  void display(PGraphics pg, color ref, color ref2, float offset) {
    pg.beginDraw();
    pg.strokeWeight(.8);
    for (float x = min.x; x <= max.x; x+=1) {
      for (float y = min.y; y <= max.y; y+=1) {
        if (isInsidePolygon(x, y)) {
          float n = fbm_warp(x + offset, y + offset, 3, 0.2, 0.9);  // Use your existing function
          color curColor = (n > 0) ? ref2 : ref;
          float brt = map(n, -1, 1, 50, 100);
          //pg.strokeWeight(map(n, -1, 1, .1, .8));
          pg.stroke(hue(curColor), saturation(curColor), brt);
          pg.point(x, y);
        }
      }
    }
    
    pg.endDraw();
  }

  void discDisplay(PGraphics pg) {
    float radius = 5; // Adjust the radius as needed
    int k = 30; // Adjust the k parameter as needed

    // Generate points using Poisson disk sampling
    ArrayList<PVector> points = poissonDiskSampling(radius, k);

    for (PVector p : points) {
        float px = p.x;
        float py = p.y;
        if (isInsidePolygon(px, py)) {
            
                float noiseValue = noiseWithOctaves(px * 0.025, py * 0.025, 6, .8);
                float brightness = map(noiseValue, 0, 1, 40, 60);
                gaussianStrokeWeight(4, 2, 6, pg);
                pg.stroke(gaussianColor(clr, brightness, brightness + 10)); // Adjust base color and range as needed
                pg.point(px, py);
            
        }
    }
 }
}
